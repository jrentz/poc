<B>POC Evalution</B>

This repo requires Ubuntu 16.04 LTS with Docker / Docker-compose installed

Please read the documentation file <a href="https://github.com/jrentz/poc/wiki/home">HERE</a> for full details.
Following this README will result in the following:

* Building of 3 unbuntu containers
* One container is a SaltStack master
* One container is a Webserver
* One server is a MySql server
* Final configuration of the web and database server is accomplished using SaltStack

<B>Prerequisites</B>

* A starting base OS of Ubuntu 16.04 LTS [ Click [HERE](https://github.com/jrentz/poc/wiki/Installing-Ubuntu-16.04-LTS) for installation instructions ]
* Docker version 18.09.2 and Docker-compose 1.8.0 [ Click [HERE](https://github.com/jrentz/poc/wiki/Installing-Docker-Docker-Compose-on-Ubuntu-16.04-LTS) for installation instructions ]
* Git [ Installed by default ]
* Public internet connection


<B>Installation</B>

From a Host server running Ubuntu 16.04 LTS with Docker, Docker-compose, and Git already installed, follow the step-by-step instructions below:

Clone the build repository

```sh
$ git clone https://github.com/jrentz/poc.git
$ cd ./poc/build
```

Build the SaltStack master, webserver and database server containers.


```sh
~/poc/build$ sudo ./build.sh

```

Now start the servers

```sh
~/poc/build$ cd ../scripts
~/poc/scripts$ sudo ./start.sh

```
Log into the SaltStack master server

```sh
~/poc/scripts$ sudo ./login_master.sh
:/#  echo $HOSTNAME
salt-master
:/#
```

From the SaltStack master, run the build script to finalize the install

```sh
:/# cd poc/saltmaster
:~/poc/saltmaster# ./BuildServers.sh
```

When the build script is complete, you can point your browser to port 42000 of the host server to view a webpage displaying the results requested.

The url would be something like: http://IP_OF_HOST:42000/

<B>Scripts</B>

Other scripts in the ./scripts directory
```sh
~/poc/scripts$ sudo ./stop.sh      [ Stop the servers ]
~/poc/scripts$ sudo ./login_db.sh  [ Login to the database server ]
~/poc/scripts$ sudo ./login_web.sh [ Login to the webserver ]
```

<B>Contact</B>

Writer: Jason Rentz

email: [jason@switchdatatech.com](mailto:jason@switchdatatech.com)
