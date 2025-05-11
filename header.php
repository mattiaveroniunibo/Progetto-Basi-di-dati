<?php
// header.php – navbar comune per tutte le pagine
session_start();
require_once 'config.php';  // assicura $pdo disponibile per il check

$isLogged  = isset($_SESSION['email']);
$isCreator = false;

if ($isLogged) {
    // verifica se l'utente è creatore
    $chk = $pdo->prepare("SELECT 1 FROM CREATORE WHERE Email = :e");
    $chk->execute([':e' => $_SESSION['email']]);
    $isCreator = (bool)$chk->fetchColumn();
}
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>BOSTARTER</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<nav class="navbar">
    <div class="logo"><a href="index.php">BOSTARTER</a></div>
    <ul class="nav-links" id="navLinks">
        <li><a href="#" onclick="loadPage('home')">Home</a></li>
        <li><a href="#" onclick="loadPage('progetti')">Progetti</a></li>
        <li><a href="#" onclick="loadPage('statistiche')">Statistiche</a></li>
        <?php if ($isCreator): ?>
            <li><a href="my_projects.php">Dashboard</a></li>
        <?php endif; ?>
        <li><a href="#" onclick="loadPage('profilo')">Profilo</a></li>
        <?php if ($isLogged): ?>
            <li><a href="logout.php">Logout</a></li>
        <?php else: ?>
            <li><a href="#" onclick="loadPage('login')">Accedi</a></li>
        <?php endif; ?>
    </ul>
</nav>
<div class="content-container">
