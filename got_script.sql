-- usage
-- db2 -td$ -vf got_script.sql

db2start$
CREATE DATABASE	got$
CONNECT TO got$

-- DROP ALL TABLES
-- db2 -x "select 'drop table ' || rtrim(tabschema) || '.' || rtrim(tabname) || ' '  || ';'from syscat.tables where type = 'T' and tabschema='DBP037'"
drop table FIGUR$
drop table PERSON$
drop table ANGEHOERT$
drop table BEZIEHUNG$
drop table STRAFFEL$
drop table EPISODE$
drop table AUFTRETENIN$
drop table BENUTZER$
drop table TIER$
drop table ENTHALTEN$
drop table BEWERTUNG$
drop table HAUS$
drop table ORT$
drop table BURG$
drop table ANSEHEN$
drop table BEHERRSCHEN$
drop table PLAYLISTE$

CREATE TABLE figur (
	figurid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	name VARCHAR(50) NOT NULL,
	herkunftsort VARCHAR(50) NOT NULL,
	PRIMARY KEY (figurid)
)$

CREATE TABLE person (
	figurid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	name VARCHAR(50) NOT NULL,
	herkunftsort VARCHAR(50) NOT NULL,
	titel VARCHAR(100) NOT NULL,
	Biografie VARCHAR(500),
	PRIMARY KEY (figurid)
)$

CREATE TABLE angehoert (
	figurid INTEGER NOT NULL REFERENCES figur (figurid),
	hausid INTEGER NOT NULL REFERENCES haus (hausid),
	startepisode INTEGER NOT NULL,
	endepisode INTEGER NOT NULL,
	PRIMARY KEY (figurid, hausid)
)$

CREATE TABLE beziehung (
	figurida INTEGER NOT NULL REFERENCES figur (figurid),
	figuridb INTEGER NOT NULL REFERENCES figur (figurid),
	beziehungstyp VARCHAR(20) NOT NULL,
	PRIMARY KEY (figurida, figuridb)
)$

CREATE TABLE ort (
	ortid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	ortname VARCHAR(100) NOT NULL,
	PRIMARY KEY (ortid)
)$

CREATE TABLE tier (
	figurid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	name VARCHAR(50) NOT NULL,
	herkunftsort INTEGER NOT NULL REFERENCES ort (ortid),
	besitztVon INTEGER,
	PRIMARY KEY (figurid)
-- 	FOREIGN KEY (herkunftsort) REFERENCES ort (ortid)
)$

CREATE TABLE straffel (
	nummer INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	episodenanzahl INTEGER NOT NULL,
	startsdatum DATE NOT NULL,
	PRIMARY KEY (nummer)
)$

CREATE TABLE episode (
	episodeid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	epinummer INTEGER NOT NULL,
	titel VARCHAR(50) NOT NULL,
	inhaltsangabe VARCHAR(50),
	Erstausstrahlungsdatum DATE NOT NULL,
	nummer INTEGER NOT NULL REFERENCES straffel (nummer),
	PRIMARY KEY (nummer, episodeid)
-- 	FOREIGN KEY (nummer) REFERENCES straffel (nummer)
)$

CREATE TABLE auftretenIn (
	figurid INTEGER NOT NULL REFERENCES figur (figurid),
	episodeid INTEGER NOT NULL,
	nummer INTEGER NOT NULL, --straffel nummer
	PRIMARY KEY (figurid, episodeid, nummer),
-- 	FOREIGN KEY (figurid) REFERENCES figur (figurid),
	FOREIGN KEY (episodeid, nummer) REFERENCES episode (episodeid, nummer)
)$

CREATE TABLE benutzer (
	benutzerid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	loginkennung VARCHAR(30) NOT NULL,
	name VARCHAR(30) NOT NULL,
	passwort VARCHAR(30) NOT NULL,
	PRIMARY KEY (benutzerid)
)$

CREATE TABLE playliste (
	playlisteid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	gehoertzu INTEGER REFERENCES benutzer (benutzerid),
	PRIMARY KEY (playlisteid)
	--FOREIGN KEY (gehoertzu) REFERENCES benutzer (benutzerid)
)$

