DROP DATABASE IF  EXISTS BOTSTARTER;
CREATE DATABASE IF NOT EXISTS BOTSTARTER;

CREATE TABLE UTENTE(
	Email varchar(100) PRIMARY KEY,
    Nickname varchar(50),
    Password varchar(20),
    Nome varchar(20),
    Cognome varchar(30),
    Anno_Di_Nascita Date,
    Luogo_Di_Nascita varchar(30)
);