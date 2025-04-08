<?php
require_once __DIR__ . '/vendor/autoload.php'; // Assicurati che il path sia corretto

use MongoDB\Client;

try {
    $client = new Client("mongodb://localhost:27017");
    $collection = $client->bostarter_logs->eventi;

    $logs = $collection->find([], ['sort' => ['timestamp' => -1]]);
} catch (Exception $e) {
    die(" Errore nella connessione a MongoDB: " . $e->getMessage());
}
?>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Log Eventi MongoDB</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <h2 class="mb-4"> Log Eventi - MongoDB</h2>
    <table class="table table-striped table-bordered">
        <thead class="table-dark">
            <tr>
                <th>Azione</th>
                <th>Email</th>
                <th>Data e Ora</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($logs as $log): ?>
            <tr>
                <td><?= htmlspecialchars($log['azione']) ?></td>
                <td><?= htmlspecialchars($log['email'] ?? '—') ?></td>
                <td><?= $log['timestamp']->toDateTime()->format('Y-m-d H:i:s') ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
</div>
</body>
</html>
