<?php
include 'db_connect.php';

$competenza = $_POST['competenza'];
$livello = $_POST['livello'];

$stmt = $conn->prepare("CALL InserisciSkill(?, ?)");
$stmt->bind_param("si", $competenza, $livello);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Skill aggiunta con successo!"]);
} else {
    echo json_encode(["success" => false, "message" => "Errore nell'aggiunta della skill."]);
}

$stmt->close();
$conn->close();
?>
