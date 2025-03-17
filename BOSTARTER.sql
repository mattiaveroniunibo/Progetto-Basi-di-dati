-- Eliminazione e Creazione del Database
DROP DATABASE IF EXISTS BOSTARTER;
CREATE DATABASE IF NOT EXISTS BOSTARTER;
USE BOSTARTER;

-- Creazione della tabella UTENTE
CREATE TABLE UTENTE(
    Email VARCHAR(100) PRIMARY KEY,
    Nickname VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    Anno_Di_Nascita DATE NOT NULL,
    Luogo_Di_Nascita VARCHAR(100) NOT NULL
);

-- Creazione della tabella SKILL
CREATE TABLE SKILL(
    COMPETENZA VARCHAR(100),
    LIVELLO INT CHECK (LIVELLO BETWEEN 0 AND 5),
    PRIMARY KEY (COMPETENZA, LIVELLO)
);

-- Creazione della tabella SKILL_Curriculum
CREATE TABLE SKILL_CURRICULUM(
    Email_Utente VARCHAR(100),
    Competenza VARCHAR(100),
    Livello INT,
    PRIMARY KEY (Email_Utente, Competenza, Livello),
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email) ON DELETE CASCADE,
    FOREIGN KEY (Competenza, Livello) REFERENCES SKILL(Competenza, LIVELLO) ON DELETE CASCADE
);

-- Creazione della tabella AMMINISTRATORE
CREATE TABLE AMMINISTRATORE(
    Email VARCHAR(100) PRIMARY KEY,
    Codice_Sicurezza VARCHAR(50) NOT NULL,
    FOREIGN KEY (Email) REFERENCES UTENTE(Email) ON DELETE CASCADE
);

-- Creazione della tabella CREATORE
CREATE TABLE CREATORE (
    Email VARCHAR(100) PRIMARY KEY,
    Nr_Progetti INT DEFAULT 0,
    Affidabilita FLOAT DEFAULT 0,
    FOREIGN KEY (Email) REFERENCES UTENTE(Email) ON DELETE CASCADE
);

-- Creazione della tabella PROGETTO
CREATE TABLE PROGETTO(
    Nome VARCHAR(100) PRIMARY KEY,
    Descrizione TEXT NOT NULL,
    Data_Inserimento DATE NOT NULL,
    Stato ENUM('aperto', 'chiuso') NOT NULL,
    Budget DECIMAL(10,2) NOT NULL,
    Data_Limite DATE NOT NULL,
    Email_Creatore VARCHAR(100) NOT NULL,
    FOREIGN KEY (Email_Creatore) REFERENCES CREATORE(Email) ON DELETE CASCADE
);

-- Creazione della tabella HARDWARE
CREATE TABLE HARDWARE(
    Nome VARCHAR(100) PRIMARY KEY,
    FOREIGN KEY (Nome) REFERENCES PROGETTO(Nome) ON DELETE CASCADE
);

-- Creazione della tabella SOFTWARE
CREATE TABLE SOFTWARE(
    Nome VARCHAR(100) PRIMARY KEY,
    FOREIGN KEY (Nome) REFERENCES PROGETTO(Nome) ON DELETE CASCADE
);

-- Creazione della tabella COMPONENTI
CREATE TABLE COMPONENTI(
    Nome VARCHAR(100) PRIMARY KEY,
    Descrizione TEXT NOT NULL,
    Prezzo DECIMAL(10,2) NOT NULL,
    Quantità INT NOT NULL
);

-- Creazione della tabella COMPONENTI_HARDWARE
CREATE TABLE COMPONENTI_HARDWARE(
    Nome_Progetto VARCHAR(100),
    Nome_Componente VARCHAR(100),
    PRIMARY KEY (Nome_Progetto, Nome_Componente),
    FOREIGN KEY (Nome_Progetto) REFERENCES HARDWARE(Nome) ON DELETE CASCADE,
    FOREIGN KEY (Nome_Componente) REFERENCES COMPONENTI(Nome) ON DELETE CASCADE
);

-- Creazione della tabella PROFILO
CREATE TABLE PROFILO(
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL
);

-- Creazione della tabella PROFILO_SOFTWARE
CREATE TABLE PROFILO_SOFTWARE(
    Nome_Progetto VARCHAR(100),
    ID_Profilo INT,
    PRIMARY KEY (Nome_Progetto, ID_Profilo),
    FOREIGN KEY (Nome_Progetto) REFERENCES SOFTWARE(Nome) ON DELETE CASCADE,
    FOREIGN KEY (ID_Profilo) REFERENCES PROFILO(ID) ON DELETE CASCADE
);

