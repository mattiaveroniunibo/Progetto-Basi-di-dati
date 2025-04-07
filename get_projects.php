<?php
include 'db_connect.php';

header("Content-Type: application/json; charset=UTF-8");

$sql = "
    SELECT 
        p.Nome, 
        p.Descrizione, 
        p.Data_Inserimento, 
        p.Stato, 
        p.Budget, 
        COALESCE(SUM(f.Importo), 0) AS FinanziamentiRicevuti,
        p.Data_Limite, 
        u.Nickname AS Creatore
    FROM PROGETTO p
    LEFT JOIN FINANZIAMENTO f ON p.Nome = f.Nome_Progetto
    JOIN CREATORE c ON p.Email_Creatore = c.Email
    JOIN UTENTE u ON c.Email = u.Email
    GROUP BY p.Nome, p.Descrizione, p.Data_Inserimento, p.Stato, p.Budget, p.Data_Limite, u.Nickname
    ORDER BY p.Data_Inserimento DESC
";

$result = $conn->query($sql);

$projects = [];
while ($row = $result->fetch_assoc()) {
    $projects[] = $row;
}

echo json_encode($projects);
$conn->close();
?>
