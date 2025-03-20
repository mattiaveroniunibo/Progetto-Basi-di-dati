<?php
include 'db_connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST["email"];
    $progetto = $_POST["progetto"];
    $importo = $_POST["importo"];
    $reward = $_POST["reward"];

    $sql = "CALL FinanziaProgetto(?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssds", $email, $progetto, $importo, $reward);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Finanziamento avvenuto con successo."]);
    } else {
        echo json_encode(["success" => false, "message" => "Errore nel finanziamento."]);
    }

    $stmt->close();
    $conn->close();
}
?>
