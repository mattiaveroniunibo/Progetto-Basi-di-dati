DROP DATABASE IF EXISTS BOTSTARTER;
CREATE DATABASE IF NOT EXISTS BOTSTARTER;

USE BOTSTARTER;

-- Creazione della tabella UTENTE
CREATE TABLE UTENTE(
    Email VARCHAR(100) PRIMARY KEY, -- Email come chiave primaria
    Nickname VARCHAR(50),
    Password VARCHAR(255), -- La password potrebbe essere lunga
    Nome VARCHAR(50),
    Cognome VARCHAR(50),
    Anno_Di_Nascita DATE,
    Luogo_Di_Nascita VARCHAR(100)
);

-- Creazione della tabella SKILL
CREATE TABLE SKILL(
    COMPETENZA VARCHAR(100), -- Competenza che può essere lunga
    LIVELLO INT, -- Livello compreso tra 0 e 5
    PRIMARY KEY (COMPETENZA, LIVELLO) -- Combinazione di entrambe come chiave primaria
);

-- Creazione della tabella SKILL_Curriculum
CREATE TABLE SKILL_CURRICULUM(
    Email_Utente VARCHAR(100), 
    Competenza VARCHAR(100),
    Livello INT,
    PRIMARY KEY (Email_Utente, Competenza, Livello), -- Combinazione di chiavi
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email), -- Chiave esterna che fa riferimento alla tabella UTENTE
    FOREIGN KEY (Competenza, Livello) REFERENCES SKILL(Competenza, LIVELLO) -- Chiave esterna che fa riferimento alla tabella SKILL
);

-- Creazione della tabella AMMINISTRATORE
CREATE TABLE AMMINISTRATORE(
    Email VARCHAR(100) PRIMARY KEY, 
    Codice_Sicurezza VARCHAR(50), -- Codice di sicurezza per gli amministratori
    FOREIGN KEY (Email) REFERENCES UTENTE(Email) -- Chiave esterna che fa riferimento alla tabella UTENTE
);

-- Creazione della tabella CREATORE
CREATE TABLE CREATORE(
    Email VARCHAR(100) PRIMARY KEY, 
    FOREIGN KEY (Email) REFERENCES UTENTE(Email) -- Chiave esterna che fa riferimento alla tabella UTENTE
);

-- Creazione della tabella PROGETTO
CREATE TABLE PROGETTO(
    Nome VARCHAR(100) PRIMARY KEY, -- Nome del progetto come chiave primaria
    Descrizione TEXT,
    Data_Inserimento DATE,
    Foto TEXT,
    Stato ENUM('aperto', 'chiuso'), -- Stato del progetto (aperto o chiuso)
    Budget DECIMAL(10, 2), -- Budget richiesto per il progetto
    Data_Limite DATE, -- Data limite entro cui deve essere raggiunto il budget
    Email_Creatore VARCHAR(100), -- Email del creatore
    FOREIGN KEY (Email_Creatore) REFERENCES CREATORE(Email) -- Chiave esterna che fa riferimento alla tabella CREATORE
);

-- Creazione della tabella HARDWARE
CREATE TABLE HARDWARE(
    Nome VARCHAR(100) PRIMARY KEY, -- Nome del progetto hardware
    FOREIGN KEY (Nome) REFERENCES PROGETTO(Nome) -- Chiave esterna che fa riferimento alla tabella PROGETTO
);

-- Creazione della tabella SOFTWARE
CREATE TABLE SOFTWARE(
    Nome VARCHAR(100) PRIMARY KEY, -- Nome del progetto software
    FOREIGN KEY (Nome) REFERENCES PROGETTO(Nome) -- Chiave esterna che fa riferimento alla tabella PROGETTO
);

-- Creazione della tabella COMPONENTI
CREATE TABLE COMPONENTI(
    Nome VARCHAR(100) PRIMARY KEY, -- Nome della componente
    Descrizione TEXT,
    Prezzo DECIMAL(10, 2), -- Prezzo della componente
    Quantità INT -- Quantità necessaria della componente
);

-- Creazione della tabella COMPONENTI_HARDWARE
CREATE TABLE COMPONENTI_HARDWARE(
    Nome_Progetto VARCHAR(100),
    Nome_Componente VARCHAR(100),
    PRIMARY KEY (Nome_Progetto, Nome_Componente),
    FOREIGN KEY (Nome_Progetto) REFERENCES HARDWARE(Nome), -- Chiave esterna che fa riferimento alla tabella HARDWARE
    FOREIGN KEY (Nome_Componente) REFERENCES COMPONENTI(Nome) -- Chiave esterna che fa riferimento alla tabella COMPONENTI
);

