<?php
$host = "localhost";
$user = "root";       // Utente MySQL (controlla se usi un altro)
$password = "root";   // Prova ad aggiungere "root" se usi MAMP
$dbname = "BOSTARTER";

$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    die("Errore di connessione: " . $conn->connect_error);
}
?>