-- Creazione della tabella SKILL_RICHIESTA
CREATE TABLE SKILL_RICHIESTA(
    ID_Profilo INT,
    Competenza VARCHAR(100),
    Livello INT,
    PRIMARY KEY (ID_Profilo, Competenza, Livello),
    FOREIGN KEY (ID_Profilo) REFERENCES PROFILO(ID) ON DELETE CASCADE,
    FOREIGN KEY (Competenza, Livello) REFERENCES SKILL(Competenza, LIVELLO) ON DELETE CASCADE
);

-- Creazione della tabella COMMENTO
CREATE TABLE COMMENTO(
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Testo TEXT NOT NULL,
    Nome_Progetto VARCHAR(100) NOT NULL,
    Email_Utente VARCHAR(100) NOT NULL,
    FOREIGN KEY (Nome_Progetto) REFERENCES PROGETTO(Nome) ON DELETE CASCADE,
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email) ON DELETE CASCADE
);

-- Creazione della tabella RISPOSTA
CREATE TABLE RISPOSTA(
    ID_Commento INT PRIMARY KEY,
    Email_Creatore VARCHAR(100) NOT NULL,
    Testo TEXT NOT NULL,
    Data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Commento) REFERENCES COMMENTO(ID) ON DELETE CASCADE,
    FOREIGN KEY (Email_Creatore) REFERENCES CREATORE(Email) ON DELETE CASCADE
);

-- Creazione della tabella REWARD
CREATE TABLE REWARD(
    Codice VARCHAR(100) PRIMARY KEY,
    Descrizione TEXT NOT NULL,
    Foto TEXT
);

-- Creazione della tabella PROGETTO_REWARD
CREATE TABLE PROGETTO_REWARD(
    Nome_Progetto VARCHAR(100),
    Codice_Reward VARCHAR(100),
    PRIMARY KEY (Nome_Progetto, Codice_Reward),
    FOREIGN KEY (Nome_Progetto) REFERENCES PROGETTO(Nome) ON DELETE CASCADE,
    FOREIGN KEY (Codice_Reward) REFERENCES REWARD(Codice) ON DELETE CASCADE
);

-- Creazione della tabella FINANZIAMENTO
CREATE TABLE FINANZIAMENTO(
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Importo DECIMAL(10,2) NOT NULL,
    Email_Utente VARCHAR(100) NOT NULL,
    Codice_Reward VARCHAR(100),
    Nome_Progetto VARCHAR(100) NOT NULL,
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email) ON DELETE CASCADE,
    FOREIGN KEY (Codice_Reward) REFERENCES REWARD(Codice) ON DELETE SET NULL,
    FOREIGN KEY (Nome_Progetto) REFERENCES PROGETTO(Nome) ON DELETE CASCADE
);

-- Creazione della tabella CANDIDATURA
CREATE TABLE CANDIDATURA(
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Esito BOOLEAN DEFAULT FALSE,
    Email_Utente VARCHAR(100) NOT NULL,
    ID_Profilo INT NOT NULL,
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email) ON DELETE CASCADE,
    FOREIGN KEY (ID_Profilo) REFERENCES PROFILO(ID) ON DELETE CASCADE
);

-- Stored Procedure per autenticazione utente
DELIMITER //
CREATE PROCEDURE AutenticaUtente(IN p_Email VARCHAR(100), IN p_Password VARCHAR(255))
BEGIN
    DECLARE v_Count INT;
    SELECT COUNT(*) INTO v_Count FROM UTENTE WHERE Email = p_Email AND Password = p_Password LIMIT 1;
    IF v_Count = 1 THEN
        SELECT 'Autenticazione riuscita' AS Messaggio;
    ELSE
        SELECT 'Autenticazione fallita' AS Messaggio;
    END IF;
END //
DELIMITER ;

