<?php
require 'vendor/autoload.php';
use MongoDB\Client;

try {
    $mongo = new Client("mongodb://localhost:27017");
    $collection = $mongo->bostarter_logs->eventi;  // ← uguali al logger

    $log = $collection->find([], ['sort' => ['timestamp' => -1]]);
    $eventi = [];

    foreach ($log as $evento) {
        $eventi[] = [
            "azione" => $evento['azione'],
            "email" => $evento['email'] ?? "—",
            "data_ora" => method_exists($evento['timestamp'], 'toDateTime')
                ? $evento['timestamp']->toDateTime()->format('Y-m-d H:i:s')
                : (string) $evento['timestamp']
        ];
    }

    if (!empty($eventi)) {
        file_put_contents('log_evento.json', json_encode($eventi, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        echo "✅ Log esportati con successo in log_evento.json";
    } else {
        echo "⚠️ Nessun evento trovato nella collezione.";
    }
} catch (Exception $e) {
    echo "❌ Errore: " . $e->getMessage();
}
