<?php
include 'db_connect.php';

// Query 1: Top 3 creatori per affidabilità
$query1 = "SELECT u.Nickname, c.Affidabilita 
           FROM CREATORE c
           JOIN UTENTE u ON c.Email = u.Email
           ORDER BY c.Affidabilita DESC
           LIMIT 3";
$result1 = $conn->query($query1);
$top_creatori = [];
while ($row = $result1->fetch_assoc()) {
    $top_creatori[] = $row;
}

// Query 2: Progetti più vicini al completamento
$query2 = "SELECT p.Nome, p.Budget, COALESCE(SUM(f.Importo), 0) AS FinanziamentiRicevuti 
           FROM PROGETTO p
           LEFT JOIN FINANZIAMENTO f ON p.Nome = f.Nome_Progetto
           WHERE p.Stato = 'aperto'
           GROUP BY p.Nome, p.Budget
           ORDER BY (p.Budget - COALESCE(SUM(f.Importo), 0)) ASC
           LIMIT 3";
$result2 = $conn->query($query2);
$top_progetti = [];
while ($row = $result2->fetch_assoc()) {
    $top_progetti[] = $row;
}

// Query 3: Utenti con più finanziamenti erogati
$query3 = "SELECT u.Nickname, COALESCE(SUM(f.Importo), 0) AS TotaleFinanziato 
           FROM FINANZIAMENTO f
           JOIN UTENTE u ON f.Email_Utente = u.Email
           GROUP BY u.Nickname
           ORDER BY TotaleFinanziato DESC
           LIMIT 3";
$result3 = $conn->query($query3);
$top_finanziatori = [];
while ($row = $result3->fetch_assoc()) {
    $top_finanziatori[] = $row;
}

// Risposta JSON
$response = [
    "top_creatori" => $top_creatori,
    "top_progetti" => $top_progetti,
    "top_finanziatori" => $top_finanziatori
];

echo json_encode($response);
$conn->close();
?>
