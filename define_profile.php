<?php
// define_profile.php – il creatore definisce/associa profili software e skill richieste.
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

$creatorEmail = $_SESSION['email'];
$errors = [];
$success = false;

// Gestione POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $projectName    = trim($_POST['project'] ?? '');
    $existingId     = intval($_POST['existing_profile'] ?? 0);
    $newProfile     = trim($_POST['new_profile'] ?? '');
    $skills         = $_POST['skill']  ?? [];
    $levels         = $_POST['level']  ?? [];

    // Validazioni base
    if ($projectName === '') {
        $errors[] = 'Seleziona un progetto.';
    }
    if ($existingId === 0 && $newProfile === '') {
        $errors[] = 'Inserisci il nome del nuovo profilo o scegline uno esistente.';
    }

    // Verifica appartenenza progetto
    if ($projectName !== '') {
        $stmt = $pdo->prepare(
            "SELECT COUNT(*) 
             FROM SOFTWARE s 
             JOIN PROGETTO p ON p.Nome = s.Nome 
             WHERE s.Nome = ? AND p.Email_Creatore = ?"
        );
        $stmt->execute([$projectName, $creatorEmail]);
        if (!$stmt->fetchColumn()) {
            $errors[] = 'Progetto non valido o non di tua proprietà.';
        }
    }

    // Validazione skill-livello
    $validSkillPairs = [];
    foreach ($skills as $idx => $comp) {
        $comp = trim($comp);
        $lvl  = intval($levels[$idx] ?? -1);
        if ($comp === '' && $lvl === -1) {
            continue;
        }
        if ($comp === '' || $lvl < 0 || $lvl > 5) {
            $errors[] = 'Voce skill/livello non valida alla riga ' . ($idx + 1);
        } else {
            $validSkillPairs[] = [$comp, $lvl];
        }
    }

    if (empty($errors)) {
        try {
            $pdo->beginTransaction();

            // Determina ID e nome profilo
            if ($existingId > 0) {
                $profileIdStmt = $pdo->prepare("SELECT Nome FROM PROFILO WHERE ID = ?");
                $profileIdStmt->execute([$existingId]);
                $profileName = $profileIdStmt->fetchColumn();
                if (!$profileName) {
                    throw new Exception('Profilo scelto inesistente.');
                }
                $profileId = $existingId;
            } else {
                $insProf = $pdo->prepare('INSERT INTO PROFILO (Nome) VALUES (?)');
                $insProf->execute([$newProfile]);
                $profileId   = $pdo->lastInsertId();
                $profileName = $newProfile;
            }

            // Associa profilo al progetto
            $call = $pdo->prepare(
                'CALL InserisciProfiloRichiesto(:id, :nome, :proj)'
            );
            $call->execute([
                ':id'   => $profileId,
                ':nome' => $profileName,
                ':proj' => $projectName,
            ]);
            $call->closeCursor();

            // Inserisci/aggiorna skill richieste
            if ($validSkillPairs) {
                $insSkill = $pdo->prepare(
                    'INSERT INTO SKILL_RICHIESTA (ID_Profilo, Competenza, Livello) VALUES (?, ?, ?) 
                     ON DUPLICATE KEY UPDATE Livello = VALUES(Livello)'
                );
                foreach ($validSkillPairs as $pair) {
                    $insSkill->execute([$profileId, $pair[0], $pair[1]]);
                }
            }

            $pdo->commit();
            $success = true;
        } catch (Exception $e) {
            $pdo->rollBack();
            $errors[] = 'Errore: ' . $e->getMessage();
        }
    }
}

// Query progetti software del creatore
$projStmt = $pdo->prepare(
    "SELECT s.Nome 
     FROM SOFTWARE s 
     JOIN PROGETTO p ON p.Nome = s.Nome 
     WHERE p.Email_Creatore = ?");
$projStmt->execute([$creatorEmail]);
$projectRows = $projStmt->fetchAll(PDO::FETCH_COLUMN);

// Query profili esistenti
$profiles = $pdo->query('SELECT ID, Nome FROM PROFILO ORDER BY Nome')->fetchAll(PDO::FETCH_ASSOC);

include 'header.php';
?>
<div class="content-container">
    <h2>Definisci profili richiesti</h2>

    <?php if ($errors): ?>
        <div class="error">
            <ul>
                <?php foreach ($errors as $e): ?>
                    <li><?= htmlspecialchars($e) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    <?php elseif ($success): ?>
        <div class="success">Profilo salvato con successo.</div>
    <?php endif; ?>

    <form method="post">
        <label>Progetto software:<br>
            <select name="project" required>
                <option value="">-- seleziona --</option>
                <?php foreach ($projectRows as $p): ?>
                    <option value="<?= htmlspecialchars($p) ?>" <?= (isset($projectName) && $projectName === $p) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($p) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </label><br><br>

        <label>Profilo esistente:<br>
            <select name="existing_profile">
                <option value="0">-- nuovo profilo --</option>
                <?php foreach ($profiles as $pr): ?>
                    <option value="<?= $pr['ID'] ?>" <?= (isset($existingId) && $existingId == $pr['ID']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($pr['Nome']) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </label><br><br>

        <label>... o nuovo profilo:<br>
            <input type="text" name="new_profile" value="<?= htmlspecialchars($newProfile ?? '') ?>">
        </label><br><br>

        <fieldset>
            <legend>Skill richieste (competenza + livello)</legend>
            <div id="skills">
                <!-- righe dinamiche -->
            </div>
            <button type="button" onclick="addSkillRow()">Aggiungi skill</button>
        </fieldset><br>

        <button type="submit">Salva profilo</button>
    </form>
</div>
<?php include 'footer.php'; ?>
