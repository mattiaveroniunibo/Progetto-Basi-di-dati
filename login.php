<?php
session_start(); // Avvia la sessione
include 'db_connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST["email"];
    $password = $_POST["password"];

    $sql = "CALL AutenticaUtente(?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $email, $password);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($row["Messaggio"] === "Autenticazione riuscita") {
        $_SESSION["email"] = $email; // Salva l'email nella sessione
        echo json_encode(["success" => true, "message" => "Autenticazione riuscita", "email" => $email]);
    } else {
        echo json_encode(["success" => false, "message" => "Autenticazione fallita"]);
    }

    $stmt->close();
    $conn->close();
}
?>