-- Stored Procedure per la registrazione utente
DELIMITER //
CREATE PROCEDURE RegistraUtente(IN p_Email VARCHAR(100), IN p_Nickname VARCHAR(50), IN p_Password VARCHAR(255), IN p_Nome VARCHAR(50), IN p_Cognome VARCHAR(50), IN p_Anno_Di_Nascita DATE, IN p_Luogo_Di_Nascita VARCHAR(100))
BEGIN
    INSERT INTO UTENTE (Email, Nickname, Password, Nome, Cognome, Anno_Di_Nascita, Luogo_Di_Nascita)
    VALUES (p_Email, p_Nickname, p_Password, p_Nome, p_Cognome, p_Anno_Di_Nascita, p_Luogo_Di_Nascita);
END //
DELIMITER ;

-- Stored Procedure per l'inserimento di un commento
DELIMITER //
CREATE PROCEDURE InserisciCommento(IN p_Email VARCHAR(100), IN p_NomeProgetto VARCHAR(100), IN p_Testo TEXT)
BEGIN
    INSERT INTO COMMENTO (Data, Testo, Nome_Progetto, Email_Utente)
    VALUES (CURDATE(), p_Testo, p_NomeProgetto, p_Email);
END //
DELIMITER ;

-- Stored Procedure per il finanziamento di un progetto
DELIMITER //
CREATE PROCEDURE FinanziaProgetto(IN p_Email VARCHAR(100), IN p_NomeProgetto VARCHAR(100), IN p_Importo DECIMAL(10,2), IN p_CodiceReward VARCHAR(100))
BEGIN
    INSERT INTO FINANZIAMENTO (Data, Importo, Email_Utente, Codice_Reward, Nome_Progetto)
    VALUES (CURDATE(), p_Importo, p_Email, p_CodiceReward, p_NomeProgetto);
END //
DELIMITER ;

-- Stored Procedure per l'inserimento di una candidatura
DELIMITER //
CREATE PROCEDURE InserisciCandidatura(IN p_Email VARCHAR(100), IN p_IDProfilo INT)
BEGIN
    INSERT INTO CANDIDATURA (Esito, Email_Utente, ID_Profilo)
    VALUES (FALSE, p_Email, p_IDProfilo);
END //
DELIMITER ;

-- Stored Procedure per accettare una candidatura
DELIMITER //
CREATE PROCEDURE AccettaCandidatura(IN p_IDCandidatura INT, IN p_Esito BOOLEAN)
BEGIN
    UPDATE CANDIDATURA SET Esito = p_Esito WHERE ID = p_IDCandidatura;
END //
DELIMITER ;

-- Stored Procedure per inserire una nuova skill
DELIMITER //
CREATE PROCEDURE InserisciSkill(IN p_Competenza VARCHAR(100), IN p_Livello INT)
BEGIN
    INSERT INTO SKILL (COMPETENZA, LIVELLO) VALUES (p_Competenza, p_Livello);
END //

-- Trigger per aggiornare l'affidabilità del creatore
CREATE TRIGGER AggiornaAffidabilita AFTER INSERT ON FINANZIAMENTO
FOR EACH ROW
BEGIN
    UPDATE CREATORE C
    SET Affidabilita = (SELECT COUNT(DISTINCT P.Nome) / COUNT(*)
                        FROM PROGETTO P WHERE P.Email_Creatore = C.Email)
    WHERE C.Email = (SELECT Email_Creatore FROM PROGETTO WHERE Nome = NEW.Nome_Progetto);
END $$

-- Trigger per cambiare lo stato di un progetto quando il budget è raggiunto
CREATE TRIGGER ChiudiProgettoBudget AFTER INSERT ON FINANZIAMENTO
FOR EACH ROW
BEGIN
    UPDATE PROGETTO
    SET Stato = 'chiuso'
    WHERE Nome = NEW.Nome_Progetto AND 
          (SELECT SUM(Importo) FROM FINANZIAMENTO WHERE Nome_Progetto = NEW.Nome_Progetto) >= Budget;
END $$



-- Evento per chiudere i progetti scaduti
CREATE EVENT ChiudiProgettiScaduti
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    UPDATE PROGETTO
    SET Stato = 'chiuso'
    WHERE Stato = 'aperto' AND Data_Limite < CURDATE();
END $$

DELIMITER ;

CREATE VIEW classifica_affidabilita AS
SELECT u.Nickname, c.affidabilita
FROM UTENTE u
JOIN CREATORE c ON u.Email = c.Email
ORDER BY c.affidabilita DESC
LIMIT 3;