CREATE TABLE enthalten ( -- episode playliste
	playlisteid INTEGER NOT NULL REFERENCES  playliste (playlisteid),
	gehoertzu INTEGER NOT NULL, --benutzer id
	episodeid INTEGER NOT NULL,
	nummer INTEGER NOt NULL, --straffel nummer
	PRIMARY KEY (playlisteid, episodeid, nummer),
-- 	FOREIGN KEY (playlisteid) REFERENCES playliste (playlisteid),
	-- FOREIGN KEY (gehoertzu) REFERENCES benutzer (benutzerid),
	FOREIGN KEY (episodeid, nummer) REFERENCES episode (episodeid, nummer)
)$


CREATE TABLE bewertung (
	bewertungid INTEGER NOT NULL, --PRIMARY KEY GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	textInhalt VARCHAR(500),
	rating INTEGER NOT NULL,
	benutzerid INTEGER NOT NULL REFERENCES benutzer (benutzerid),
	PRIMARY KEY (bewertungid, benutzerid)
-- 	FOREIGN KEY (benutzerid) REFERENCES benutzer (benutzerid)
)$

CREATE TABLE haus (
	hausid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	name VARCHAR(100) NOT NULL,
	sitz VARCHAR(50) NOT NULL,
	motto VARCHAR(100) NOT NULL,
	wappen VARCHAR(100) NOT NULL,
	PRIMARY KEY (hausid)
)$

CREATE TABLE burg (
	burgid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
	name VARCHAR(100) NOT NULL,
	standort INTEGER NOT NULL REFERENCES ort (ortid),
	PRIMARY KEY (burgid)
-- 	FOREIGN KEY (standort) REFERENCES ort (ortid)
)$

CREATE TABLE ansehen (
	name VARCHAR(100) NOT NULL,
	standort INTEGER NOT NULL REFERENCES ort (ortid),
	burgid INTEGER NOT NULL REFERENCES burg (burgid),
	hausid INTEGER NOT NULL REFERENCES haus (hausid),
	PRIMARY KEY (hausid, burgid)
-- 	FOREIGN KEY (hausid) REFERENCES haus (hausid),
-- 	FOREIGN KEY (burgid) REFERENCES burg (burgid),
-- 	FOREIGN KEY (standort) REFERENCES ort (ortid)
)$

CREATE TABLE beherrschen (
	hausid INTEGER NOT NULL REFERENCES haus (hausid),
	ortid INTEGER NOT NULL REFERENCES ort (ortid),
	startepisode INTEGER NOT NULL,
	endepisode INTEGER NOT NULL,
	PRIMARY KEY (hausid, ortid, startepisode, endepisode)
-- 	FOREIGN KEY (hausid) REFERENCES haus (hausid),
-- 	FOREIGN KEY (ortid) REFERENCES ort (ortid)
)$





CREATE TRIGGER neuplayliste AFTER INSERT ON playliste
FOR EACH STATEMENT MODE DB2SQL
INSERT INTO straffel (episodenanzahl, startsdatum) VALUES (10, DATE('2011-04-17')) ,(10, DATE('2012-04-01')), (10, DATE('2013-03-31')), (10, DATE('2013-04-06')), (10, DATE('2015-04-12')), (10, DATE('2016-04-24'))$

CREATE TRIGGER listezunutzer BEFORE INSERT ON playliste
FOR EACH ROW 
BEGIN
INSERT INTO benutzer (loginkennung, name, passwort) VALUES ('user', 'user', '12345');
END$

