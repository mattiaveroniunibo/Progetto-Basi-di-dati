<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include 'db_connect.php';
header("Content-Type: application/json; charset=UTF-8");

$sql = "SELECT Email, Nickname, Nome, Cognome, Anno_Di_Nascita, Luogo_Di_Nascita FROM UTENTE";
$result = $conn->query($sql);

$users = [];
while ($row = $result->fetch_assoc()) {
    $users[] = $row;
}

echo json_encode($users);
$conn->close();
?>
