<?php
/* Include la connessione mysqli esistente (per i vecchi script) */
require_once 'db_connect.php';

/* Credenziali DB – stesse di db_connect.php */
$host = 'localhost';
$user = 'root';
$password = 'root';
$dbname = 'BOSTARTER';

/* DSN PDO: porta omessa ⇒ usa 3306 di default */
$dsn = "mysql:host=$host;dbname=$dbname;charset=utf8mb4";

try {
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (PDOException $e) {
    die('Connessione PDO fallita: ' . $e->getMessage());
}

/* Directory di upload immagini */
define('UPLOAD_DIR', __DIR__ . '/uploads/');
?>