CREATE TRIGGER straffel AFTER INSERT ON straffel
REFERENCING NEW s
FOR EACH ROW MODE DB2SQL
IF (s.nummer = 1) THEN
	INSERT INTO episode (epinummer, titel, inhaltsangabe, Erstausstrahlungsdatum, nummer) VALUES
	 (0, 'Trailer', 'Trailer', DATE('2010-03-02'), s.nummer), 
	 (1, 'Winter Is Coming', 'fehlt', DATE('2011-04-17'), s.nummer), 
	 (2, 'The Kingsroad', 'fehlt', DATE('2011-04-24'), s.nummer), 
	 (3, 'Lord Snow', 'fehlt', DATE('2011-05-01'), s.nummer), 
	 (4, 'Cripples, Bastards, and Broken Things', 'fehlt', DATE('2011-05-08'), s.nummer), 
	 (5, 'The Wolf and the Lion', 'fehlt', DATE('2011-05-15'), s.nummer), 
	 (6, 'A Golden Crown', 'fehlt', DATE('2011-05-22'), s.nummer), 
	 (7, 'You Win or You Die', 'fehlt', DATE('2011-05-29'), s.nummer), 
	 (8, 'The Pointy End', 'fehlt', DATE('2011-06-05'), s.nummer), 
	 (9, 'Winter Is Coming', 'fehlt', DATE('2011-06-12'), s.nummer), 
	 (10, 'Fire and Blood', 'fehlt', DATE('2011-06-19'), s.nummer);
ELSEIF (s.nummer = 2) THEN
	INSERT INTO episode (epinummer, titel, inhaltsangabe, Erstausstrahlungsdatum, nummer) VALUES (0, 'Trailer', 'Trailer', DATE('2011-04-19'), s.nummer), (1, 'The North Remembers', 'fehlt', DATE('2012-04-01'), s.nummer), (2, 'The Night Lands', 'fehlt', DATE('2012-04-08'), s.nummer), (3, 'What Is Dead May Never Die', 'fehlt', DATE('2012-04-15'), s.nummer), (4, 'Garden of Bones', 'fehlt', DATE('2012-04-22'), s.nummer), (5, 'The Ghost of Harrenhal', 'fehlt', DATE('2012-04-29'), s.nummer), (6, 'The Old Gods and the New', 'fehlt', DATE('2012-05-06'), s.nummer), (7, 'A Man Without Honor', 'fehlt', DATE('2012-05-13'), s.nummer), (8, 'The Prince of Winterfall', 'fehlt', DATE('2012-05-20'), s.nummer), (9, 'Blackwater', 'fehlt', DATE('2012-05-27'), s.nummer), (10, 'Valar Morghulis', 'fehlt', DATE('2012-06-03'), s.nummer);
ELSEIF (s.nummer = 3) THEN
	INSERT INTO episode (epinummer, titel, inhaltsangabe, Erstausstrahlungsdatum, nummer) VALUES (0, 'Trailer', 'Trailer', DATE('2012-04-10'), s.nummer), (1, 'Valar Dohaeris', 'fehlt', DATE('2013-03-31'), s.nummer), (2, 'Dark Wings, Dark Words', 'fehlt', DATE('2013-04-07'), s.nummer), (3, 'Walk of Punishment', 'fehlt', DATE('2013-04-14'), s.nummer), (4, 'And Now His Watch Is Ended', 'fehlt', DATE('2013-04-21'), s.nummer), (5, 'Kissed by Fire', 'fehlt', DATE('2013-04-28'), s.nummer), (6, 'The Climb', 'fehlt', DATE('2013-05-05'), s.nummer), (7, 'The Bear and the Maiden Fair', 'fehlt', DATE('2013-05-12'), s.nummer), (8, 'Second Sons', 'fehlt', DATE('2013-05-19'), s.nummer), (9, 'The Rains of Castamere', 'fehlt', DATE('2013-06-02'), s.nummer), (10, 'Mhysa', 'fehlt', DATE('2013-06-09'), s.nummer);
