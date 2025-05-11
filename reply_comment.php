<?php
// reply_comment.php – il creatore risponde ai commenti sui propri progetti.
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

// POST: salva la risposta
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id'], $_POST['reply'])) {
    $idCommento = (int) $_POST['id'];
    $reply      = trim($_POST['reply']);
    if ($reply === '') {
        $errorMsg = 'Testo risposta obbligatorio.';
    } else {
        try {
            $pdo->beginTransaction();
            // Verifica ownership e che non sia già risposto
            $check = $pdo->prepare(
                "SELECT p.Email_Creatore
                 FROM COMMENTO c
                 JOIN PROGETTO p ON p.Nome = c.Nome_Progetto
                 LEFT JOIN RISPOSTA r ON r.ID_Commento = c.ID
                 WHERE c.ID = :id
                   AND p.Email_Creatore = :email
                   AND r.ID_Commento IS NULL
                 FOR UPDATE"
            );
            $check->execute([':id' => $idCommento, ':email' => $creatorEmail]);
            if (!$check->fetch()) {
                throw new Exception('Commento non valido o già risposto.');
            }
            // Inserisci risposta
            $stmt = $pdo->prepare("CALL InserisciRisposta(:idc, :emailc, :testo)");
            $stmt->execute([
                ':idc'    => $idCommento,
                ':emailc' => $creatorEmail,
                ':testo'  => $reply
            ]);
            $pdo->commit();
            header('Location: reply_comment.php?msg=ok');
            exit;
        } catch (Exception $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            $errorMsg = 'Errore: ' . $e->getMessage();
        }
    }
}

// Contenuto HTML
?>
<div class="content-container">
    <h2>Risposta ai commenti</h2>

    <?php if ($errorMsg): ?>
        <p class="error"><?= htmlspecialchars($errorMsg) ?></p>
    <?php elseif (isset($_GET['msg']) && $_GET['msg'] === 'ok'): ?>
        <p class="success">Risposta inviata con successo!</p>
    <?php endif; ?>

    <?php if (isset($_GET['id'])):
        $id = (int) $_GET['id'];
        $stmt = $pdo->prepare(
            "SELECT c.ID, c.Nome_Progetto, c.Testo
             FROM COMMENTO c
             JOIN PROGETTO p ON p.Nome = c.Nome_Progetto AND p.Email_Creatore = :email
             LEFT JOIN RISPOSTA r ON r.ID_Commento = c.ID
             WHERE c.ID = :id AND r.ID_Commento IS NULL"
        );
        $stmt->execute([':email' => $creatorEmail, ':id' => $id]);
        $comment = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$comment): ?>
            <p>Commento non valido o già risposto.</p>
        <?php else: ?>
            <h3>Progetto: <?= htmlspecialchars($comment['Nome_Progetto']) ?></h3>
            <blockquote><?= nl2br(htmlspecialchars($comment['Testo'])) ?></blockquote>
            <form method="post">
                <input type="hidden" name="id" value="<?= $comment['ID'] ?>">
                <textarea name="reply" rows="4" required></textarea><br>
                <button type="submit">Invia risposta</button>
            </form>
        <?php endif;
    else:
        $stmt = $pdo->prepare(
            "SELECT c.ID, c.Nome_Progetto, c.Testo, u.Nickname, c.Data
             FROM COMMENTO c
             JOIN PROGETTO p ON p.Nome = c.Nome_Progetto AND p.Email_Creatore = :email
             JOIN UTENTE u ON u.Email = c.Email_Utente
             LEFT JOIN RISPOSTA r ON r.ID_Commento = c.ID
             WHERE r.ID_Commento IS NULL
             ORDER BY c.Data DESC"
        );
        $stmt->execute([':email' => $creatorEmail]);
        $comments = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (empty($comments)): ?>
            <p>Nessun commento da rispondere.</p>
        <?php else: ?>
            <ul>
                <?php foreach ($comments as $c): ?>
                    <li>
                        <strong><?= htmlspecialchars($c['Nome_Progetto']) ?></strong> —
                        <em><?= htmlspecialchars($c['Nickname']) ?> (<?= htmlspecialchars($c['Data']) ?>)</em><br>
                        <?= nl2br(htmlspecialchars($c['Testo'])) ?><br>
                        <a href="reply_comment.php?id=<?= $c['ID'] ?>">Rispondi</a>
                    </li>
                <?php endforeach; ?>
            </ul>
        <?php endif;
    endif; ?>

    <p><a href="my_projects.php">&laquo; Torna alla dashboard</a></p>
</div>
<?php include 'footer.php'; ?>
