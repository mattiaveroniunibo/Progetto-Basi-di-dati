<?php
header('Content-Type: application/json');
include 'db_connect.php';

// Array risposta iniziale
$response = [
    "top_creatori" => [],
    "top_progetti" => [],
    "top_finanziatori" => [],
];

// Query 1: classifica_affidabilita
$query1 = "SELECT * FROM classifica_affidabilita";
$result1 = $conn->query($query1);
if ($result1) {
    while ($row = $result1->fetch_assoc()) {
        $response["top_creatori"][] = $row;
    }
} else {
    http_response_code(500);
    echo json_encode(["error" => "Errore nella vista classifica_affidabilita"]);
    exit;
}

// Query 2: ProgettiQuasiCompletati
$query2 = "SELECT * FROM ProgettiQuasiCompletati";
$result2 = $conn->query($query2);
if ($result2) {
    while ($row = $result2->fetch_assoc()) {
        $response["top_progetti"][] = $row;
    }
} else {
    http_response_code(500);
    echo json_encode(["error" => "Errore nella vista ProgettiQuasiCompletati"]);
    exit;
}

// Query 3: ClassificaFinanziatori
$query3 = "SELECT * FROM ClassificaFinanziatori";
$result3 = $conn->query($query3);
if ($result3) {
    while ($row = $result3->fetch_assoc()) {
        $response["top_finanziatori"][] = $row;
    }
} else {
    http_response_code(500);
    echo json_encode(["error" => "Errore nella vista ClassificaFinanziatori"]);
    exit;
}

// Output finale in JSON (formattato)
echo json_encode($response, JSON_PRETTY_PRINT);

$conn->close();
?>
