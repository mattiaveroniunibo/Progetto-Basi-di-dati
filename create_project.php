<?php
// create_project.php – pagina unica (form + processing)
session_start();
require_once 'config.php';    // include $pdo e costanti

// Protezione: serve creatore loggato
if (!isset($_SESSION['email'])) {
    header('Location: login.php');
    exit;
}
// Verifica sia creatore
$chk = $pdo->prepare("SELECT 1 FROM CREATORE WHERE Email = :e");
$chk->execute([':e'=>$_SESSION['email']]);
if (!$chk->fetchColumn()) {
    include 'header.php';
    echo "<p style='color:red;'>Accesso riservato ai creatori.</p>";
    include 'footer.php';
    exit;
}

$errors = [];
$success = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Sanitizzazione e validazione
    $nome        = trim($_POST['nome'] ?? '');
    $descrizione = trim($_POST['descrizione'] ?? '');
    $budget      = (float)($_POST['budget'] ?? 0);
    $deadline    = $_POST['data_limite'] ?? '';

    if ($nome === '' || strlen($nome) > 100) {
        $errors[] = 'Il titolo è obbligatorio (max 100 caratteri).';
    }
    if ($budget <= 0) {
        $errors[] = 'Budget non valido.';
    }
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $deadline) || strtotime($deadline) <= time()) {
        $errors[] = 'Data limite non valida o già trascorsa.';
    }

    // Upload immagini (max 3)
    $imagePaths = [];
    if (!empty($_FILES['immagini']['name'][0])) {
        $allowed = ['image/jpeg','image/png','image/webp'];
        for ($i = 0; $i < count($_FILES['immagini']['name']); $i++) {
            if ($_FILES['immagini']['error'][$i] === UPLOAD_ERR_OK) {
                if (!in_array($_FILES['immagini']['type'][$i], $allowed, true)) {
                    $errors[] = "{$_FILES['immagini']['name'][$i]}: formato non consentito.";
                    continue;
                }
                $ext = pathinfo($_FILES['immagini']['name'][$i], PATHINFO_EXTENSION);
                $safe = uniqid('img_', true) . ".{$ext}";
                $dest = UPLOAD_DIR . DIRECTORY_SEPARATOR . $safe;
                if (move_uploaded_file($_FILES['immagini']['tmp_name'][$i], $dest)) {
                    $imagePaths[] = $safe;
                } else {
                    $errors[] = "Impossibile caricare {$_FILES['immagini']['name'][$i]}.";
                }
            }
        }
    }

    if (empty($errors)) {
        try {
            $pdo->beginTransaction();
            // Inserimento progetto
            $sp = $pdo->prepare("CALL InserisciProgetto(:n, :d, CURDATE(), :b, :dl, 'aperto', :e)");
            $sp->execute([
                ':n'=>$nome,
                ':d'=>$descrizione,
                ':b'=>$budget,
                ':dl'=>$deadline,
                ':e'=>$_SESSION['email']
            ]);
            // Inserimento immagini
            if ($imagePaths) {
                $fstmt = $pdo->prepare("INSERT INTO FOTO (percorso, Nome_Progetto) VALUES (:p, :n)");
                foreach ($imagePaths as $p) {
                    $fstmt->execute([':p'=>$p, ':n'=>$nome]);
                }
            }
            $pdo->commit();
            $success = true;
        } catch (PDOException $e) {
            $pdo->rollBack();
            if ($e->errorInfo[1] == 1062) {
                $errors[] = 'Progetto già esistente.';
            } else {
                $errors[] = 'Errore DB: ' . $e->getMessage();
            }
        }
    }
}

include 'header.php';
?>

<div class="content-container">
    <h2>Crea nuovo progetto</h2>

    <?php if ($success): ?>
        <div class="alert alert-success">Progetto creato correttamente!</div>
        <p><a href="my_projects.php">Torna alla dashboard</a></p>
    <?php else: ?>
        <?php if ($errors): ?>
            <div class="alert alert-danger">
                <ul>
                    <?php foreach ($errors as $err): ?>
                        <li><?=htmlspecialchars($err)?></li>
                    <?php endforeach; ?>
                </ul>
            </div>
        <?php endif; ?>

        <form method="post" enctype="multipart/form-data">
            <label>Titolo*</label><br>
            <input type="text" name="nome" maxlength="100" required value="<?=htmlspecialchars($_POST['nome'] ?? '')?>"><br><br>

            <label>Descrizione*</label><br>
            <textarea name="descrizione" rows="5" required><?=htmlspecialchars($_POST['descrizione'] ?? '')?></textarea><br><br>

            <label>Budget (€)*</label><br>
            <input type="number" name="budget" step="0.01" min="1" required value="<?=htmlspecialchars($_POST['budget'] ?? '')?>"><br><br>

            <label>Data limite*</label><br>
            <input type="date" name="data_limite" required value="<?=htmlspecialchars($_POST['data_limite'] ?? '')?>"><br><br>

            <label>Immagini (max 3 jpg/png/webp)</label><br>
            <input type="file" name="immagini[]" accept="image/jpeg,image/png,image/webp" multiple><br><br>

            <button type="submit">Crea progetto</button>
        </form>
    <?php endif; ?>
</div>

<?php include 'footer.php'; ?>
