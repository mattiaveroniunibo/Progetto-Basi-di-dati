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
