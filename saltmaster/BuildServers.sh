#!/bin/bash
#
# Build script to be run on salt-master container after docker-compose builds server.
# Put state files where they belong
#
# define some functions

#DB Install
function dbinstall {
    salt $1 state.apply database_installed;
    MYSQLSERVER=`salt $1 pkg.list_pkgs | grep mysql-server-core-5.7`
    MYSQLCLIENT=`salt $1 pkg.list_pkgs | grep mysql-client-5.7`
    if [ -z "$MYSQLSERVER" ] || [ -z "$MYSQLCLIENT" ]
    then
        # lets try one more time
        salt $1 state.apply database_installed;
        MYSQLSERVER=`salt $1 pkg.list_pkgs | grep mysql-server-core-5.7`
        MYSQLCLIENT=`salt $1 pkg.list_pkgs | grep mysql-client-5.7`
        if [ -z "$MYSQLSERVER" ] || [ -z "$MYSQLCLIENT" ]
        then
            echo "Package(s) failed to install!";
            exit 1;
        fi
    fi
}

# WEB Install
function webinstall {
    salt $1 state.apply web_installed;
    NGINX=`salt $1 pkg.list_pkgs | grep nginx:`
    PHPFPM=`salt $1 pkg.list_pkgs | grep php7.2-fpm:`
    PHPMYSQL=`salt $1 pkg.list_pkgs | grep php7.2-mysql:`
    if [ -z "$NGINX" ] || [ -z "$PHPFPM" ] || [ -z "$PHPMYSQL" ]
    then
        # lets try one more time
        salt $1 state.apply web_installed;
        NGINX=`salt $1 pkg.list_pkgs | grep nginx:`
        PHPFPM=`salt $1 pkg.list_pkgs | grep php7.2-fpm:`
        PHPMYSQL=`salt $1 pkg.list_pkgs | grep php7.2-mysql:`
        if [ -z "$NGINX" ] || [ -z "$PHPFPM" ] || [ -z "$PHPMYSQL" ]
        then
            echo "Package(s) failed to install!";
            exit 1;
        fi
    fi
}

# DB Access control
function dbaccess {
    salt $1 cmd.run " mysql -u root -pChangeAfter1Install -e \"CREATE USER 'minion'@'localhost' IDENTIFIED BY 'password';GRANT ALL PRIVILEGES ON * . * TO 'minion'@'localhost';GRANT ALL ON *.* to minion@'$2' IDENTIFIED BY 'password';flush privileges\""
}

# Build php files
function phpconfig {
    salt $1 cmd.run "printf '[database]\nservername = $2\nusername = minion\npassword = password\ndbname = employees' > /var/www/config.ini"
    salt-cp $1 ./index.php /var/www/html/index.php
}

# MAIN
#
mkdir /srv/salt
cp *.sls /srv/salt/

# lets make sure we have two minions before we get started
GOOD=`salt '*' test.ping --output=txt | wc -l`;
if [ $GOOD -ne 2 ]; then
    echo "Cound not find 2 minions ready, ABORT!"
    exit 1
fi

# now walk through the servers we see
for i in `salt '*' cmd.run 'echo $HOSTNAME' --out=txt | sed 's/ //'`;
do
    ID=`echo ${i} | cut -d ':' -f1`;
    ROLE=`echo ${i} | cut -d ':' -f2`;
    echo "Working on the $ROLE server with ID $ID";

    if [ "$ROLE" = "db" ]; then
        # Define DB_ID for later use
        DB_ID="$ID"
        # Get IP of the host
        DB_IP=`salt $ID cmd.run 'tail -1 /etc/hosts' --out=txt | awk '{print $2}'`;
        echo "IP of $DB_ID is $DB_IP..."
        # Install needed packages
        echo "Installing needed packages, this will take a few min.(Expect 1 false positive failure) Good time to get coffee?..."
        dbinstall $ID
        # Comment out bind-address in config to allow db to listen to all devices
        echo "Change bindings for Database..."
        salt $ID cmd.run "sed -i 's/bind-address/#bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf"
        # start DB
        echo "Starting database..."
        salt $ID cmd.run 'service mysql start'
        # tell DB to pull down their git repo and load into mysql
        echo "Pulling down test_db repo and importing into DB..."
        salt $ID cmd.run 'git clone https://github.com/datacharmer/test_db && cd test_db/ && mysql -u root -pChangeAfter1Install < employees.sql'

    elif [ "$ROLE" = "web" ]; then
        # Define WEB_ID for later use
        WEB_ID="$ID"
        # Get IP of the host
        WEB_IP=`salt $ID cmd.run 'tail -1 /etc/hosts' --out=txt | awk '{print $2}'`;
        echo "IP of $WEB_ID is $WEB_IP..."
        # Install needed packages
        echo "Installing needed packages..."
        webinstall $ID
        # Enable mysqli
        echo "Enabling mysqli and starting php-fpm..."
        salt $ID cmd.run "sed -i 's/;extension=mysqli/extension=mysqli/' /etc/php/7.2/fpm/php.ini"
        # Start php fpm
        salt $ID cmd.run "service php7.2-fpm start"
        # update nginx config
        echo "Updating nginx config and starting..."
        salt-cp $ID ./nginx_default /etc/nginx/sites-available/default
        # Start nginx
        salt $ID cmd.run "service nginx start"

    else
        echo "Server was not web or db, panic!"
    fi
done

# update scripts, push and run as needed

# Fix access for the webserver in the database
dbaccess $DB_ID $WEB_IP

# Push index.php and config file down to webserer
phpconfig $WEB_ID $DB_IP

echo "Done.  You should now be able to open http://<HOST_IP>:42000/index.php"