-- Creazione della tabella PROFILO
CREATE TABLE PROFILO(
    ID INT PRIMARY KEY, 
    Nome VARCHAR(100) -- Nome del profilo (ad esempio "Esperto AI")
);

-- Creazione della tabella PROFILO_SOFTWARE
CREATE TABLE PROFILO_SOFTWARE(
    Nome_Progetto VARCHAR(100),
    ID_Profilo INT,
    PRIMARY KEY (Nome_Progetto, ID_Profilo),
    FOREIGN KEY (Nome_Progetto) REFERENCES SOFTWARE(Nome), -- Chiave esterna che fa riferimento alla tabella SOFTWARE
    FOREIGN KEY (ID_Profilo) REFERENCES PROFILO(ID) -- Chiave esterna che fa riferimento alla tabella PROFILO
);

-- Creazione della tabella SKILL_RICHIESTA
CREATE TABLE SKILL_RICHIESTA(
    ID_Profilo INT,
    Competenza VARCHAR(100),
    Livello INT, -- Livello richiesto per quella skill
    PRIMARY KEY (ID_Profilo, Competenza, Livello),
    FOREIGN KEY (ID_Profilo) REFERENCES PROFILO(ID), -- Chiave esterna che fa riferimento alla tabella PROFILO
    FOREIGN KEY (Competenza, Livello) REFERENCES SKILL(Competenza, LIVELLO) -- Chiave esterna che fa riferimento alla tabella SKILL
);

-- Creazione della tabella COMMENTO
CREATE TABLE COMMENTO(
    ID INT PRIMARY KEY,
    Data DATE, -- Data di inserimento del commento
    Testo TEXT, -- Testo del commento
    Nome_Progetto VARCHAR(100), -- Progetto a cui si riferisce il commento
    Email_Utente VARCHAR(100), -- Email dell'utente che ha scritto il commento
    FOREIGN KEY (Nome_Progetto) REFERENCES PROGETTO(Nome), -- Chiave esterna che fa riferimento alla tabella PROGETTO
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email) -- Chiave esterna che fa riferimento alla tabella UTENTE
);

-- Creazione della tabella RISPOSTA
CREATE TABLE RISPOSTA(
    ID_Commento INT,
    Email_Creatore VARCHAR(100),
    Testo TEXT, -- Testo della risposta
    Data DATE, -- Data di inserimento della risposta
    PRIMARY KEY (ID_Commento),
    FOREIGN KEY (ID_Commento) REFERENCES COMMENTO(ID), -- Chiave esterna che fa riferimento alla tabella COMMENTO
    FOREIGN KEY (Email_Creatore) REFERENCES CREATORE(Email) -- Chiave esterna che fa riferimento alla tabella CREATORE
);

-- Creazione della tabella REWARD
CREATE TABLE REWARD(
    Codice VARCHAR(100) PRIMARY KEY, -- Codice della reward
    Descrizione TEXT, -- Descrizione della reward
    Foto TEXT, -- Foto associata alla reward
    Nome_Progetto VARCHAR(100), -- Progetto a cui è associata la reward
    FOREIGN KEY (Nome_Progetto) REFERENCES PROGETTO(Nome) -- Chiave esterna che fa riferimento alla tabella PROGETTO
);

-- Creazione della tabella FINANZIAMENTO
CREATE TABLE FINANZIAMENTO(
    ID INT PRIMARY KEY,
    Data DATE, -- Data del finanziamento
    Importo DECIMAL(10, 2), -- Importo del finanziamento
    Email_Utente VARCHAR(100), -- Email dell'utente che finanzia
    Codice_Reward VARCHAR(100), -- Codice della reward scelta
    Nome_Progetto VARCHAR(100), -- Nome del progetto finanziato
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email), -- Chiave esterna che fa riferimento alla tabella UTENTE
    FOREIGN KEY (Codice_Reward) REFERENCES REWARD(Codice), -- Chiave esterna che fa riferimento alla tabella REWARD
    FOREIGN KEY (Nome_Progetto) REFERENCES PROGETTO(Nome) -- Chiave esterna che fa riferimento alla tabella PROGETTO
);

-- Creazione della tabella CANDIDATURA
CREATE TABLE CANDIDATURA(
    ID INT PRIMARY KEY, 
    Esito BOOLEAN, -- Esito della candidatura
    Email_Utente VARCHAR(100), -- Email dell'utente che si è candidato
    ID_Profilo INT, -- Profilo a cui si è candidati
    FOREIGN KEY (Email_Utente) REFERENCES UTENTE(Email), -- Chiave esterna che fa riferimento alla tabella UTENTE
    FOREIGN KEY (ID_Profilo) REFERENCES PROFILO(ID) -- Chiave esterna che fa riferimento alla tabella PROFILO
);

