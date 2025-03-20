<?php
include 'db_connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST["email"];
    $progetto = $_POST["progetto"];
    $testo = $_POST["testo"];

    $sql = "CALL InserisciCommento(?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $email, $progetto, $testo);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Commento inserito con successo."]);
    } else {
        echo json_encode(["success" => false, "message" => "Errore nell'inserimento del commento."]);
    }

    $stmt->close();
    $conn->close();
}
?>
