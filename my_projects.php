<?php
// my_projects.php – Dashboard Creatore “stand-alone”
session_start();
require_once 'config.php';        // include $pdo
// se non sei loggato → vai al login
if (!isset($_SESSION['email'])) {
    header('Location: login.php');
    exit;
}
// header.php facoltativo: se lo usi, includilo qui. Altrimenti la navbar:
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="utf-8">
    <title>Dashboard Creatore – BOSTARTER</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<nav class="navbar">
  <div class="logo">BOSTARTER</div>
  <ul class="nav-links">
    <li><a href="index.html">Home</a></li>
    <li><a href="index.html#progetti">Progetti</a></li>
    <li><a href="index.html#statistiche">Statistiche</a></li>
    <li><a href="my_projects.php">Dashboard</a></li>
    <li><a href="index.html#profilo">Profilo</a></li>
    <li><a href="logout.php">Logout</a></li>
  </ul>
</nav>

<div class="content-container">

    <h2>I miei progetti</h2>

    <?php
    // verifico che l'utente sia creatore
    $chk = $pdo->prepare("SELECT 1 FROM CREATORE WHERE Email = :e");
    $chk->execute([':e'=>$_SESSION['email']]);
    if (!$chk->fetchColumn()) {
        echo "<p style='color:red;'>Accesso riservato ai creatori.</p>";
        echo "</div></body></html>";
        exit;
    }

    // estraggo i progetti
    $stmt = $pdo->prepare(
        "SELECT p.Nome,p.Stato,p.Budget,
                COALESCE(SUM(f.Importo),0) AS Raccolto,
                DATEDIFF(p.Data_Limite,CURDATE()) AS GiorniResidui
         FROM PROGETTO p
         LEFT JOIN FINANZIAMENTO f ON f.Nome_Progetto = p.Nome
         WHERE p.Email_Creatore = :e
         GROUP BY p.Nome,p.Stato,p.Budget,p.Data_Limite
         ORDER BY p.Data_Inserimento DESC"
    );
    $stmt->execute([':e'=>$_SESSION['email']]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    ?>

    <table class="dash-table" style="width:100%; border-collapse:collapse; margin-top:1em;">
        <tr style="background:#333; color:#fff;">
            <th style="padding:8px">Nome</th>
            <th>Stato</th>
            <th>Budget (€)</th>
            <th>Raccolto (€)</th>
            <th>Giorni residui</th>
            <th>Azioni</th>
        </tr>

        <?php if (count($rows)): foreach ($rows as $r): ?>
        <tr>
            <td style="padding:6px; border:1px solid #ccc;"><?=htmlspecialchars($r['Nome'])?></td>
            <td style="border:1px solid #ccc;"><?=htmlspecialchars($r['Stato'])?></td>
            <td style="border:1px solid #ccc; text-align:right;"><?=number_format($r['Budget'],2,',','.')?></td>
            <td style="border:1px solid #ccc; text-align:right;"><?=number_format($r['Raccolto'],2,',','.')?></td>
            <td style="border:1px solid #ccc; text-align:center;"><?=htmlspecialchars($r['GiorniResidui'])?></td>
            <td style="border:1px solid #ccc; text-align:center;">
                <a href="add_reward.php?proj=<?=urlencode($r['Nome'])?>">Reward</a> |
                <a href="define_profile.php?proj=<?=urlencode($r['Nome'])?>">Profili</a> |
                <a href="handle_application.php?proj=<?=urlencode($r['Nome'])?>">Candidature</a> |
                <a href="reply_comment.php?proj=<?=urlencode($r['Nome'])?>">Commenti</a>
            </td>
        </tr>
        <?php endforeach; else: ?>
        <tr>
            <td colspan="6" style="padding:12px; text-align:center; color:#666;">
                Nessun progetto creato.
            </td>
        </tr>
        <?php endif; ?>
    </table>

    <p style="margin:1.5em 0;">
        <a href="create_project.php" style="display:inline-block;
           padding:8px 12px; background:#28a745; color:#fff;
           text-decoration:none; border-radius:4px;">
            ➕ Crea nuovo progetto
        </a>
    </p>

</div>
</body>
</html>