DELIMITER $$

-- Autenticazione utente
CREATE PROCEDURE AutenticaUtente(IN p_Email VARCHAR(100), IN p_Password VARCHAR(255))
BEGIN
    DECLARE v_Count INT;
    SELECT COUNT(*) INTO v_Count FROM UTENTE WHERE Email = p_Email AND Password = p_Password;
    IF v_Count = 1 THEN
        SELECT 'Autenticazione riuscita' AS Messaggio;
    ELSE
        SELECT 'Autenticazione fallita' AS Messaggio;
    END IF;
END $$

-- Registrazione nuovo utente
CREATE PROCEDURE RegistraUtente(IN p_Email VARCHAR(100), IN p_Nickname VARCHAR(50), IN p_Password VARCHAR(255), IN p_Nome VARCHAR(50), IN p_Cognome VARCHAR(50), IN p_Anno_Di_Nascita DATE, IN p_Luogo_Di_Nascita VARCHAR(100))
BEGIN
    INSERT INTO UTENTE (Email, Nickname, Password, Nome, Cognome, Anno_Di_Nascita, Luogo_Di_Nascita)
    VALUES (p_Email, p_Nickname, p_Password, p_Nome, p_Cognome, p_Anno_Di_Nascita, p_Luogo_Di_Nascita);
END $$

-- Inserimento delle proprie skill
CREATE PROCEDURE InserisciSkillCurriculum(IN p_Email VARCHAR(100), IN p_Competenza VARCHAR(100), IN p_Livello INT)
BEGIN
    INSERT INTO SKILL_CURRICULUM (Email_Utente, Competenza, Livello)
    VALUES (p_Email, p_Competenza, p_Livello);
END $$

-- Visualizzazione dei progetti disponibili
CREATE PROCEDURE VisualizzaProgetti()
BEGIN
    SELECT * FROM PROGETTO WHERE Stato = 'aperto';
END $$

-- Finanziamento di un progetto
CREATE PROCEDURE FinanziaProgetto(IN p_Email VARCHAR(100), IN p_NomeProgetto VARCHAR(100), IN p_Importo DECIMAL(10,2), IN p_CodiceReward VARCHAR(100))
BEGIN
    INSERT INTO FINANZIAMENTO (Data, Importo, Email_Utente, Codice_Reward, Nome_Progetto)
    VALUES (CURDATE(), p_Importo, p_Email, p_CodiceReward, p_NomeProgetto);
END $$

-- Scelta della reward a valle del finanziamento di un progetto
CREATE PROCEDURE SceltaRewardFinanziamento(IN p_Email VARCHAR(100), IN p_CodiceReward VARCHAR(100), IN p_NomeProgetto VARCHAR(100))
BEGIN
    DECLARE v_ControlloFinanziamento INT;

    -- Verifica se l'utente ha finanziato il progetto
    SELECT COUNT(*) INTO v_ControlloFinanziamento
    FROM FINANZIAMENTO
    WHERE Email_Utente = p_Email AND Nome_Progetto = p_NomeProgetto;

    IF v_ControlloFinanziamento > 0 THEN
        -- Inserisce la scelta della reward
        INSERT INTO FINANZIAMENTO_REWARD (Email_Utente, Codice_Reward, Nome_Progetto)
        VALUES (p_Email, p_CodiceReward, p_NomeProgetto);
        SELECT 'Reward scelta con successo' AS Messaggio;
    ELSE
        SELECT 'Impossibile scegliere reward: non hai finanziato questo progetto' AS Messaggio;
    END IF;
END $$

-- Inserimento di un commento
CREATE PROCEDURE InserisciCommento(IN p_Email VARCHAR(100), IN p_NomeProgetto VARCHAR(100), IN p_Testo TEXT)
BEGIN
    INSERT INTO COMMENTO (Data, Testo, Nome_Progetto, Email_Utente)
    VALUES (CURDATE(), p_Testo, p_NomeProgetto, p_Email);
END $$

-- Inserimento candidatura
CREATE PROCEDURE InserisciCandidatura(IN p_Email VARCHAR(100), IN p_IDProfilo INT)
BEGIN
    INSERT INTO CANDIDATURA (Esito, Email_Utente, ID_Profilo)
    VALUES (NULL, p_Email, p_IDProfilo);
END $$