-- View per i progetti aperti più vicini al completamento (Top 3)
CREATE VIEW ProgettiQuasiCompletati AS
SELECT p.Nome, p.Descrizione, p.Budget - COALESCE(SUM(f.Importo), 0) AS DifferenzaResidua
FROM Progetto p
LEFT JOIN Finanziamento f ON p.Nome = f.Nome_Progetto
WHERE p.Stato = 'APERTI'
GROUP BY p.Nome, p.Descrizione, p.Budget
ORDER BY DifferenzaResidua ASC
LIMIT 3;

-- View per la classifica degli utenti in base ai finanziamenti totali erogati (Top 3)
CREATE VIEW ClassificaFinanziatori AS
SELECT u.Nickname
FROM Utente u
JOIN Finanziamento f ON u.Email = f.Email_Utente
GROUP BY u.Nickname
ORDER BY SUM(f.Importo) DESC
LIMIT 3;

-- Inserimento dati nella tabella UTENTE
INSERT INTO UTENTE (Email, Nickname, Password, Nome, Cognome, Anno_Di_Nascita, Luogo_Di_Nascita) VALUES
('dalia.barone@email.com', 'dalia28', 'password123', 'Dalia', 'Barone', '2004-02-20', 'Termoli'),
('mattia.veroni@email.com', 'mattiav', 'mypassword', 'Mattia', 'Veroni', '2002-12-31', 'Carpi'),
('sofia.neamtu@email.com', 'sofia_n', 'securepass', 'Sofia', 'Neamtu', '2003-12-10', 'Padova');

-- Inserimento dati nella tabella SKILL (CORRETTO)
INSERT INTO SKILL (Competenza, Livello) VALUES
('AI', 4),
('Machine Learning', 5),
('Web Development', 4),
('Database Management', 3),
('Cybersecurity', 4),
('Data Analysis', 3),
('Cloud Computing', 5), -- Corretto a 5 per matchare SKILL_RICHIESTA
('Cloud Computing', 4),
('Networking', 3),
('Software Engineering', 4),
('Embedded Systems', 3);

-- Inserimento dati nella tabella SKILL_CURRICULUM (CORRETTO)
INSERT INTO SKILL_CURRICULUM (Email_Utente, Competenza, Livello) VALUES
('dalia.barone@email.com', 'Web Development', 4),
('dalia.barone@email.com', 'Database Management', 3),
('mattia.veroni@email.com', 'Cybersecurity', 4),
('mattia.veroni@email.com', 'Networking', 3),
('sofia.neamtu@email.com', 'Data Analysis', 3),
('sofia.neamtu@email.com', 'AI', 4),
('sofia.neamtu@email.com', 'Machine Learning', 5);

-- Inserimento dati nella tabella AMMINISTRATORE
-- Solo alcuni utenti saranno amministratori
INSERT INTO AMMINISTRATORE (Email, Codice_Sicurezza) VALUES
('dalia.barone@email.com', 'SEC123'),
('mattia.veroni@email.com', 'SEC456');

-- Inserimento dati nella tabella CREATORE
-- Solo alcuni utenti saranno creatori di progetti
INSERT INTO CREATORE (Email, Affidabilita) VALUES
('dalia.barone@email.com', 5),
('mattia.veroni@email.com', 4),
('sofia.neamtu@email.com', 3);

-- Inserimento dati nella tabella PROGETTO
INSERT INTO PROGETTO (Nome, Descrizione, Data_Inserimento, Stato, Budget, Data_Limite, Email_Creatore) VALUES
('SmartHome AI', 'Sistema di automazione domestica basato su AI', '2025-03-01','aperto', 5000, '2025-06-01', 'dalia.barone@email.com'),
('EduTech Platform', 'Piattaforma di e-learning avanzata', '2025-02-20','aperto', 8000, '2025-05-15', 'mattia.veroni@email.com'),
('CyberShield', 'Firewall AI per la sicurezza informatica', '2025-01-15', 'chiuso', 12000, '2025-04-30', 'sofia.neamtu@email.com'),
('AutoPilot System', 'Sistema di guida autonoma per auto', '2025-02-10', 'aperto', 15000, '2025-08-01', 'dalia.barone@email.com'),
('E-Health Monitor', 'Sistema di monitoraggio remoto della salute', '2025-03-05','aperto', 7000, '2025-06-30', 'mattia.veroni@email.com');

-- Inserimento dati nella tabella HARDWARE (solo per progetti hardware)
INSERT INTO HARDWARE (Nome) VALUES
('SmartHome AI'),
('AutoPilot System');

