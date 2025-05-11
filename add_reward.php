<?php
// add_reward.php – il creatore associa una nuova ricompensa a un suo progetto.
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

// 1. Recupera i progetti dell'utente per la <select>
$creatorEmail = $_SESSION['email'];
$stmt = $pdo->prepare(
    'SELECT Nome 
     FROM PROGETTO 
     WHERE Email_Creatore = :email 
     ORDER BY Data_Inserimento DESC'
);
$stmt->execute(['email' => $creatorEmail]);
$ownProjects = $stmt->fetchAll(PDO::FETCH_COLUMN);

// 2. Se POST: validazione + inserimento
$errors = [];
$success = false;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $codice       = trim($_POST['codice'] ?? '');
    $descrizione  = trim($_POST['descrizione'] ?? '');
    $nomeProgetto = trim($_POST['nome_progetto'] ?? '');

    // Validazioni base
    if ($codice === '') {
        $errors[] = 'Codice reward obbligatorio.';
    }
    if ($descrizione === '') {
        $errors[] = 'Descrizione obbligatoria.';
    }
    if ($nomeProgetto === '' || !in_array($nomeProgetto, $ownProjects, true)) {
        $errors[] = 'Progetto non valido.';
    }

    if (empty($errors)) {
        try {
            $pdo->beginTransaction();
            $call = $pdo->prepare(
                'CALL InserisciReward(:codice, :descrizione, NULL, :nomeProj)'
            );
            $call->execute([
                ':codice'      => $codice,
                ':descrizione' => $descrizione,
                ':nomeProj'    => $nomeProgetto,
            ]);
            $pdo->commit();
            $success = true;
        } catch (PDOException $e) {
            $pdo->rollBack();
            // Duplicate entry o altro errore
            if ((int)$e->getCode() === 23000) {
                $errors[] = 'Codice reward già esistente.';
            } else {
                $errors[] = 'Errore DB: ' . $e->getMessage();
            }
        }
    }
}
?>

<div class="content-container">
    <h2>Aggiungi Reward a <?= htmlspecialchars($nomeProgetto ?? '') ?></h2>

    <?php if ($success): ?>
        <p class="success">Reward aggiunto con successo!</p>
        <p><a href="my_projects.php">← Torna alla Dashboard</a></p>
    <?php else: ?>
        <?php if ($errors): ?>
            <div class="error">
                <ul>
                    <?php foreach ($errors as $e): ?>
                        <li><?= htmlspecialchars($e) ?></li>
                    <?php endforeach; ?>
                </ul>
            </div>
        <?php endif; ?>

        <form action="add_reward.php" method="post">
            <label for="nome_progetto">Progetto:</label><br>
            <select name="nome_progetto" id="nome_progetto" required>
                <option value="">-- seleziona --</option>
                <?php foreach ($ownProjects as $p): ?>
                    <option value="<?= htmlspecialchars($p) ?>"
                        <?= (isset($nomeProgetto) && $nomeProgetto === $p) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($p) ?>
                    </option>
                <?php endforeach; ?>
            </select><br><br>

            <label for="codice">Codice Reward:</label><br>
            <input type="text" name="codice" id="codice" maxlength="100"
                   value="<?= htmlspecialchars($codice ?? '') ?>" required><br><br>

            <label for="descrizione">Descrizione:</label><br>
            <textarea name="descrizione" id="descrizione" rows="4" required><?= htmlspecialchars($descrizione ?? '') ?></textarea><br><br>

            <button type="submit">Salva Reward</button>
        </form>
    <?php endif; ?>
</div>

<?php include 'footer.php'; ?>
