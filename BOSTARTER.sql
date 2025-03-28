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

-- Creazione della tabella SKILL_CURRICULUM
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

-- Creazione della tabella FOTOGRAFIA (nuova entità per gestire le immagini)
CREATE TABLE FOTOGRAFIA (
    id INT AUTO_INCREMENT PRIMARY KEY,
    percorso VARCHAR(255) NOT NULL,
    descrizione TEXT,
    data_inserimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creazione della tabella PROGETTO (rimosso campo Foto, aggiunto idFoto)
CREATE TABLE PROGETTO(
    Nome VARCHAR(100) PRIMARY KEY,
    Descrizione TEXT NOT NULL,
    Data_Inserimento DATE NOT NULL,
    idFoto INT,                         -- Riferimento alla fotografia
    Stato ENUM('aperto', 'chiuso') NOT NULL,
    Budget DECIMAL(10,2) NOT NULL,
    Data_Limite DATE NOT NULL,
    Email_Creatore VARCHAR(100) NOT NULL,
    FOREIGN KEY (Email_Creatore) REFERENCES CREATORE(Email) ON DELETE CASCADE,
    FOREIGN KEY (idFoto) REFERENCES FOTOGRAFIA(id) ON DELETE SET NULL
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
    Quantita INT NOT NULL
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

-- Creazione della tabella REWARD (rimosso campo Foto, aggiunto idFoto)
CREATE TABLE REWARD(
    Codice VARCHAR(100) PRIMARY KEY,
    Descrizione TEXT NOT NULL,
    idFoto INT,
    FOREIGN KEY (idFoto) REFERENCES FOTOGRAFIA(id) ON DELETE SET NULL
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

--------------------------------------------------------------------
-- Delimitatore per le procedure e i trigger
--------------------------------------------------------------------

DELIMITER $$

-- Stored Procedure per autenticazione utente
CREATE PROCEDURE AutenticaUtente(
    IN p_Email VARCHAR(100),
    IN p_Password VARCHAR(255)
)
BEGIN
    DECLARE v_Count INT;
    SELECT COUNT(*) INTO v_Count
    FROM UTENTE
    WHERE Email = p_Email AND Password = p_Password
    LIMIT 1;
    IF v_Count = 1 THEN
        SELECT 'Autenticazione riuscita' AS Messaggio;
    ELSE
        SELECT 'Autenticazione fallita' AS Messaggio;
    END IF;
END $$

-- Stored Procedure per la registrazione utente
CREATE PROCEDURE RegistraUtente(
    IN p_Email VARCHAR(100),
    IN p_Nickname VARCHAR(50),
    IN p_Password VARCHAR(255),
    IN p_Nome VARCHAR(50),
    IN p_Cognome VARCHAR(50),
    IN p_Anno_Di_Nascita DATE,
    IN p_Luogo_Di_Nascita VARCHAR(100)
)
BEGIN
    INSERT INTO UTENTE (
        Email,
        Nickname,
        Password,
        Nome,
        Cognome,
        Anno_Di_Nascita,
        Luogo_Di_Nascita
    )
    VALUES (
        p_Email,
        p_Nickname,
        p_Password,
        p_Nome,
        p_Cognome,
        p_Anno_Di_Nascita,
        p_Luogo_Di_Nascita
    );
END $$

-- Stored Procedure per l'inserimento di un commento
CREATE PROCEDURE InserisciCommento(
    IN p_Email VARCHAR(100),
    IN p_NomeProgetto VARCHAR(100),
    IN p_Testo TEXT
)
BEGIN
    INSERT INTO COMMENTO (Data, Testo, Nome_Progetto, Email_Utente)
    VALUES (NOW(), p_Testo, p_NomeProgetto, p_Email);
END $$

-- Stored Procedure per il finanziamento di un progetto
CREATE PROCEDURE FinanziaProgetto(
    IN p_Email VARCHAR(100),
    IN p_NomeProgetto VARCHAR(100),
    IN p_Importo DECIMAL(10,2),
    IN p_CodiceReward VARCHAR(100)
)
BEGIN
    INSERT INTO FINANZIAMENTO (Importo, Email_Utente, Codice_Reward, Nome_Progetto)
    VALUES (p_Importo, p_Email, p_CodiceReward, p_NomeProgetto);
END $$

-- Stored Procedure per l'inserimento di una candidatura
CREATE PROCEDURE InserisciCandidatura(
    IN p_Email VARCHAR(100),
    IN p_IDProfilo INT
)
BEGIN
    INSERT INTO CANDIDATURA (Esito, Email_Utente, ID_Profilo)
    VALUES (FALSE, p_Email, p_IDProfilo);
END $$

-- Stored Procedure per accettare una candidatura
CREATE PROCEDURE AccettaCandidatura(
    IN p_IDCandidatura INT,
    IN p_Esito BOOLEAN
)
BEGIN
    UPDATE CANDIDATURA
    SET Esito = p_Esito
    WHERE ID = p_IDCandidatura;
END $$

-- Stored Procedure per inserire una nuova skill
CREATE PROCEDURE InserisciSkill(
    IN p_Competenza VARCHAR(100),
    IN p_Livello INT
)
BEGIN
    INSERT INTO SKILL (COMPETENZA, LIVELLO)
    VALUES (p_Competenza, p_Livello);
END $$

-- Trigger per aggiornare l'affidabilita del creatore
CREATE TRIGGER AggiornaAffidabilita
AFTER INSERT ON FINANZIAMENTO
FOR EACH ROW
BEGIN
    UPDATE CREATORE C
    SET Affidabilita = (
        SELECT COUNT(DISTINCT P.Nome) / COUNT(*)
        FROM PROGETTO P
        WHERE P.Email_Creatore = C.Email
    )
    WHERE C.Email = (
        SELECT Email_Creatore
        FROM PROGETTO
        WHERE Nome = NEW.Nome_Progetto
    );
END $$

-- Trigger per cambiare lo stato di un progetto quando il budget è raggiunto
CREATE TRIGGER ChiudiProgettoBudget
AFTER INSERT ON FINANZIAMENTO
FOR EACH ROW
BEGIN
    UPDATE PROGETTO
    SET Stato = 'chiuso'
    WHERE Nome = NEW.Nome_Progetto
      AND (
         SELECT SUM(Importo)
         FROM FINANZIAMENTO
         WHERE Nome_Progetto = NEW.Nome_Progetto
      ) >= Budget;
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

-- View classifica_affidabilita
CREATE VIEW classifica_affidabilita AS
SELECT u.Nickname, c.affidabilita
FROM UTENTE u
JOIN CREATORE c ON u.Email = c.Email
ORDER BY c.affidabilita DESC
LIMIT 3;

-- View per i progetti aperti più vicini al completamento (Top 3)
CREATE VIEW ProgettiQuasiCompletati AS
SELECT p.Nome,
       p.Descrizione,
       p.Budget - COALESCE(SUM(f.Importo), 0) AS DifferenzaResidua
FROM PROGETTO p
LEFT JOIN FINANZIAMENTO f ON p.Nome = f.Nome_Progetto
WHERE p.Stato = 'aperto'
GROUP BY p.Nome, p.Descrizione, p.Budget
ORDER BY DifferenzaResidua ASC
LIMIT 3;

-- View per la classifica degli utenti in base ai finanziamenti totali erogati (Top 3)
CREATE VIEW ClassificaFinanziatori AS
SELECT u.Nickname
FROM UTENTE u
JOIN FINANZIAMENTO f ON u.Email = f.Email_Utente
GROUP BY u.Nickname
ORDER BY SUM(f.Importo) DESC
LIMIT 3;

-- Dati di esempio

-- Inserimento dati nella tabella UTENTE
INSERT INTO UTENTE (Email, Nickname, Password, Nome, Cognome, Anno_Di_Nascita, Luogo_Di_Nascita)
VALUES
('dalia.barone@email.com','dalia28','password123','Dalia','Barone','2004-02-20','Termoli'),
('mattia.veroni@email.com','mattiav','mypassword','Mattia','Veroni','2002-12-31','Carpi'),
('sofia.neamtu@email.com','sofia_n','securepass','Sofia','Neamtu','2003-12-10','Padova');

-- Inserimento dati nella tabella SKILL
INSERT INTO SKILL (Competenza, Livello) VALUES
('AI', 4),
('Machine Learning', 5),
('Web Development', 4),
('Database Management', 3),
('Cybersecurity', 4),
('Data Analysis', 3),
('Cloud Computing', 5),
('Cloud Computing', 4),
('Networking', 3),
('Software Engineering', 4),
('Embedded Systems', 3);

-- Inserimento dati nella tabella SKILL_CURRICULUM
INSERT INTO SKILL_CURRICULUM (Email_Utente, Competenza, Livello) VALUES
('dalia.barone@email.com','Web Development',4),
('dalia.barone@email.com','Database Management',3),
('mattia.veroni@email.com','Cybersecurity',4),
('mattia.veroni@email.com','Networking',3),
('sofia.neamtu@email.com','Data Analysis',3),
('sofia.neamtu@email.com','AI',4),
('sofia.neamtu@email.com','Machine Learning',5);

-- Inserimento dati nella tabella AMMINISTRATORE
INSERT INTO AMMINISTRATORE (Email, Codice_Sicurezza) VALUES
('dalia.barone@email.com','SEC123'),
('mattia.veroni@email.com','SEC456');

-- Inserimento dati nella tabella CREATORE
INSERT INTO CREATORE (Email, Affidabilita) VALUES
('dalia.barone@email.com',5),
('mattia.veroni@email.com',4),
('sofia.neamtu@email.com',3);


-- Inserimento dati per la gestione delle immagini

-- Immagini per i progetti
INSERT INTO FOTOGRAFIA (percorso, descrizione)
VALUES 
('smarthome.jpg', 'Foto per SmartHome AI'),
('edutech.jpg', 'Foto per EduTech Platform'),
('cybershield.jpg', 'Foto per CyberShield'),
('autopilot.jpg', 'Foto per AutoPilot System'),
('ehealth.jpg', 'Foto per E-Health Monitor');

-- Immagini per le reward
INSERT INTO FOTOGRAFIA (percorso, descrizione)
VALUES 
('beta_access.jpg', 'Foto per Reward RWD1'),
('tshirt.jpg', 'Foto per Reward RWD2'),
('mention.jpg', 'Foto per Reward RWD3'),
('event_invite.jpg', 'Foto per Reward RWD4'),
('premium_pack.jpg', 'Foto per Reward RWD5');


-- Inserimento dati nella tabella PROGETTO (utilizzando gli idFoto appena inseriti)

INSERT INTO PROGETTO (Nome, Descrizione, Data_Inserimento, idFoto, Stato, Budget, Data_Limite, Email_Creatore)
VALUES
('SmartHome AI',
 'Sistema di automazione domestica basato su AI',
 '2025-03-01',
 1,  -- idFoto corrispondente a 'smarthome.jpg'
 'aperto',
 5000,
 '2025-06-01',
 'dalia.barone@email.com'),

('EduTech Platform',
 'Piattaforma di e-learning avanzata',
 '2025-02-20',
 2,  -- idFoto corrispondente a 'edutech.jpg'
 'aperto',
 8000,
 '2025-05-15',
 'mattia.veroni@email.com'),

('CyberShield',
 'Firewall AI per la sicurezza informatica',
 '2025-01-15',
 3,  -- idFoto corrispondente a 'cybershield.jpg'
 'chiuso',
 12000,
 '2025-04-30',
 'sofia.neamtu@email.com'),

('AutoPilot System',
 'Sistema di guida autonoma per auto',
 '2025-02-10',
 4,  -- idFoto corrispondente a 'autopilot.jpg'
 'aperto',
 15000,
 '2025-08-01',
 'dalia.barone@email.com'),

('E-Health Monitor',
 'Sistema di monitoraggio remoto della salute',
 '2025-03-05',
 5,  -- idFoto corrispondente a 'ehealth.jpg'
 'aperto',
 7000,
 '2025-06-30',
 'mattia.veroni@email.com');


-- Inserimento dati nelle tabelle HARDWARE e SOFTWARE

-- HARDWARE
INSERT INTO HARDWARE (Nome)
VALUES ('SmartHome AI'),
       ('AutoPilot System');

-- SOFTWARE
INSERT INTO SOFTWARE (Nome)
VALUES ('EduTech Platform'),
       ('CyberShield'),
       ('E-Health Monitor');

-- Inserimento dati nella tabella COMPONENTI

INSERT INTO COMPONENTI (Nome, Descrizione, Prezzo, Quantita)
VALUES
('Sensore di Movimento','Sensore per rilevare il movimento in ambienti domestici',20.00,10),
('Modulo Bluetooth','Modulo di comunicazione Bluetooth per connessione remota',15.00,8),
('Camera HD','Telecamera ad alta risoluzione per sicurezza',50.00,5),
('Motore Elettrico','Motore per guida autonoma',120.00,4),
('Sensore LiDAR','Sensore per rilevamento ostacoli in guida autonoma',200.00,2),
('Batteria al Litio','Batteria ricaricabile ad alta capacita',90.00,6),
('Modulo WiFi','Modulo di connessione WiFi per dispositivi embedded',18.00,10),
('Display Touchscreen','Schermo touchscreen per interfaccia utente',75.00,3);


-- Inserimento dati nella tabella COMPONENTI_HARDWARE

INSERT INTO COMPONENTI_HARDWARE (Nome_Progetto, Nome_Componente)
VALUES
('SmartHome AI','Sensore di Movimento'),
('SmartHome AI','Modulo Bluetooth'),
('SmartHome AI','Camera HD'),
('AutoPilot System','Motore Elettrico'),
('AutoPilot System','Sensore LiDAR'),
('AutoPilot System','Batteria al Litio');


-- Inserimento dati nella tabella PROFILO

INSERT INTO PROFILO (ID, Nome)
VALUES
(1,'Esperto AI'),
(2,'Sviluppatore Full Stack'),
(3,'Analista di Sicurezza'),
(4,'Ingegnere DevOps'),
(5,'Data Scientist'),
(6,'Cloud Architect');


-- Inserimento dati nella tabella PROFILO_SOFTWARE

INSERT INTO PROFILO_SOFTWARE (Nome_Progetto, ID_Profilo)
VALUES
('EduTech Platform',1),
('EduTech Platform',2),
('CyberShield',3),
('CyberShield',4),
('E-Health Monitor',5),
('E-Health Monitor',6);


-- Inserimento dati nella tabella SKILL_RICHIESTA

INSERT INTO SKILL_RICHIESTA (ID_Profilo, Competenza, Livello)
VALUES
(1,'AI',4),
(1,'Machine Learning',5),
(2,'Web Development',4),
(2,'Database Management',3),
(3,'Cybersecurity',4),
(4,'Cloud Computing',5),
(5,'Data Analysis',3),
(5,'AI',4),
(6,'Cloud Computing',4),
(6,'Networking',3);


-- Inserimento dati nella tabella REWARD (utilizzando gli idFoto per le immagini delle reward)

INSERT INTO REWARD (Codice, Descrizione, idFoto)
VALUES
('RWD1','Accesso beta esclusivo al prodotto', 6),  -- idFoto per 'beta_access.jpg'
('RWD2','T-shirt personalizzata del progetto', 7),   -- idFoto per 'tshirt.jpg'
('RWD3','Menzione speciale nel sito ufficiale', 8),    -- idFoto per 'mention.jpg'
('RWD4','Invito a evento esclusivo di presentazione', 9),  -- idFoto per 'event_invite.jpg'
('RWD5','Pacchetto premium di funzioni avanzate', 10);  -- idFoto per 'premium_pack.jpg'


-- Inserimento dati nella tabella FINANZIAMENTO

INSERT INTO FINANZIAMENTO (Importo, Email_Utente, Codice_Reward, Nome_Progetto)
VALUES
(100.00, 'dalia.barone@email.com', 'RWD1', 'SmartHome AI'),
(200.00, 'mattia.veroni@email.com', 'RWD2', 'EduTech Platform'),
(150.00, 'sofia.neamtu@email.com', 'RWD3', 'CyberShield'),
(300.00, 'dalia.barone@email.com', 'RWD4', 'AutoPilot System'),
(250.00, 'mattia.veroni@email.com', 'RWD5', 'E-Health Monitor');


-- Inserimento dati nella tabella CANDIDATURA

INSERT INTO CANDIDATURA (Esito, Email_Utente, ID_Profilo)
VALUES
(FALSE, 'dalia.barone@email.com', 1),
(FALSE, 'mattia.veroni@email.com', 2),
(FALSE, 'sofia.neamtu@email.com', 3);


