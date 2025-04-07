<?php
session_start();
include 'db_connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST["email"];
    $password = $_POST["password"];
    $is_admin = isset($_POST["is_admin"]);
    $message = "";
    $success = false;

    if ($is_admin) {
        $code = $_POST["security_code"] ?? '';
        $stmt = $conn->prepare("CALL LoginAmministratore(?, ?, ?)");
        $stmt->bind_param("sss", $email, $password, $code);
    } else {
        $stmt = $conn->prepare("CALL AutenticaUtente(?, ?)");
        $stmt->bind_param("ss", $email, $password);
    }

    if ($stmt->execute()) {
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();

        if (isset($row["Messaggio"]) && str_contains($row["Messaggio"], "riuscit")) {
            $success = true;
            $message = $row["Messaggio"];
        } else {
            $message = $row["Messaggio"];
        }
    } else {
        $message = "Errore esecuzione login";
    }

    $stmt->close();
    $conn->close();

    echo json_encode([
        "success" => $success,
        "message" => $message,
        "email" => $email,
        "admin" => $is_admin ? "1" : "0"
    ]);
}
?>
