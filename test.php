<?php
$servername = "localhost";
$username = "root";  
$password = "root";  
$dbname = "BOSTARTER";
$port = 3306; // ⚠️ Controlla in MAMP se usa 8889 o 3306

$conn = new mysqli($servername, $username, $password, $dbname, $port);

if ($conn->connect_error) {
    die("Connessione fallita: " . $conn->connect_error);
}
echo "Connessione riuscita!";
?>

