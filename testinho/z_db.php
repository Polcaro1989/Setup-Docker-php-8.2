<?php
$con = new mysqli("testinho_mariadb-8.2", "root", "root", "vogue");

if ($con->connect_errno) {
    echo "Failed to connect to MySQL: (" . $con->connect_errno . ") " . $con->connect_error;
} /*else {
    echo "Conexão bem-sucedida!";
}*/
?>
