<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include("db_connect.php");

// Query per la tabella DebugProgetti
$sql = "SELECT * FROM DebugProgetti";
$result = $conn->query($sql);

// Query per le candidature
$sql_candidature = "
SELECT 
    u.Nickname AS Utente,
    pr.Nome AS Profilo,
    ps.Nome_Progetto AS Progetto,
    c.Esito
FROM CANDIDATURA c
JOIN UTENTE u ON c.Email_Utente = u.Email
JOIN PROFILO pr ON c.ID_Profilo = pr.ID
JOIN PROFILO_SOFTWARE ps ON ps.ID_Profilo = pr.ID
ORDER BY c.ID DESC
";
$result_candidature = $conn->query($sql_candidature);

// Statistiche: Top creatori e finanziatori
$result_affidabili = $conn->query("SELECT * FROM classifica_affidabilita");
$result_finanziatori = $conn->query("SELECT * FROM ClassificaFinanziatori");
$result_quasi_completati = $conn->query("SELECT * FROM ProgettiQuasiCompletati");

$sql_skills = "
SELECT u.Nickname, sc.Competenza, sc.Livello
FROM SKILL_CURRICULUM sc
JOIN UTENTE u ON u.Email = sc.Email_Utente
ORDER BY u.Nickname, sc.Competenza
";
$result_skills = $conn->query($sql_skills);

$sql_commenti = "
SELECT c.ID, u.Nickname AS Utente, p.Nome AS Progetto, c.Testo AS Commento, r.Testo AS Risposta
FROM COMMENTO c
JOIN UTENTE u ON u.Email = c.Email_Utente
JOIN PROGETTO p ON p.Nome = c.Nome_Progetto
LEFT JOIN RISPOSTA r ON r.ID_Commento = c.ID
ORDER BY c.ID DESC
";
$result_commenti = $conn->query($sql_commenti);

?>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Debug Progetti</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <h2 class="mb-4">🧪 Pannello Debug: Stato Progetti & Affidabilità</h2>

    <?php if ($result && $result->num_rows > 0): ?>
        <table class="table table-bordered table-striped">
            <thead class="table-dark">
                <tr>
                    <th>Progetto</th>
                    <th>Creatore</th>
                    <th>Stato</th>
                    <th>Budget (€)</th>
                    <th>Totale Finanziato (€)</th>
                    <th>Giorni Residui</th>
                    <th># Progetti</th>
                    <th>Affidabilità</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result->fetch_assoc()): ?>
                <tr>
                    <td><?= htmlspecialchars($row['Progetto']) ?></td>
                    <td><?= htmlspecialchars($row['Creatore']) ?></td>
                    <td><?= $row['Stato'] === 'aperto' ? '🟢 Aperto' : '🔴 Chiuso' ?></td>
                    <td><?= number_format($row['Budget'], 2, ',', '.') ?> €</td>
                    <td><?= number_format($row['TotaleFinanziato'], 2, ',', '.') ?> €</td>
                    <td><?= $row['GiorniResidui'] ?></td>
                    <td><?= $row['Nr_Progetti'] ?></td>
                    <td><?= number_format($row['Affidabilita'] * 100, 2, ',', '.') ?>%</td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="alert alert-warning">Nessun dato trovato nella view DebugProgetti.</div>
    <?php endif; ?>

    <hr class="my-5">

    <h3 class="mb-3">👤 Candidature a Profili Richiesti</h3>

    <?php if ($result_candidature && $result_candidature->num_rows > 0): ?>
        <table class="table table-hover table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Utente</th>
                    <th>Profilo</th>
                    <th>Progetto</th>
                    <th>Esito</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result_candidature->fetch_assoc()): ?>
                    <tr>
                        <td><?= htmlspecialchars($row['Utente']) ?></td>
                        <td><?= htmlspecialchars($row['Profilo']) ?></td>
                        <td><?= htmlspecialchars($row['Progetto']) ?></td>
                        <td><?= $row['Esito'] ? '✅ Accettata' : '⏳ In attesa' ?></td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="alert alert-secondary">Nessuna candidatura trovata.</div>
    <?php endif; ?>

    <hr class="my-5">

    <h3>🏆 Classifica Affidabilità Creatori</h3>
    <?php if ($result_affidabili && $result_affidabili->num_rows > 0): ?>
        <table class="table table-sm table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Nickname</th>
                    <th>Affidabilità</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result_affidabili->fetch_assoc()): ?>
                    <tr>
                        <td><?= htmlspecialchars($row['Nickname']) ?></td>
                        <td><?= number_format($row['affidabilita'] * 100, 2, ',', '.') ?>%</td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="alert alert-secondary">Nessun dato disponibile per la classifica affidabilità.</div>
    <?php endif; ?>

    <h3 class="mt-5">💰 Classifica Top Finanziatori</h3>
    <?php if ($result_finanziatori && $result_finanziatori->num_rows > 0): ?>
        <table class="table table-sm table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Nickname</th>
                    <th>Totale Finanziato (€)</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result_finanziatori->fetch_assoc()): ?>
                    <tr>
                        <td><?= htmlspecialchars($row['Nickname']) ?></td>
                        <td><?= number_format($row['Totale'], 2, ',', '.') ?> €</td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="alert alert-secondary">Nessun finanziatore presente.</div>
    <?php endif; ?>

    <h3 class="mt-5">📈 Progetti Quasi Completati</h3>
    <?php if ($result_quasi_completati && $result_quasi_completati->num_rows > 0): ?>
        <table class="table table-sm table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Progetto</th>
                    <th>Descrizione</th>
                    <th>Residuo (€)</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result_quasi_completati->fetch_assoc()): ?>
                    <tr>
                        <td><?= htmlspecialchars($row['Nome']) ?></td>
                        <td><?= htmlspecialchars($row['Descrizione']) ?></td>
                        <td><?= number_format($row['DifferenzaResidua'], 2, ',', '.') ?> €</td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="alert alert-secondary">Nessun progetto quasi completato.</div>
    <?php endif; ?>

    <hr class="my-5">
    <h3 class="mb-3">🧠 Skill Curriculum Utenti</h3>
    <?php if ($result_skills && $result_skills->num_rows > 0): ?>
        <table class="table table-sm table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Nickname</th>
                    <th>Competenza</th>
                    <th>Livello</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result_skills->fetch_assoc()): ?>
                    <tr>
                        <td><?= htmlspecialchars($row['Nickname']) ?></td>
                        <td><?= htmlspecialchars($row['Competenza']) ?></td>
                        <td><?= $row['Livello'] ?>/5</td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="alert alert-secondary">Nessuna skill trovata nei curriculum.</div>
    <?php endif; ?>

    <hr class="my-5">
    <h3 class="mb-3">💬 Commenti & Risposte dei Progetti</h3>
    <?php if ($result_commenti && $result_commenti->num_rows > 0): ?>
        <table class="table table-sm table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Utente</th>
                    <th>Progetto</th>
                    <th>Commento</th>
                    <th>Risposta del Creatore</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result_commenti->fetch_assoc()): ?>
                    <tr>
                        <td><?= htmlspecialchars($row['Utente']) ?></td>
                        <td><?= htmlspecialchars($row['Progetto']) ?></td>
                        <td><?= htmlspecialchars($row['Commento']) ?></td>
                        <td><?= $row['Risposta'] ? htmlspecialchars($row['Risposta']) : '<em>Nessuna risposta</em>' ?></td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    <?php else: ?>
        <div class="alert alert-secondary">Nessun commento presente.</div>
    <?php endif; ?>

</div>
</body>
</html>