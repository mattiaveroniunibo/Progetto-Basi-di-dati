<?php
include("db_connect.php");
require_once("mongo_logger.php");

$response = ["success" => false, "message" => ""];

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $email = $_POST["email"];
    $nickname = $_POST["nickname"];
    $password = $_POST["password"];
    $nome = $_POST["nome"];
    $cognome = $_POST["cognome"];
    $anno_nascita = $_POST["anno_nascita"];
    $luogo_nascita = $_POST["luogo_nascita"];

    $stmt = $conn->prepare("CALL RegistraUtente(?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssss", $email, $nickname, $password, $nome, $cognome, $anno_nascita, $luogo_nascita);

    if ($stmt->execute()) {
        $response["success"] = true;
        $response["message"] = "Registrazione completata con successo!";
        logEvento("Nuovo utente registrato", $email);
    } else {
        $response["message"] = "Errore durante la registrazione.";
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($response);
?>
