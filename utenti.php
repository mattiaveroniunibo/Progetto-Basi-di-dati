<?php
$servername = "localhost";
$username = "root"; // Username di MySQL
$password = "root"; // Password di MySQL
$database = "botstarter"; // Nome del database

// Connessione al database
$conn = new mysqli($servername, $username, $password, $database);

// Controllo della connessione
if ($conn->connect_error) {
    die("Connessione fallita: " . $conn->connect_error);
}

// Query per prendere gli utenti
$sql = "SELECT * FROM UTENTE";
$result = $conn->query($sql);

// Stampiamo gli utenti in una tabella HTML
echo "<h2>Elenco Utenti</h2>";
echo "<table border='1'>
        <tr>
            <th>Email</th>
            <th>Nickname</th>
            <th>Nome</th>
            <th>Cognome</th>
        </tr>";

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "<tr>
                <td>" . $row["Email"] . "</td>
                <td>" . $row["Nickname"] . "</td>
                <td>" . $row["Nome"] . "</td>
                <td>" . $row["Cognome"] . "</td>
              </tr>";
    }
} else {
    echo "<tr><td colspan='4'>Nessun utente trovato</td></tr>";
}

echo "</table>";

// Chiudiamo la connessione
$conn->close();
?>
