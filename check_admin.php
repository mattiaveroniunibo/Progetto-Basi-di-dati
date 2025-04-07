<?php
header('Content-Type: application/json');
include 'db_connect.php';

$email = $_POST['email'] ?? '';
$code = $_POST['code'] ?? '';

// Verifica codice di sicurezza associato all'admin
$sql = "SELECT * FROM AMMINISTRATORE WHERE Email = ? AND Codice_Sicurezza = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $email, $code);
$stmt->execute();
$result = $stmt->get_result();

$response = ['success' => false];

if ($result->num_rows === 1) {
    $response['success'] = true;
}

echo json_encode($response);
$stmt->close();
$conn->close();