-- Inserimento nuova competenza (solo admin)
CREATE PROCEDURE InserisciCompetenza(IN p_Competenza VARCHAR(100), IN p_Livello INT)
BEGIN
    INSERT INTO SKILL (COMPETENZA, LIVELLO) VALUES (p_Competenza, p_Livello);
END $$

-- Autenticazione utente con codice di sicurezza (solo per amministratori)
CREATE PROCEDURE AutenticaUtenteConCodiceSicurezza(IN p_Email VARCHAR(100), IN p_Password VARCHAR(255), IN p_CodiceSicurezza VARCHAR(50))
BEGIN
    DECLARE v_Count INT;
    DECLARE v_CodiceSicurezzaValido INT;

    -- Verifica se l'utente esiste e la password è corretta
    SELECT COUNT(*) INTO v_Count FROM UTENTE WHERE Email = p_Email AND Password = p_Password;
    
    -- Se l'utente è un amministratore, verifica anche il codice di sicurezza
    IF v_Count = 1 THEN
        SELECT COUNT(*) INTO v_CodiceSicurezzaValido 
        FROM AMMINISTRATORE 
        WHERE Email = p_Email AND Codice_Sicurezza = p_CodiceSicurezza;
        
        IF v_CodiceSicurezzaValido = 1 THEN
            SELECT 'Autenticazione riuscita' AS Messaggio;
        ELSE
            SELECT 'Codice di sicurezza errato' AS Messaggio;
        END IF;
    ELSE
        SELECT 'Autenticazione fallita' AS Messaggio;
    END IF;
END $$

-- Inserimento nuovo progetto (solo creatori)
CREATE PROCEDURE InserisciProgetto(IN p_Nome VARCHAR(100), IN p_Descrizione TEXT, IN p_Foto TEXT, IN p_Budget DECIMAL(10,2), IN p_DataLimite DATE, IN p_EmailCreatore VARCHAR(100))
BEGIN
    INSERT INTO PROGETTO (Nome, Descrizione, Data_Inserimento, Foto, Stato, Budget, Data_Limite, Email_Creatore)
    VALUES (p_Nome, p_Descrizione, CURDATE(), p_Foto, 'aperto', p_Budget, p_DataLimite, p_EmailCreatore);
END $$

-- Inserimento di una reward (solo creatori)
CREATE PROCEDURE InserisciReward(IN p_Codice VARCHAR(100), IN p_Descrizione TEXT, IN p_Foto TEXT, IN p_NomeProgetto VARCHAR(100))
BEGIN
    INSERT INTO REWARD (Codice, Descrizione, Foto, Nome_Progetto)
    VALUES (p_Codice, p_Descrizione, p_Foto, p_NomeProgetto);
END $$

-- Inserimento risposta ad un commento (solo creatori)
CREATE PROCEDURE InserisciRisposta(IN p_IDCommento INT, IN p_EmailCreatore VARCHAR(100), IN p_Testo TEXT)
BEGIN
    INSERT INTO RISPOSTA (ID_Commento, Email_Creatore, Testo, Data)
    VALUES (p_IDCommento, p_EmailCreatore, p_Testo, CURDATE());
END $$

-- Inserimento di un profilo - solo per la realizzazione di un progetto software
CREATE PROCEDURE InserisciProfiloSoftware(IN p_Nome VARCHAR(100))
BEGIN
    INSERT INTO PROFILO (Nome) 
    VALUES (p_Nome);
END $$

-- Accettazione candidatura (solo creatori)
CREATE PROCEDURE AccettaCandidatura(IN p_IDCandidatura INT, IN p_Esito BOOLEAN)
BEGIN
    UPDATE CANDIDATURA SET Esito = p_Esito WHERE ID = p_IDCandidatura;
END $$

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

-- Trigger per incrementare il numero di progetti di un creatore
CREATE TRIGGER IncrementaNrProgetti AFTER INSERT ON PROGETTO
FOR EACH ROW
BEGIN
    UPDATE CREATORE
    SET Nr_Progetti = Nr_Progetti + 1
    WHERE Email = NEW.Email_Creatore;
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
SELECT u.Nickname, 
       COUNT(DISTINCT p.Nome) AS Progetti_Creati,
       COUNT(f.ID) AS Totale_Finanziamenti,
       IFNULL(COUNT(DISTINCT p.Nome) / NULLIF(COUNT(f.ID), 0), 0) AS Affidabilita
FROM UTENTE u
JOIN CREATORE c ON u.Email = c.Email
LEFT JOIN PROGETTO p ON c.Email = p.Email_Creatore
LEFT JOIN FINANZIAMENTO f ON p.Nome = f.Nome_Progetto
GROUP BY u.Nickname
ORDER BY Affidabilita DESC
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