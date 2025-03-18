<?php
header('Access-Control-Allow-Origin: *'); // Permette richieste CORS
header('Content-Type: application/json'); // Risposta JSON

require 'db_connect.php'; // Connessione al database

$sql = "SELECT Nome, Descrizione, Budget, Stato FROM PROGETTO";
$result = $conn->query($sql);

$progetti = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $progetti[] = $row;
    }
}

echo json_encode($progetti);
$conn->close();
?>
