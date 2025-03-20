<?php
include 'db_connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST["email"];
    $nickname = $_POST["nickname"];
    $password = $_POST["password"];
    $nome = $_POST["nome"];
    $cognome = $_POST["cognome"];
    $anno_nascita = $_POST["anno_nascita"];
    $luogo_nascita = $_POST["luogo_nascita"];

    $sql = "CALL RegistraUtente(?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssss", $email, $nickname, $password, $nome, $cognome, $anno_nascita, $luogo_nascita);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Registrazione avvenuta con successo."]);
    } else {
        echo json_encode(["success" => false, "message" => "Errore nella registrazione."]);
    }

    $stmt->close();
    $conn->close();
}
?>
