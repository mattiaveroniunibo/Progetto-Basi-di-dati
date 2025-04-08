<?php
require_once __DIR__ . '/vendor/autoload.php'; 

function logEvento($azione, $emailUtente = null) {
    try {
        $client = new MongoDB\Client("mongodb://localhost:27017");
        $db = $client->bostarter_logs;
        $collection = $db->eventi;

        $documento = [
            "azione" => $azione,
            "email" => $emailUtente,
            "timestamp" => new MongoDB\BSON\UTCDateTime()
        ];

        $collection->insertOne($documento);
    } catch (Exception $e) {
        error_log("Errore log MongoDB: " . $e->getMessage());
    }
}
?>