ELSEIF (s.nummer = 4) THEN
	INSERT INTO episode (epinummer, titel, inhaltsangabe, Erstausstrahlungsdatum, nummer) VALUES (0, 'Trailer', 'Trailer', DATE('2013-04-02'), s.nummer), (1, 'Valar Dohaeris', 'fehlt', DATE('2013-03-31'), s.nummer), (2, 'Dark Wings, Dark Words', 'fehlt', DATE('2013-04-07'), s.nummer), (3, 'Walk of Punishment', 'fehlt', DATE('2013-04-14'), s.nummer), (4, 'And Now His Watch Is Ended', 'fehlt', DATE('2013-04-21'), s.nummer), (5, 'Kissed by Fire', 'fehlt', DATE('2013-04-28'), s.nummer), (6, 'The Climb', 'fehlt', DATE('2013-05-05'), s.nummer), (7, 'The Bear and the Maiden Fair', 'fehlt', DATE('2013-05-12'), s.nummer), (8, 'Second Sons', 'fehlt', DATE('2013-05-19'), s.nummer), (9, 'The Rains of Castamere', 'fehlt', DATE('2013-06-02'), s.nummer), (10, 'Mhysa', 'fehlt', DATE('2013-06-09'), s.nummer);
ELSEIF (s.nummer = 5) THEN
	INSERT INTO episode (epinummer, titel, inhaltsangabe, Erstausstrahlungsdatum, nummer) VALUES (0, 'Trailer', 'Trailer', DATE('2014-04-08'), s.nummer), (1, 'Valar Dohaeris', 'fehlt', DATE('2013-03-31'), s.nummer), (2, 'Dark Wings, Dark Words', 'fehlt', DATE('2013-04-07'), s.nummer), (3, 'Walk of Punishment', 'fehlt', DATE('2013-04-14'), s.nummer), (4, 'And Now His Watch Is Ended', 'fehlt', DATE('2013-04-21'), s.nummer), (5, 'Kissed by Fire', 'fehlt', DATE('2013-04-28'), s.nummer), (6, 'The Climb', 'fehlt', DATE('2013-05-05'), s.nummer), (7, 'The Bear and the Maiden Fair', 'fehlt', DATE('2013-05-12'), s.nummer), (8, 'Second Sons', 'fehlt', DATE('2013-05-19'), s.nummer), (9, 'The Rains of Castamere', 'fehlt', DATE('2013-06-02'), s.nummer), (10, 'Mhysa', 'fehlt', DATE('2013-06-09'), s.nummer);	
ELSEIF (s.nummer = 6) THEN
	INSERT INTO episode (epinummer, titel, inhaltsangabe, Erstausstrahlungsdatum, nummer) VALUES (0, 'Trailer', 'Trailer', DATE('2014-04-08'), s.nummer), (1, 'Valar Dohaeris', 'fehlt', DATE('2013-03-31'), s.nummer), (2, 'Dark Wings, Dark Words', 'fehlt', DATE('2013-04-07'), s.nummer), (3, 'Walk of Punishment', 'fehlt', DATE('2013-04-14'), s.nummer), (4, 'And Now His Watch Is Ended', 'fehlt', DATE('2013-04-21'), s.nummer), (5, 'Kis, sed by Fire', 'fehlt', DATE('2013-04-28'), s.nummer), (6, 'The Climb', 'fehlt', DATE('2013-05-05'), s.nummer), (7, 'The Bear and the Maiden Fair', 'fehlt', DATE('2013-05-12'), s.nummer), (8, 'Second Sons', 'fehlt', DATE('2013-05-19'), s.nummer), (9, 'The Rains of Castamere', 'fehlt', DATE('2013-06-02'), s.nummer), (10, 'Mhysa', 'fehlt', DATE('2013-06-09'), s.nummer);
END IF
$

CREATE TRIGGER episode AFTER INSERT ON episode 
REFERENCING NEW TABLE AS new_episode
FOR EACH STATEMENT MODE DB2SQL
INSERT INTO enthalten (playlisteid, gehoertzu, episodeid, nummer) 
SELECT playlisteid, gehoertzu, episodeid, nummer FROM playliste p, new_episode e WHERE e.epinummer = 0$


--DELETE DATA from talbes
DELETE FROM benutzer$
DELETE FROM enthalten$
DELETE FROM episode$
DELETE FROM straffel$
DELETE FROM playliste$

INSERT INTO playliste (gehoertzu) values (1)$
SELECT e.playlisteid, e.gehoertzu, ep.nummer, ep.titel, ep.ERSTAUSSTRAHLUNGSDATUM 
FROM enthalten e INNER JOIN episode ep ON e.episodeid = ep.episodeid$



