-- Inserimento dati nella tabella SOFTWARE (solo per progetti software)
INSERT INTO SOFTWARE (Nome) VALUES
('EduTech Platform'),
('CyberShield'),
('E-Health Monitor');

-- Inserimento dati nella tabella COMPONENTI
INSERT INTO COMPONENTI (Nome, Descrizione, Prezzo, Quantità) VALUES
('Sensore di Movimento', 'Sensore per rilevare il movimento in ambienti domestici', 20.00, 10),
('Modulo Bluetooth', 'Modulo di comunicazione Bluetooth per connessione remota', 15.00, 8),
('Camera HD', 'Telecamera ad alta risoluzione per sicurezza', 50.00, 5),
('Motore Elettrico', 'Motore per guida autonoma', 120.00, 4),
('Sensore LiDAR', 'Sensore per rilevamento ostacoli in guida autonoma', 200.00, 2),
('Batteria al Litio', 'Batteria ricaricabile ad alta capacità', 90.00, 6),
('Modulo WiFi', 'Modulo di connessione WiFi per dispositivi embedded', 18.00, 10),
('Display Touchscreen', 'Schermo touchscreen per interfaccia utente', 75.00, 3);

-- Inserimento dati nella tabella COMPONENTI_HARDWARE
INSERT INTO COMPONENTI_HARDWARE (Nome_Progetto, Nome_Componente) VALUES
('SmartHome AI', 'Sensore di Movimento'),
('SmartHome AI', 'Modulo Bluetooth'),
('SmartHome AI', 'Camera HD'),
('AutoPilot System', 'Motore Elettrico'),
('AutoPilot System', 'Sensore LiDAR'),
('AutoPilot System', 'Batteria al Litio');

-- Inserimento dati nella tabella PROFILO
INSERT INTO PROFILO (ID, Nome) VALUES
(1, 'Esperto AI'),
(2, 'Sviluppatore Full Stack'),
(3, 'Analista di Sicurezza'),
(4, 'Ingegnere DevOps'),
(5, 'Data Scientist'),
(6, 'Cloud Architect');

-- Inserimento dati nella tabella PROFILO_SOFTWARE
INSERT INTO PROFILO_SOFTWARE (Nome_Progetto, ID_Profilo) VALUES
('EduTech Platform', 1),
('EduTech Platform', 2),
('CyberShield', 3),
('CyberShield', 4),
('E-Health Monitor', 5),
('E-Health Monitor', 6);

-- Inserimento dati nella tabella SKILL_RICHIESTA (CORRETTO)
INSERT INTO SKILL_RICHIESTA (ID_Profilo, Competenza, Livello) VALUES
(1, 'AI', 4), -- Esperto AI deve avere almeno AI livello 4
(1, 'Machine Learning', 5), -- Esperto AI deve avere Machine Learning livello 5
(2, 'Web Development', 4), -- Sviluppatore Full Stack deve sapere Web Dev livello 4
(2, 'Database Management', 3), -- Sviluppatore Full Stack deve saper gestire DB livello 3
(3, 'Cybersecurity', 4), -- Analista Sicurezza deve sapere Cybersecurity livello 4
(4, 'Cloud Computing', 5), -- Ingegnere DevOps deve avere Cloud Computing livello 5
(5, 'Data Analysis', 3), -- Data Scientist deve avere Data Analysis livello 3
(5, 'AI', 4), -- Corretto il livello di AI per Data Scientist a 4 (prima era 3)
(6, 'Cloud Computing', 4), -- Cloud Architect deve sapere Cloud Computing livello 4
(6, 'Networking', 3); -- Cloud Architect deve sapere Networking livello 3

-- Tabelle commento e risposta in tempo reale

-- Inserimento dati nella tabella REWARD
INSERT INTO REWARD (Codice, Descrizione, Foto) VALUES
('RWD1', 'Accesso beta esclusivo al prodotto', 'beta_access.jpg'),
('RWD2', 'T-shirt personalizzata del progetto', 'tshirt.jpg'),
('RWD3', 'Menzione speciale nel sito ufficiale', 'mention.jpg'),
('RWD4', 'Invito a evento esclusivo di presentazione', 'event_invite.jpg'),
('RWD5', 'Pacchetto premium di funzioni avanzate', 'premium_pack.jpg');

-- Tabella finanziamento e candidatura in tempo reale