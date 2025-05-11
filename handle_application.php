<?php
// handle_application.php – pannello candidature per il creatore.
session_start();
require_once 'config.php';    // include $pdo

// Protezione: serve creatore loggato
if (!isset($_SESSION['email'])) {
    header('Location: login.php');
    exit;
}
// Verifica sia creatore
$chk = $pdo->prepare("SELECT 1 FROM CREATORE WHERE Email = :e");
$chk->execute([':e' => $_SESSION['email']]);
if (!$chk->fetchColumn()) {
    header('HTTP/1.1 403 Forbidden');
    echo 'Accesso riservato ai creatori.';
    exit;
}

include 'header.php';

$creatorEmail = $_SESSION['email'];
$errorMsg = '';

// Gestione POST (accept / reject)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id'], $_POST['action'])) {
    $id = (int)$_POST['id'];
    $esito = ($_POST['action'] === 'accept') ? 1 : 0;
    try {
        $stmt = $pdo->prepare('CALL AccettaCandidatura(:id, :esito)');
        $stmt->execute([':id' => $id, ':esito' => $esito]);
        header('Location: handle_application.php?msg=done');
        exit;
    } catch (PDOException $e) {
        $errorMsg = 'Errore DB: ' . $e->getMessage();
    }
}

// Query candidature pendenti per progetti del creatore
$sql = <<<SQL
SELECT c.ID, u.Nickname, p.Nome AS Progetto, pr.Nome AS Profilo
FROM CANDIDATURA c
JOIN UTENTE u ON u.Email = c.Email_Utente
JOIN PROFILO pr ON pr.ID = c.ID_Profilo
JOIN PROFILO_SOFTWARE ps ON ps.ID_Profilo = pr.ID
JOIN PROGETTO p ON p.Nome = ps.Nome_Progetto
WHERE p.Email_Creatore = :email AND c.Esito = 0
ORDER BY c.ID DESC
SQL;

$pendenti = $pdo->prepare($sql);
$pendenti->execute([':email' => $creatorEmail]);
$candidature = $pendenti->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="content-container">
    <h2>Candidature pendenti</h2>

    <?php if ($errorMsg): ?>
        <p class="error"><?= htmlspecialchars($errorMsg) ?></p>
    <?php elseif (isset($_GET['msg']) && $_GET['msg'] === 'done'): ?>
        <p class="success">Operazione completata!</p>
    <?php endif; ?>

    <?php if (empty($candidature)): ?>
        <p>Non ci sono candidature in attesa.</p>
    <?php else: ?>
        <table class="dash-table" style="width:100%; border-collapse:collapse; margin-top:1em;">
            <thead>
                <tr style="background:#333; color:#fff;">
                    <th style="padding:8px;">ID</th>
                    <th>Utente</th>
                    <th>Progetto</th>
                    <th>Profilo</th>
                    <th>Azione</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($candidature as $cand): ?>
                <tr>
                    <td style="padding:6px; border:1px solid #ccc;"><?= htmlspecialchars($cand['ID']) ?></td>
                    <td style="border:1px solid #ccc;"><?= htmlspecialchars($cand['Nickname']) ?></td>
                    <td style="border:1px solid #ccc;"><?= htmlspecialchars($cand['Progetto']) ?></td>
                    <td style="border:1px solid #ccc;"><?= htmlspecialchars($cand['Profilo']) ?></td>
                    <td style="border:1px solid #ccc; text-align:center;">
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="id" value="<?= $cand['ID'] ?>">
                            <button name="action" value="accept">Accetta</button>
                            <button name="action" value="reject">Rifiuta</button>
                        </form>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>

    <p style="margin-top:1em;"><a href="my_projects.php">&laquo; Torna alla Dashboard</a></p>
</div>

<?php include 'footer.php'; ?>
