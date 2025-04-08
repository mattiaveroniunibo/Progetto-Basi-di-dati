<?php
include("db_connect.php");
require_once("mongo_logger.php");

$competenza = $_POST["competenza"] ?? null;
$livello = $_POST["livello"] ?? null;
$email = $_POST["email"] ?? null; 

$response = ["success" => false, "message" => ""];

if ($competenza && is_numeric($livello)) {
    $stmt = $conn->prepare("CALL InserisciSkill(?, ?)");
    $stmt->bind_param("si", $competenza, $livello);

    if ($stmt->execute()) {
        $response["success"] = true;
        $response["message"] = "Skill inserita con successo!";
        
        logEvento("Nuova skill inserita: {$competenza} (livello {$livello})", $email);
    } else {
        $response["message"] = "Errore nell'inserimento della skill.";
    }

    $stmt->close();
} else {
    $response["message"] = "Dati incompleti o non validi.";
}

$conn->close();
echo json_encode($response);
