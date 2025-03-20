<?php
session_start();
session_destroy(); // Distrugge la sessione
echo json_encode(["success" => true, "message" => "Logout effettuato"]);
?>
