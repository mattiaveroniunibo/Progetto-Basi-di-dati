<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

session_start();
require_once 'config.php';   // $pdo e UPLOAD_DIR disponibili

/* ------------------------------------------------------------------
 * 1.  SE LA RICHIESTA È GET  →  MOSTRA IL FORM
 * ------------------------------------------------------------------*/
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="utf-8">
    <title>Login</title>
</head>
<body>
<h2>Accedi</h2>

<form method="post" action="login.php">
    <label>Email:
        <input type="email" name="email" required>
    </label><br><br>

    <label>Password:
        <input type="password" name="password" required>
    </label><br><br>

    <label>Admin?
        <input type="checkbox" name="is_admin" id="is_admin"
               onchange="document.getElementById('sec').style.display=this.checked?'inline':'none'">
    </label><br><br>

    <span id="sec" style="display:none">
        <label>Security Code:
            <input type="text" name="security_code">
        </label><br><br>
    </span>

    <button type="submit">Login</button>
</form>
</body>
</html>
<?php
    exit;     // evita di eseguire la parte JSON
}

/* ------------------------------------------------------------------
 * 2.  SE LA RICHIESTA È POST  →  AUTENTICAZIONE E RISPOSTA JSON
 * ------------------------------------------------------------------*/
header('Content-Type: application/json; charset=utf-8');

$email     = $_POST['email']        ?? '';
$password  = $_POST['password']     ?? '';
$is_admin  = isset($_POST['is_admin']);
$code      = $_POST['security_code'] ?? '';

$success = false;
$message = '';

try {
    if ($is_admin) {
        $stmt = $pdo->prepare("CALL LoginAmministratore(:e, :p, :c)");
        $stmt->execute([':e'=>$email, ':p'=>$password, ':c'=>$code]);
    } else {
        $stmt = $pdo->prepare("CALL AutenticaUtente(:e, :p)");
        $stmt->execute([':e'=>$email, ':p'=>$password]);
    }

    $row = $stmt->fetch();          // FETCH_ASSOC di default

    if ($row && isset($row['Messaggio'])) {
        $message = $row['Messaggio'];
        $success = str_contains($message, 'riuscit');
        if ($success) {
            $_SESSION['email'] = $email;   // login riuscito
        }
    } else {
        $message = 'Login fallito';
    }

    $stmt->closeCursor();           // libera il resultset
} catch (PDOException $ex) {
    $message = 'Errore esecuzione login: ' . $ex->getMessage();
}

/* ... blocco try ... */

$creatorFlag = '0';                         // valore di default
if ($success) {                             // ← sposta la query qui
    $creatorQ = $pdo->prepare(
        "SELECT 1 FROM CREATORE WHERE Email = :e LIMIT 1"
    );
    $creatorQ->execute([':e'=>$email]);
    $creatorFlag = $creatorQ->fetchColumn() ? '1' : '0';
}

echo json_encode([
    'success' => $success,
    'message' => $message,
    'email'   => $email,
    'admin'   => $is_admin ? '1' : '0',
    'creator' => $creatorFlag         // ora è sicuro
]);

?>
