<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require 'vendor/autoload.php';
use MongoDB\Client;

$client = new Client("mongodb://localhost:27017");
$collection = $client->bostarter->log_eventi;

$collection->insertOne([
    'messaggio' => '✅ Log test da PHP riuscito!',
    'data' => new MongoDB\BSON\UTCDateTime()
]);

echo "✅ Log inserito con successo!";
