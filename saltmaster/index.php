<?php

$config = parse_ini_file('../config.ini');
$servername = $config['servername'];
$username = $config['username'];
$password = $config['password'];
$dbname = $config['dbname'];

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
$sql = "SELECT emp_no, first_name, last_name, gender, birth_date, hire_date from employees where birth_date = '1965-02-01' and gender = 'M' and hire_date > '1990-01-01' ORDER BY concat(first_name,last_name)";
#$sql = "select * from employees where birth_date = '1965-02-01' and gender = 'M' and hire_date > '1990-01-01' ORDER BY concat(first_name,last_name);
#$sql = "SELECT first_name, last_name, gender, hire_date FROM employees";
$result = $conn->query($sql);

?>
<Head><TITLE>POC Query Result Page</TITLE><HEAD>
<THML><BODY>
<CENTER><H1>POC Query Result Page</H1></CENTER><HR>
<P>The purpose of this result page is to display the following requirements:</P>
<B>"Deploy a simple app that outputs the list of employees that are Male which birth date is 1965-02-01 and the hire date is greater than 1990-01-01 ordered by the Full Name of the employee"</B>
<BR><BR>
The following is a result of this request.  Although the data to display was not outlined, I provided the following:<br>
 <li>Employee Number</li>
 <li>Full Name </li>
 <li>Gender </li>
 <li>Birth Date </li>
 <li>Hire Date </li>
<br>
<B>NOTE:</B> The request specified the query be orderd by 'Full Name' so the sort order concatenated the first and last name. (A common order is Full Name sorted by the last name, in which case I would have used concat(last_name,first_name) instead.)<br>
<br><br>
The query used was:<br>
<P> </P><B> SELECT emp_no, first_name, last_name, gender, birth_date, hire_date from employees where birth_date = '1965-02-01' and gender = 'M' and hire_date > '1990-01-01' ORDER BY concat(first_name,last_name) </B><br>
<br><br>
<H3>The results of the query are:</H3><hr>
<CENTER><table style="width:70%" border="1" align="center">
  <tr>
    <th>Employee #</th>
    <th>Name</th>
    <th>Gender</th>
    <th>Birth Date</th>
    <th>Hire Date</th>
  </tr>
  <tr>
<?php

if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "<td>" . $row["emp_no"]. "</td><td>" . $row["first_name"]. " " . $row["last_name"]. "</td><td>" . $row["gender"]. "</td><td>" . $row["birth_date"]. "</td><td>" . $row["hire_date"]. "</td></tr>";
    }
} else {
    echo "</tr></TABLE><B>0 results</B>";
}
$conn->close();
?>
</TABLE></CENTER></BODY></HTML>


