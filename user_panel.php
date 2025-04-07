<?php
// ===== user_panel.php =====
session_start();
if (!isset($_SESSION['email'])) {
    header('Location: login.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Benvenuto Utente</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <h2 class="mb-4">👋 Benvenuto, <?= htmlspecialchars($_SESSION['email']) ?></h2>
    <p>Hai effettuato l'accesso come utente normale.</p>
    <a href="logout.php" class="btn btn-danger">Logout</a>
</div>
</body>
</html>

<?php
// ===== logout.php =====
session_start();
session_destroy();
header("Location: login.php");
exit;
?>
