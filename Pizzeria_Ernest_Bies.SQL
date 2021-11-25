/*
Created: 29.10.2019
Modified: 06.01.2020
Project: Pizzeria
Model: Pizzeria management system
Company: ernestbies
Author: Ernest Bieś
Version: 1.0
Database: PostgreSQL 9.5
*/


-- Create roles section -------------------------------------------------

CREATE ROLE "administrator"
;

CREATE ROLE "przyjmujacy_zamowienie"
;

CREATE ROLE "klient"
;

CREATE ROLE "Ernest" LOGIN
;

CREATE ROLE "Marek" LOGIN
;

CREATE ROLE "Anna" LOGIN
;

-- Create domain types section -------------------------------------------------

CREATE DOMAIN "Email" AS Character varying(100) CONSTRAINT "email_check" CHECK (VALUE ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
;

CREATE DOMAIN "Telefon" AS Character varying(12) CONSTRAINT "telefon_check" CHECK (VALUE::text ~* '([(0)])([0-9]){9,}'::text OR VALUE::text ~* '([(0])([0-9]){2,}([)])([0-9]){7,}'::text)
;

-- Create sequences section -------------------------------------------------

CREATE SEQUENCE "klienci_id_klienta_seq"
 INCREMENT BY 1
 NO MAXVALUE
 MINVALUE 1
 CACHE 1
;

CREATE SEQUENCE "szczegoly_zamowienia_id_pozycji_seq"
 INCREMENT BY 1
 NO MAXVALUE
 MINVALUE 1
 CACHE 1
;

CREATE SEQUENCE "zamowienia_id_zamowienia_seq"
 INCREMENT BY 1
 NO MAXVALUE
 MINVALUE 1
 CACHE 1
;

CREATE SEQUENCE "adresy_id_adresu_seq"
 INCREMENT BY 1
 NO MAXVALUE
 MINVALUE 1
 CACHE 1
;

CREATE SEQUENCE "produkty_id_produktu_seq"
 INCREMENT BY 1
 NO MAXVALUE
 MINVALUE 1
 CACHE 1
;

CREATE SEQUENCE "dodatki_id_dodatku_seq"
 INCREMENT BY 1
 NO MAXVALUE
 NO MINVALUE
 CACHE 1
;

CREATE SEQUENCE "klienci_dane_logowania_id_dane_logowania_seq"
 INCREMENT BY 1
 NO MAXVALUE
 MINVALUE 1
 CACHE 1
;

-- Create tables section -------------------------------------------------

-- Table klienci

CREATE TABLE "klienci"(
 "id_klienta" Integer DEFAULT nextval('klienci_id_klienta_seq') NOT NULL,
 "imie" Character varying(20) NOT NULL,
 "nazwisko" Character varying(30) NOT NULL,
 "email" "Email",
 "nr_telefonu" "Telefon",
 "id_adresu" Integer DEFAULT nextval('adresy_id_adresu_seq'),
 "ilosc_punktow" Integer DEFAULT 0
)
WITH (
 autovacuum_enabled=true)
;

-- Create indexes for table klienci

CREATE INDEX "klienci_id_adresu_idx" ON "klienci" ("id_adresu")
;

-- Add keys for table klienci

ALTER TABLE "klienci" ADD CONSTRAINT "PK_klienci" PRIMARY KEY ("id_klienta")
;

-- Table adresy

CREATE TABLE "adresy"(
 "id_adresu" Integer DEFAULT nextval('adresy_id_adresu_seq') NOT NULL,
 "miejscowosc" Character varying(30) NOT NULL,
 "ulica" Character varying(30) NOT NULL,
 "nr_domu" Character varying(10) NOT NULL
)
WITH (
 autovacuum_enabled=true)
;

-- Add keys for table adresy

ALTER TABLE "adresy" ADD CONSTRAINT "PK_adresy" PRIMARY KEY ("id_adresu")
;

-- Table produkty

CREATE TABLE "produkty"(
 "id_produktu" Integer DEFAULT nextval('produkty_id_produktu_seq') NOT NULL,
 "nazwa_produktu" Character varying(60) NOT NULL,
 "sklad_produktu" Character varying(200),
 "cena_produktu" Money NOT NULL
)
WITH (
 autovacuum_enabled=true)
;

-- Add keys for table produkty

ALTER TABLE "produkty" ADD CONSTRAINT "PK_produkty" PRIMARY KEY ("id_produktu")
;

ALTER TABLE "produkty" ADD CONSTRAINT "nazwa_produktu" UNIQUE ("nazwa_produktu")
;

-- Table dodatki

CREATE TABLE "dodatki"(
 "id_dodatku" Integer DEFAULT nextval('dodatki_id_dodatku_seq') NOT NULL,
 "nazwa_dodatku" Character varying(30) NOT NULL,
 "cena_dodatku" Money NOT NULL
)
WITH (
 autovacuum_enabled=true)
;

-- Add keys for table dodatki

ALTER TABLE "dodatki" ADD CONSTRAINT "PK_dodatki" PRIMARY KEY ("id_dodatku")
;

ALTER TABLE "dodatki" ADD CONSTRAINT "nazwa_dodatku" UNIQUE ("nazwa_dodatku")
;

-- Table zamowienia

CREATE TABLE "zamowienia"(
 "id_zamowienia" Integer DEFAULT nextval('zamowienia_id_zamowienia_seq') NOT NULL,
 "id_klienta" Integer DEFAULT nextval('klienci_id_klienta_seq') NOT NULL,
 "data_zamowienia" Timestamp NOT NULL,
 "ilosc_punktow" Integer DEFAULT 0 NOT NULL,
 "komentarz" Text DEFAULT NULL,
 "ocena" Integer DEFAULT NULL
        CHECK (ocena > 0 AND ocena <= 5)
)
WITH (
 autovacuum_enabled=true)
;

-- Add keys for table zamowienia

ALTER TABLE "zamowienia" ADD CONSTRAINT "PK_zamowienia" PRIMARY KEY ("id_zamowienia")
;

-- Table szczegoly_zamowienia

CREATE TABLE "szczegoly_zamowienia"(
 "id_pozycji" Integer DEFAULT nextval('szczegoly_zamowienia_id_pozycji_seq') NOT NULL,
 "id_zamowienia" Integer DEFAULT nextval('zamowienia_id_zamowienia_seq') NOT NULL,
 "id_produktu" Integer DEFAULT nextval('produkty_id_produktu_seq') NOT NULL,
 "id_dodatku" Integer DEFAULT nextval('dodatki_id_dodatku_seq'),
 "cena" Money DEFAULT 0::MONEY NOT NULL
)
WITH (
 autovacuum_enabled=true)
;

-- Create indexes for table szczegoly_zamowienia

CREATE INDEX "szczegoly_zamowienia_id_dodatku_idx" ON "szczegoly_zamowienia" ("id_dodatku")
;

-- Add keys for table szczegoly_zamowienia

ALTER TABLE "szczegoly_zamowienia" ADD CONSTRAINT "PK_szczegoly_zamowienia" PRIMARY KEY ("id_pozycji")
;

-- Table punkty_zasady

CREATE TABLE "punkty_zasady"(
 "id_progu" Integer NOT NULL,
 "prog" Money NOT NULL
        CHECK (prog > 0::money AND prog <= 500::money),
 "punkty" Integer NOT NULL
        CHECK (punkty > 0 AND punkty <= 100)
)
WITH (
 autovacuum_enabled=true)
;

-- Add keys for table punkty_zasady

ALTER TABLE "punkty_zasady" ADD CONSTRAINT "PK_punkty_zasady" PRIMARY KEY ("id_progu")
;

-- Table klienci_dane_logowania

CREATE TABLE "klienci_dane_logowania"(
 "id_dane_logowania" Integer DEFAULT nextval('klienci_dane_logowania_id_dane_logowania_seq') NOT NULL,
 "id_klienta" Integer DEFAULT nextval('klienci_id_klienta_seq') NOT NULL,
 "login" Character varying NOT NULL,
 "haslo" Character varying(60) NOT NULL
)
WITH (
 autovacuum_enabled=true)
;

-- Create indexes for table klienci_dane_logowania

CREATE INDEX "klienci_dane_logowania_id_klienta_idx" ON "klienci_dane_logowania" ("id_klienta")
;

-- Add keys for table klienci_dane_logowania

ALTER TABLE "klienci_dane_logowania" ADD CONSTRAINT "PK_klienci_dane_logowania" PRIMARY KEY ("id_dane_logowania")
;

ALTER TABLE "klienci_dane_logowania" ADD CONSTRAINT "login" UNIQUE ("login")
;

-- Create views section -------------------------------------------------

CREATE VIEW "adresy_klientow" AS
SELECT "id_klienta", "imie", "nazwisko", "adresy"."id_adresu", "miejscowosc", "ulica", "nr_domu"
FROM "klienci", "adresy"
WHERE klienci.id_adresu = adresy.id_adresu
;

CREATE VIEW "zamowienia_klientow" AS
SELECT "klienci"."id_klienta", "imie", "nazwisko", "id_zamowienia", "data_zamowienia", "zamowienia"."ilosc_punktow", "komentarz", "ocena"
FROM "klienci", "zamowienia"
WHERE klienci.id_klienta = zamowienia.id_klienta
;

CREATE VIEW "klienci_pelne_dane" AS
SELECT "klienci"."id_klienta", "imie", "nazwisko", "email", "nr_telefonu", "id_adresu", "ilosc_punktow", "login", "haslo"
FROM "klienci", "klienci_dane_logowania"
WHERE klienci.id_klienta = klienci_dane_logowania.id_klienta
;

CREATE VIEW "konta_klientow" AS
SELECT "klienci"."id_klienta", "login", "haslo"
FROM "klienci", "klienci_dane_logowania"
WHERE klienci.id_klienta = klienci_dane_logowania.id_klienta
;

CREATE VIEW "cena_zamowienia"
 AS
SELECT zamowienia.id_zamowienia, SUM(cena) AS wartosc_laczna,
zamowienia.data_zamowienia
FROM zamowienia, szczegoly_zamowienia 
WHERE zamowienia.id_zamowienia = szczegoly_zamowienia.id_zamowienia
GROUP BY zamowienia.id_zamowienia;
;

CREATE VIEW "ranking_klientow" AS
SELECT "id_klienta", "imie", "nazwisko", "email", "ilosc_punktow"
FROM "klienci"
ORDER BY "ilosc_punktow" DESC
;

CREATE VIEW "klienci_szczegoly_zamowienia" AS
SELECT "klienci"."id_klienta", "szczegoly_zamowienia"."id_zamowienia", "id_produktu", "id_dodatku", "cena"
FROM "klienci", "zamowienia", "szczegoly_zamowienia"
WHERE klienci.id_klienta = zamowienia.id_klienta AND zamowienia.id_zamowienia = szczegoly_zamowienia.id_zamowienia
;
-- Create foreign keys (relationships) section ------------------------------------------------- 

ALTER TABLE "klienci" ADD CONSTRAINT "jest przypisany" FOREIGN KEY ("id_adresu") REFERENCES "adresy" ("id_adresu") ON DELETE NO ACTION ON UPDATE NO ACTION
;

ALTER TABLE "zamowienia" ADD CONSTRAINT "składa" FOREIGN KEY ("id_klienta") REFERENCES "klienci" ("id_klienta") ON DELETE NO ACTION ON UPDATE NO ACTION
;

ALTER TABLE "szczegoly_zamowienia" ADD CONSTRAINT "uwzględnia" FOREIGN KEY ("id_produktu") REFERENCES "produkty" ("id_produktu") ON DELETE NO ACTION ON UPDATE NO ACTION
;

ALTER TABLE "szczegoly_zamowienia" ADD CONSTRAINT "posiada" FOREIGN KEY ("id_dodatku") REFERENCES "dodatki" ("id_dodatku") ON DELETE NO ACTION ON UPDATE NO ACTION
;

ALTER TABLE "szczegoly_zamowienia" ADD CONSTRAINT "zawiera" FOREIGN KEY ("id_zamowienia") REFERENCES "zamowienia" ("id_zamowienia") ON DELETE NO ACTION ON UPDATE NO ACTION
;

ALTER TABLE "klienci_dane_logowania" ADD CONSTRAINT "posiada" FOREIGN KEY ("id_klienta") REFERENCES "klienci" ("id_klienta") ON DELETE NO ACTION ON UPDATE NO ACTION
;


ALTER SEQUENCE "klienci_id_klienta_seq" OWNED BY "klienci"."id_klienta"
;
ALTER SEQUENCE "szczegoly_zamowienia_id_pozycji_seq" OWNED BY "szczegoly_zamowienia"."id_pozycji"
;
ALTER SEQUENCE "zamowienia_id_zamowienia_seq" OWNED BY "zamowienia"."id_zamowienia"
;
ALTER SEQUENCE "adresy_id_adresu_seq" OWNED BY "adresy"."id_adresu"
;
ALTER SEQUENCE "produkty_id_produktu_seq" OWNED BY "produkty"."id_produktu"
;
ALTER SEQUENCE "dodatki_id_dodatku_seq" OWNED BY "dodatki"."id_dodatku"
;

-- Grant permissions section -------------------------------------------------

GRANT "administrator" TO "Ernest"
;
GRANT "przyjmujacy_zamowienie" TO "Marek"
;
GRANT "klient" TO "Anna"
;

GRANT SELECT ON "klienci" TO "administrator"
;
GRANT INSERT ON "klienci" TO "administrator"
;
GRANT UPDATE ON "klienci" TO "administrator"
;
GRANT DELETE ON "klienci" TO "administrator"
;
GRANT REFERENCES ON "klienci" TO "administrator"
;
GRANT TRIGGER ON "klienci" TO "administrator"
;
GRANT TRUNCATE ON "klienci" TO "administrator"
;
GRANT SELECT ON "klienci" TO "przyjmujacy_zamowienie"
;
GRANT INSERT ON "klienci" TO "przyjmujacy_zamowienie"
;
GRANT UPDATE ON "klienci" TO "przyjmujacy_zamowienie"
;
GRANT REFERENCES ON "klienci" TO "przyjmujacy_zamowienie"
;
GRANT TRIGGER ON "klienci" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "klienci" TO "klient"
;
GRANT UPDATE ON "klienci" TO "klient"
;
GRANT INSERT ON "klienci" TO "klient"
;
GRANT SELECT ON "adresy" TO "administrator"
;
GRANT INSERT ON "adresy" TO "administrator"
;
GRANT UPDATE ON "adresy" TO "administrator"
;
GRANT DELETE ON "adresy" TO "administrator"
;
GRANT REFERENCES ON "adresy" TO "administrator"
;
GRANT TRIGGER ON "adresy" TO "administrator"
;
GRANT TRUNCATE ON "adresy" TO "administrator"
;
GRANT SELECT ON "adresy" TO "przyjmujacy_zamowienie"
;
GRANT INSERT ON "adresy" TO "przyjmujacy_zamowienie"
;
GRANT UPDATE ON "adresy" TO "przyjmujacy_zamowienie"
;
GRANT REFERENCES ON "adresy" TO "przyjmujacy_zamowienie"
;
GRANT TRIGGER ON "adresy" TO "przyjmujacy_zamowienie"
;
GRANT DELETE ON "adresy" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "punkty_zasady" TO "administrator"
;
GRANT INSERT ON "punkty_zasady" TO "administrator"
;
GRANT UPDATE ON "punkty_zasady" TO "administrator"
;
GRANT DELETE ON "punkty_zasady" TO "administrator"
;
GRANT REFERENCES ON "punkty_zasady" TO "administrator"
;
GRANT TRIGGER ON "punkty_zasady" TO "administrator"
;
GRANT TRUNCATE ON "punkty_zasady" TO "administrator"
;
GRANT SELECT ON "zamowienia" TO "administrator"
;
GRANT INSERT ON "zamowienia" TO "administrator"
;
GRANT UPDATE ON "zamowienia" TO "administrator"
;
GRANT DELETE ON "zamowienia" TO "administrator"
;
GRANT REFERENCES ON "zamowienia" TO "administrator"
;
GRANT TRIGGER ON "zamowienia" TO "administrator"
;
GRANT TRUNCATE ON "zamowienia" TO "administrator"
;
GRANT SELECT ON "zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT INSERT ON "zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT UPDATE ON "zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT REFERENCES ON "zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT TRIGGER ON "zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT DELETE ON "zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "szczegoly_zamowienia" TO "administrator"
;
GRANT INSERT ON "szczegoly_zamowienia" TO "administrator"
;
GRANT UPDATE ON "szczegoly_zamowienia" TO "administrator"
;
GRANT DELETE ON "szczegoly_zamowienia" TO "administrator"
;
GRANT REFERENCES ON "szczegoly_zamowienia" TO "administrator"
;
GRANT TRIGGER ON "szczegoly_zamowienia" TO "administrator"
;
GRANT TRUNCATE ON "szczegoly_zamowienia" TO "administrator"
;
GRANT SELECT ON "szczegoly_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT INSERT ON "szczegoly_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT UPDATE ON "szczegoly_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT REFERENCES ON "szczegoly_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT TRIGGER ON "szczegoly_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT DELETE ON "szczegoly_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "produkty" TO "administrator"
;
GRANT INSERT ON "produkty" TO "administrator"
;
GRANT UPDATE ON "produkty" TO "administrator"
;
GRANT DELETE ON "produkty" TO "administrator"
;
GRANT REFERENCES ON "produkty" TO "administrator"
;
GRANT TRIGGER ON "produkty" TO "administrator"
;
GRANT TRUNCATE ON "produkty" TO "administrator"
;
GRANT SELECT ON "produkty" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "dodatki" TO "administrator"
;
GRANT INSERT ON "dodatki" TO "administrator"
;
GRANT UPDATE ON "dodatki" TO "administrator"
;
GRANT DELETE ON "dodatki" TO "administrator"
;
GRANT REFERENCES ON "dodatki" TO "administrator"
;
GRANT TRIGGER ON "dodatki" TO "administrator"
;
GRANT TRUNCATE ON "dodatki" TO "administrator"
;
GRANT SELECT ON "dodatki" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "klienci_dane_logowania" TO "administrator"
;
GRANT INSERT ON "klienci_dane_logowania" TO "administrator"
;
GRANT UPDATE ON "klienci_dane_logowania" TO "administrator"
;
GRANT DELETE ON "klienci_dane_logowania" TO "administrator"
;
GRANT REFERENCES ON "klienci_dane_logowania" TO "administrator"
;
GRANT TRIGGER ON "klienci_dane_logowania" TO "administrator"
;
GRANT TRUNCATE ON "klienci_dane_logowania" TO "administrator"
;
GRANT SELECT ON "klienci_dane_logowania" TO "przyjmujacy_zamowienie"
;
GRANT INSERT ON "klienci_dane_logowania" TO "przyjmujacy_zamowienie"
;
GRANT UPDATE ON "klienci_dane_logowania" TO "przyjmujacy_zamowienie"
;
GRANT DELETE ON "klienci_dane_logowania" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "klienci_dane_logowania" TO "klient"
;
GRANT UPDATE ON "klienci_dane_logowania" TO "klient"
;
GRANT INSERT ON "klienci_dane_logowania" TO "klient"
;
GRANT SELECT ON "cena_zamowienia" TO "administrator"
;
GRANT INSERT ON "cena_zamowienia" TO "administrator"
;
GRANT UPDATE ON "cena_zamowienia" TO "administrator"
;
GRANT DELETE ON "cena_zamowienia" TO "administrator"
;
GRANT REFERENCES ON "cena_zamowienia" TO "administrator"
;
GRANT TRIGGER ON "cena_zamowienia" TO "administrator"
;
GRANT SELECT ON "cena_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "cena_zamowienia" TO "klient"
;
GRANT SELECT ON "adresy_klientow" TO "administrator"
;
GRANT INSERT ON "adresy_klientow" TO "administrator"
;
GRANT UPDATE ON "adresy_klientow" TO "administrator"
;
GRANT DELETE ON "adresy_klientow" TO "administrator"
;
GRANT REFERENCES ON "adresy_klientow" TO "administrator"
;
GRANT TRIGGER ON "adresy_klientow" TO "administrator"
;
GRANT SELECT ON "adresy_klientow" TO "przyjmujacy_zamowienie"
;
GRANT INSERT ON "adresy_klientow" TO "przyjmujacy_zamowienie"
;
GRANT UPDATE ON "adresy_klientow" TO "przyjmujacy_zamowienie"
;
GRANT DELETE ON "adresy_klientow" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "konta_klientow" TO "administrator"
;
GRANT INSERT ON "konta_klientow" TO "administrator"
;
GRANT UPDATE ON "konta_klientow" TO "administrator"
;
GRANT DELETE ON "konta_klientow" TO "administrator"
;
GRANT REFERENCES ON "konta_klientow" TO "administrator"
;
GRANT TRIGGER ON "konta_klientow" TO "administrator"
;
GRANT SELECT ON "konta_klientow" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "klienci_pelne_dane" TO "administrator"
;
GRANT INSERT ON "klienci_pelne_dane" TO "administrator"
;
GRANT UPDATE ON "klienci_pelne_dane" TO "administrator"
;
GRANT DELETE ON "klienci_pelne_dane" TO "administrator"
;
GRANT REFERENCES ON "klienci_pelne_dane" TO "administrator"
;
GRANT TRIGGER ON "klienci_pelne_dane" TO "administrator"
;
GRANT SELECT ON "zamowienia_klientow" TO "administrator"
;
GRANT INSERT ON "zamowienia_klientow" TO "administrator"
;
GRANT UPDATE ON "zamowienia_klientow" TO "administrator"
;
GRANT DELETE ON "zamowienia_klientow" TO "administrator"
;
GRANT REFERENCES ON "zamowienia_klientow" TO "administrator"
;
GRANT TRIGGER ON "zamowienia_klientow" TO "administrator"
;
GRANT SELECT ON "zamowienia_klientow" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "ranking_klientow" TO "administrator"
;
GRANT INSERT ON "ranking_klientow" TO "administrator"
;
GRANT UPDATE ON "ranking_klientow" TO "administrator"
;
GRANT DELETE ON "ranking_klientow" TO "administrator"
;
GRANT REFERENCES ON "ranking_klientow" TO "administrator"
;
GRANT TRIGGER ON "ranking_klientow" TO "administrator"
;
GRANT SELECT ON "ranking_klientow" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "ranking_klientow" TO "klient"
;
GRANT SELECT ON "zamowienia" TO "klient"
;
GRANT UPDATE ON "zamowienia" TO "klient"
;
GRANT INSERT ON "zamowienia" TO "klient"
;
GRANT SELECT ON "szczegoly_zamowienia" TO "klient"
;
GRANT INSERT ON "szczegoly_zamowienia" TO "klient"
;
GRANT UPDATE ON "szczegoly_zamowienia" TO "klient"
;
GRANT SELECT ON "punkty_zasady" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "punkty_zasady" TO "klient"
;
GRANT SELECT ON "klienci_szczegoly_zamowienia" TO "administrator"
;
GRANT INSERT ON "klienci_szczegoly_zamowienia" TO "administrator"
;
GRANT UPDATE ON "klienci_szczegoly_zamowienia" TO "administrator"
;
GRANT DELETE ON "klienci_szczegoly_zamowienia" TO "administrator"
;
GRANT REFERENCES ON "klienci_szczegoly_zamowienia" TO "administrator"
;
GRANT TRIGGER ON "klienci_szczegoly_zamowienia" TO "administrator"
;
GRANT SELECT ON "klienci_szczegoly_zamowienia" TO "przyjmujacy_zamowienie"
;
GRANT SELECT ON "dodatki" TO "klient"
;
GRANT SELECT ON "produkty" TO "klient"
;
GRANT SELECT ON "adresy" TO "klient"
;
GRANT UPDATE ON "adresy" TO "klient"
;
GRANT INSERT ON "adresy" TO "klient"
;
GRANT SELECT ON "klienci_pelne_dane" TO "przyjmujacy_zamowienie"
;

-- Triggers
-- 1) Trigger, wartość pozycji w zamówieniu:
CREATE OR REPLACE FUNCTION oblicz_cene()
    RETURNS TRIGGER AS
$$
DECLARE
    cena_p MONEY;
    cena_d MONEY;
BEGIN
    cena_p = (SELECT cena_produktu FROM produkty WHERE produkty.id_produktu = NEW.id_produktu);
    cena_d = (SELECT cena_dodatku FROM dodatki WHERE dodatki.id_dodatku = NEW.id_dodatku);

    NEW.cena = cena_p;
    IF cena_d IS NOT NULL THEN
       NEW.cena = cena_p + cena_d;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

DROP TRIGGER IF EXISTS zamowienia_oblicz_cene ON szczegoly_zamowienia;
CREATE TRIGGER zamowienia_oblicz_cene BEFORE INSERT OR UPDATE
ON szczegoly_zamowienia FOR EACH ROW
EXECUTE PROCEDURE oblicz_cene();


-- 2) Trigger, dodawania punktow dla danego zamowienia:
CREATE OR REPLACE FUNCTION oblicz_punkty_zamowienia()
    RETURNS TRIGGER AS
$$
DECLARE
    pkt INTEGER;
BEGIN

IF (TG_OP != 'DELETE') THEN
    pkt = (SELECT punkty FROM punkty_zasady WHERE prog <= (SELECT SUM(cena) FROM szczegoly_zamowienia WHERE id_zamowienia = NEW.id_zamowienia) ORDER BY prog DESC LIMIT 1);
    IF pkt IS NULL THEN
       pkt = 0;
    END IF;
    UPDATE zamowienia SET ilosc_punktow = pkt WHERE zamowienia.id_zamowienia = NEW.id_zamowienia;  

    RETURN NEW;
END IF;
    UPDATE zamowienia SET ilosc_punktow = 0 WHERE zamowienia.id_zamowienia = OLD.id_zamowienia;
    RETURN NULL;    
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

DROP TRIGGER IF EXISTS zamowienia_oblicz_punkty_zamowienia ON szczegoly_zamowienia;
CREATE TRIGGER zamowienia_oblicz_punkty_zamowienia AFTER INSERT OR UPDATE OR DELETE
ON szczegoly_zamowienia FOR EACH ROW
EXECUTE PROCEDURE oblicz_punkty_zamowienia();

-- 3) Trigger, dodawania punktow dla klienta:
CREATE OR REPLACE FUNCTION oblicz_punkty_klienta()
    RETURNS TRIGGER AS
$$
DECLARE
    konto INTEGER;
    pkt_klienta INTEGER;
BEGIN
    konto = (SELECT COUNT(*) FROM klienci_dane_logowania k WHERE k.id_klienta = (SELECT id_klienta FROM zamowienia z WHERE z.id_zamowienia = NEW.id_zamowienia));
    IF konto>0 THEN
        pkt_klienta = (SELECT SUM(ilosc_punktow) FROM zamowienia z WHERE z.id_klienta = NEW.id_klienta);
	UPDATE klienci k SET ilosc_punktow = pkt_klienta WHERE k.id_klienta = NEW.id_klienta; 
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

DROP TRIGGER IF EXISTS zamowienia_oblicz_punkty_klienta ON zamowienia;
CREATE TRIGGER zamowienia_oblicz_punkty_klienta AFTER INSERT OR UPDATE
ON zamowienia FOR EACH ROW
EXECUTE PROCEDURE oblicz_punkty_klienta();

-- 5) Trigger, hashowanie hasła
CREATE OR REPLACE FUNCTION hash_haslo()
    RETURNS TRIGGER AS
$$
DECLARE

BEGIN
    NEW.haslo = md5(NEW.haslo);
    RETURN NEW;    
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

DROP TRIGGER IF EXISTS klienci_dane_logowania_hash_haslo ON klienci_dane_logowania;
CREATE TRIGGER klienci_dane_logowania_hash_haslo BEFORE INSERT OR UPDATE
ON klienci_dane_logowania FOR EACH ROW
EXECUTE PROCEDURE hash_haslo();

-- SQL Queries
-- Zdefiniowanie kwerend prostych.

-- A1) Dane o kliencie wraz z liczbą kont.
CREATE VIEW liczba_kont_klientow_A1_query AS (
SELECT id_klienta, imie, nazwisko, email, COUNT(kdl.id_klienta)::INTEGER AS liczba_kont_klienta
FROM klienci NATURAL LEFT JOIN klienci_dane_logowania kdl GROUP BY id_klienta ORDER BY liczba_kont_klienta DESC);

-- A2) Klienci z wprowadzonymi pełnymi danymi.
CREATE VIEW adresy_klientow_pelne_dane_A2_query AS (
SELECT id_klienta, imie, nazwisko, miejscowosc, ulica, email, nr_telefonu
FROM klienci NATURAL JOIN adresy WHERE email IS NOT NULL AND nr_telefonu IS NOT NULL);

-- A3) Zamówienia wraz ze szczegółami.
CREATE VIEW zamowienia_szczegoly_A3_query AS(
SELECT id_zamowienia, id_klienta, data_zamowienia, COUNT(szczegoly_zamowienia) AS liczba_pozycji_zamowienia 
FROM zamowienia NATURAL JOIN szczegoly_zamowienia GROUP BY id_zamowienia, id_klienta, data_zamowienia ORDER BY id_zamowienia ASC);

-- A4) Produkty w zamówieniach.
CREATE VIEW zamowienia_produkty_A4_query AS(
SELECT id_zamowienia, id_produktu, nazwa_produktu, sklad_produktu, cena_produktu
FROM szczegoly_zamowienia NATURAL JOIN produkty ORDER BY id_zamowienia);

-- A5) Dodatki w zamówieniach.
CREATE VIEW zamowienia_dodatki_A5_query AS(
SELECT id_zamowienia, szczegoly_zamowienia.id_dodatku, nazwa_dodatku, cena_dodatku 
FROM szczegoly_zamowienia, dodatki WHERE dodatki.id_dodatku = szczegoly_zamowienia.id_dodatku
ORDER BY id_zamowienia);

-- A6) Liczba zamówień klienta.
CREATE VIEW liczba_zamowien_klientow_A6_query AS(
SELECT klienci.id_klienta, imie, nazwisko, COUNT(id_zamowienia) AS liczba_zamowien FROM zamowienia
INNER JOIN klienci ON klienci.id_klienta = zamowienia.id_klienta GROUP BY klienci.id_klienta); 
 
-- Zdefiniowanie kwerend złożonych.

-- B1) Dane na temat klientów, ilości punktów oraz liczby złożonych zamówień.
CREATE VIEW klienci_liczba_punktow_zamowien_B1_query AS(
SELECT klienci.id_klienta, imie, nazwisko, klienci.ilosc_punktow, COUNT(id_zamowienia) AS liczba_zamowien FROM zamowienia, klienci
WHERE klienci.id_klienta = zamowienia.id_klienta GROUP BY klienci.id_klienta ORDER BY ilosc_punktow DESC); 
 
-- B2) Informacje na temat danych klientów, ich zamówień oraz szczegołów zamówień wchodzących w skład zamówienia.
CREATE VIEW klienci_zamowienia_szczegoly_B2_query AS(
SELECT k.id_klienta, k.imie, k.nazwisko, sz.id_zamowienia, p.id_produktu, p.nazwa_produktu, d.id_dodatku, d.nazwa_dodatku, sz.cena
FROM klienci k, zamowienia z, szczegoly_zamowienia sz NATURAL LEFT JOIN produkty p NATURAL LEFT JOIN dodatki d
WHERE k.id_klienta = z.id_klienta AND z.id_zamowienia = sz.id_zamowienia);
 
-- B3) Informacje na temat klientów, ich adresów oraz danych logowania.
CREATE VIEW klienci_adresy_logowanie_B3_query AS(
SELECT k.id_klienta, k.imie, k.nazwisko, kd.login, kd.haslo, a.id_adresu, a.miejscowosc, a.ulica, a.nr_domu 
FROM klienci k NATURAL JOIN adresy a NATURAL LEFT JOIN klienci_dane_logowania kd ORDER BY id_klienta); 

-- B4) Klienci o największej liczbie punktów.
CREATE VIEW klienci_najwiecej_punktow_B4_query AS(
SELECT k.id_klienta, k.imie, k.nazwisko, k.ilosc_punktow, kd.login, kd.haslo, a.id_adresu, a.miejscowosc, a.ulica, a.nr_domu 
FROM klienci k NATURAL JOIN klienci_dane_logowania kd INNER JOIN adresy a ON a.id_adresu = k.id_adresu
WHERE k.ilosc_punktow = (SELECT MAX(ilosc_punktow) FROM klienci));

-- B5) Zamówienia wraz ze szczegółami, produktami wraz z pełnymi danymi produktów oraz pełnymi danymi klientów wraz z adresami klientów.
CREATE VIEW szczegoly_produkty_klientow_B5_query AS(
SELECT k.id_klienta, k.imie, k.nazwisko, a.id_adresu, a.miejscowosc, a.ulica, a.nr_domu, sz.id_zamowienia, p.id_produktu, p.nazwa_produktu, p.sklad_produktu, d.id_dodatku, d.nazwa_dodatku, sz.cena
FROM klienci k, adresy a, zamowienia z, szczegoly_zamowienia sz NATURAL LEFT JOIN produkty p NATURAL LEFT JOIN dodatki d
WHERE k.id_adresu = a.id_adresu AND k.id_klienta = z.id_klienta AND z.id_zamowienia = sz.id_zamowienia);

-- B6) Zamówienie wraz z ilością składowych oraz ceną.
CREATE VIEW zamowienia_skladowe_cena_B6_query AS(
SELECT z.id_zamowienia, COUNT(z.id_zamowienia) AS ilosc_skladowych_zamowienia, SUM(cena) AS kwota_zamowienia 
FROM zamowienia z INNER JOIN szczegoly_zamowienia sz ON z.id_zamowienia = sz.id_zamowienia
GROUP BY 1 ORDER BY 1);

-- B7) Zamówienie z łączną kwotą.
CREATE VIEW zamowienia_laczna_kwota_B7_query AS(
SELECT z.id_zamowienia AS zamowienie, 
(SELECT SUM(sz.cena) FROM szczegoly_zamowienia sz WHERE sz.id_zamowienia = z.id_zamowienia)
AS laczna_cena FROM zamowienia z GROUP BY z.id_zamowienia);

-- B8) Klienci bez konta.
CREATE VIEW klienci_bez_kont_B8_query AS(
SELECT k.id_klienta, (imie || ' ' || nazwisko)::varchar AS dane_osobowe, 
(SELECT id_adresu FROM adresy a WHERE a.id_adresu = k.id_adresu),
(SELECT miejscowosc FROM adresy a WHERE a.id_adresu = k.id_adresu),
(SELECT ulica FROM adresy a WHERE a.id_adresu = k.id_adresu),
TRUE AS brak_konta FROM klienci k
WHERE id_klienta NOT IN (SELECT id_klienta FROM klienci_dane_logowania)); 

-- B9) Klienci z największa liczbą zamówień.
CREATE VIEW klienci_najwiecej_zamowien_B9_query AS(
SELECT klienci.id_klienta, imie, nazwisko, klienci.ilosc_punktow, COUNT(id_zamowienia) AS liczba_zamowien FROM zamowienia, klienci
WHERE klienci.id_klienta = zamowienia.id_klienta GROUP BY klienci.id_klienta HAVING COUNT(id_zamowienia) = 
(SELECT MAX(ilosc) FROM (SELECT COUNT(id_zamowienia) AS ilosc FROM zamowienia GROUP BY id_klienta) AS c)
ORDER BY ilosc_punktow DESC);

-- B10) Klienci z najmniejszą liczbą zamówień.
CREATE VIEW klienci_najmniej_zamowien_B10_query AS(
SELECT klienci.id_klienta, imie, nazwisko, klienci.ilosc_punktow, COUNT(id_zamowienia) AS liczba_zamowien FROM zamowienia, klienci
WHERE klienci.id_klienta = zamowienia.id_klienta GROUP BY klienci.id_klienta HAVING COUNT(id_zamowienia) = 
(SELECT MIN(ilosc) FROM (SELECT COUNT(id_zamowienia) AS ilosc FROM zamowienia GROUP BY id_klienta) AS c)
ORDER BY ilosc_punktow DESC);

-- B11) Klienci z liczbą punktów większą od średniej liczby punktów klientów.
CREATE VIEW klienci_wiecej_niz_srednia_punktow_B11_query AS(
SELECT k.id_klienta, k.imie, k.nazwisko, kd.login, kd.haslo, a.id_adresu, a.miejscowosc, a.ulica, a.nr_domu, k.ilosc_punktow 
FROM klienci k NATURAL JOIN klienci_dane_logowania kd INNER JOIN adresy a ON a.id_adresu = k.id_adresu
WHERE k.ilosc_punktow >= (SELECT AVG(ilosc_punktow) FROM klienci));


-- Functions
-- 1) Dzień, w którym było najwięcej zamówień z danego przedziału dat
CREATE OR REPLACE FUNCTION zamowienia_max_dzien_tyg(data_poczatkowa DATE, data_koncowa DATE)
RETURNS VARCHAR AS
$ZAMOWIENIA_MAX_DZIEN_TYG$
DECLARE
    daty DATE[];
    dni_tygodnia INTEGER[7];
    dni_tygodnia_nazwy VARCHAR[7];
    dzien SMALLINT;
    rozmiar_daty INTEGER;
    i INTEGER := 0;
    max INTEGER := 0;
    ilosc_dat INTEGER := 0;
BEGIN
    IF data_poczatkowa > data_koncowa THEN
	RAISE NOTICE 'Błędne wywołanie! Data końcowa jest wcześniejsza od daty początkowej!';
	RETURN NULL;
    END IF;

    dni_tygodnia := ARRAY[0,0,0,0,0,0,0];
    dni_tygodnia_nazwy := ARRAY['poniedziałek','wtorek','środa','czwartek','piątek','sobota','niedziela'];

    ilosc_dat := (SELECT COUNT(data_zamowienia) FROM zamowienia WHERE data_zamowienia >= data_poczatkowa AND data_zamowienia <= data_koncowa);
    IF ilosc_dat = 0 THEN
       RAISE NOTICE 'Brak zamówień w tym przedziale!';
       RETURN NULL;
    END IF;   
    
    daty := ARRAY(SELECT data_zamowienia FROM zamowienia WHERE data_zamowienia >= data_poczatkowa AND data_zamowienia <= data_koncowa);
    rozmiar_daty := (SELECT array_length(daty, 1));
    
    LOOP
	i := i + 1;
	dzien = EXTRACT(dow FROM daty[i]);
	dni_tygodnia[dzien] := dni_tygodnia[dzien] + 1;
	RAISE NOTICE 'Dzień: %', dni_tygodnia;
	IF i = rozmiar_daty THEN
	   EXIT;
	END IF;   
    END LOOP;

    i := 0;
    max := 0;
    dzien := 0;
    LOOP 
	i := i + 1;
	IF dni_tygodnia[i] > max THEN 
	  dzien := i;
	  max := dni_tygodnia[i];
	END IF;  

	IF i = 7 THEN
	   EXIT;
	END IF;   	
    END LOOP;	

	RETURN dni_tygodnia_nazwy[dzien];  
END;
$ZAMOWIENIA_MAX_DZIEN_TYG$
LANGUAGE 'plpgsql';

-- 2) Funkcja - obliczanie rabatu
CREATE OR REPLACE FUNCTION oblicz_rabat(id_klienta INTEGER, wartosc_zamowienia NUMERIC)
RETURNS TABLE
(
    rabat VARCHAR,
    zamowienie_z_rabatem MONEY
)AS
$RABAT$
DECLARE
    punkty_klienta INTEGER;
    r VARCHAR;
    w NUMERIC;
BEGIN

    RAISE NOTICE 'Funkcja obliczająca rabat w zależności od punktów klienta 
    Zasady przyznawania rabatu: 500 punktów - 2000 punktów - 5 procent rabatu
    2001 punktów - 5000 punktów - 10 procent rabatu
    >5000 punktów - 10 zł + 5 procent rabatu';
    
    SELECT ilosc_punktow INTO punkty_klienta FROM klienci k WHERE k.id_klienta = $1;

    IF punkty_klienta < 500 THEN
       r := 'brak rabatu';
       w := $2;
    ELSIF punkty_klienta >= 500 AND punkty_klienta <= 2000 THEN
       r := '5% rabatu';
       w := $2 - ($2 * 0.05);
    ELSIF punkty_klienta >= 2001 AND punkty_klienta <= 5000 THEN
       r := '10% rabatu'; 
       w := $2 - ($2 * 0.1);
    ELSIF punkty_klienta > 5000 THEN
       r := '10zł + 5% rabatu';
       w := $1 - 10 - (($1 - 10)*0.05);
    END IF;    
    rabat := r;
    zamowienie_z_rabatem := w::MONEY;
    RETURN NEXT;
END;
$RABAT$ 
LANGUAGE 'plpgsql';

-- 3) Funkcja - hashowanie hasła
CREATE OR REPLACE FUNCTION hash(haslo VARCHAR, sposob_hashowania VARCHAR, liczba_iteracji INTEGER)
RETURNS TEXT AS
$HASH$
BEGIN
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
    IF $2 = 'md5' THEN
      RETURN md5($1);
    ELSIF $2 = 'crypt-md5' THEN
      RETURN crypt($1, gen_salt('md5')); 
    ELSIF $2 = 'crypt-bf' THEN
      RETURN crypt($1, gen_salt('bf',$3));  
    ELSIF $2 = 'crypt-xdes' THEN
      RETURN crypt($1, gen_salt('xdes'));
    ELSIF $2 = 'crypt-des' THEN
      RETURN crypt($1, gen_salt('des'));   
	ELSE
	  RAISE NOTICE 'Podano nieprawidłowy parametr!';
	  RETURN NULL;
    END IF;   
END;
$HASH$ 
LANGUAGE 'plpgsql';

-- 4) Funkcja - walidacja loginu
CREATE OR REPLACE FUNCTION sprawdz_login(login VARCHAR)
RETURNS BOOLEAN AS
$LOGIN$
BEGIN
   IF login ~ '[A-Za-z0-9]+$' THEN 
      RAISE NOTICE 'Nazwa użytkownika jest poprawna';
      RETURN TRUE;
   ELSE 
      RAISE NOTICE 'Wprowadzono niepoprawną nazwę użytkownika!';
      RETURN FALSE;
   END IF;       	
END;
$LOGIN$ 
LANGUAGE 'plpgsql';

-- 5) Funkcja - generacja rekordów
CREATE OR REPLACE FUNCTION generuj_rekordy()
RETURNS BOOLEAN AS
$GENERATOR$
DECLARE 
  i INTEGER := 0;
  imie VARCHAR [10];
  nazwisko VARCHAR [10];
  miejscowosc VARCHAR [10];
  ulica VARChAR [10];
  losowa1 INTEGER;
  losowa2 INTEGER;
  losowa3 INTEGER;
  rec RECORD;
  numer VARCHAR := '';
  losowa_data TIMESTAMP WITHOUT TIME ZONE;
BEGIN
   DELETE FROM szczegoly_zamowienia;
   DELETE FROM zamowienia;
   DELETE FROM klienci_dane_logowania;
   DELETE FROM klienci;
   DELETE FROM adresy;
   DELETE FROM punkty_zasady;
   DELETE FROM dodatki;
   DELETE FROM produkty;
   
   imie := ARRAY['Ernest', 'Grzegorz', 'Anna', 'Tomasz', 'Janusz', 'Łucja', 'Karolina', 'Józef', 'Elżbieta', 'Jan'];
   nazwisko := ARRAY['Bieś', 'Ptak', 'Sowa', 'Nowak', 'Kowalski', 'Dąb', 'Maj', 'Wiśniewski', 'Tokarczuk', 'Zięba'];
   miejscowosc := ARRAY['Dąbrowa Tarnowska', 'Tarnów', 'Żabno', 'Bolesław', 'Nieczajna Górna', 'Szczucin', 'Radgoszcz', 'Lisia Góra', 'Breń', 'Sieradza'];
   ulica := ARRAY['Owocowa', 'Leśna', 'Dąbrowskiego', 'Tarnowska', 'Żabieńska', 'Krajowa', 'Brzozowa', 'Mała', 'Duża', 'Kwadratowa'];
   LOOP
        losowa1 := (SELECT (random() * 9 + 1)::INTEGER);
        losowa2 := (SELECT (random() * 9 + 1)::INTEGER);
        losowa3 := (SELECT (random() * 100)::INTEGER);
	INSERT INTO adresy (miejscowosc, ulica, nr_domu) VALUES (miejscowosc[losowa1], ulica[losowa2], losowa3::VARCHAR);
   IF i = 100 THEN
      EXIT;
   END IF;   	
   i := i + 1;
   END LOOP;

   FOR rec IN (SELECT id_adresu FROM adresy) LOOP
        numer := '(0)';
        i := 0;
        LOOP 
        numer := (numer || (SELECT (random() * 9)::INTEGER::VARCHAR));
	  IF i = 8 THEN
            EXIT;
	  END IF;
	i := i + 1;  
        END LOOP;
	losowa1 := (SELECT (random() * 9 + 1)::INTEGER);
        losowa2 := (SELECT (random() * 9 + 1)::INTEGER);
        losowa3 := (SELECT (random() * 100)::INTEGER);

        IF (SELECT (random() * 2)::INTEGER) = 0 THEN
           numer := NULL;
        END IF;   
	INSERT INTO klienci (imie, nazwisko, email, nr_telefonu, id_adresu) VALUES (imie[losowa1], nazwisko[losowa1], (losowa3::VARCHAR|| '@email.com'), numer, rec.id_adresu);
   END LOOP;

   IF (SELECT COUNT(*) FROM punkty_zasady) = 0 THEN
	   INSERT INTO punkty_zasady VALUES (1, 50::MONEY, 10);
	   INSERT INTO punkty_zasady VALUES (2, 100::MONEY, 25);
	   INSERT INTO punkty_zasady VALUES (3, 150::MONEY, 40);
	   INSERT INTO punkty_zasady VALUES (4, 200::MONEY, 80);
	   INSERT INTO punkty_zasady VALUES (5, 250::MONEY, 100);
   END IF;	   

   FOR rec IN (SELECT * FROM klienci) LOOP
	IF (SELECT (random() * 3)::INTEGER) = 1 THEN
           INSERT INTO klienci_dane_logowania (id_klienta, login, haslo) VALUES (rec.id_klienta, (rec.imie || rec.id_klienta::VARCHAR), md5(rec.nazwisko));
        END IF;   
   END LOOP;

   IF (SELECT COUNT(*) FROM produkty) = 0 THEN
		INSERT INTO produkty (nazwa_produktu, sklad_produktu, cena_produktu) VALUES ('Pizza wegetariańska', 'sałata, pieczarka, ogórki, pomidory', 25);
        INSERT INTO produkty (nazwa_produktu, sklad_produktu, cena_produktu) VALUES ('Pizza wiejska', 'kiełbasa wiejska, boczek, ogórki, cebula' , 30);
        INSERT INTO produkty (nazwa_produktu, sklad_produktu, cena_produktu) VALUES ('Pizza owoce morza', 'krewetki, kukurydza, pomidory', 40);
        INSERT INTO produkty (nazwa_produktu, sklad_produktu, cena_produktu) VALUES ('Pizza margaritta', 'sos pomidorowy, pieczarki, żółty ser', 15);
        INSERT INTO produkty (nazwa_produktu, sklad_produktu, cena_produktu) VALUES ('Pizza szynka', 'szynka, pieczarki, żółty ser', 20);
        INSERT INTO produkty (nazwa_produktu, sklad_produktu, cena_produktu) VALUES ('Pizza firmowa', NULL, 50);
   END IF;

   IF (SELECT COUNT(*) FROM dodatki) = 0 THEN
	INSERT INTO dodatki (nazwa_dodatku, cena_dodatku) VALUES ('keczup', 5);
	INSERT INTO dodatki (nazwa_dodatku, cena_dodatku) VALUES ('oregano', 3);
	INSERT INTO dodatki (nazwa_dodatku, cena_dodatku) VALUES ('pietruszka', 2);
	INSERT INTO dodatki (nazwa_dodatku, cena_dodatku) VALUES ('majonez', 5);
   END IF;

   FOR rec IN (SELECT id_klienta FROM klienci) LOOP
	losowa1 := (SELECT (random() * 10 + 1)::INTEGER);
	i := 0;
	LOOP
	losowa_data := (SELECT '2019-01-01'::TIMESTAMP WITHOUT TIME ZONE + (random() * ('2019-12-30'::TIMESTAMP WITHOUT TIME ZONE -'2019-01-01'::TIMESTAMP WITHOUT TIME ZONE)));
	INSERT INTO zamowienia (id_klienta, data_zamowienia) VALUES (rec.id_klienta, losowa_data);
	   IF i = losowa1 THEN
	      EXIT;
	   END IF;   
	i := i + 1;   
	END LOOP;
   END LOOP;

   FOR rec IN (SELECT id_zamowienia FROM zamowienia) LOOP
        losowa1 := (SELECT (random() * 3 + 1)::INTEGER);
        i := 0;
	LOOP
	   losowa2 := (SELECT id_produktu FROM produkty ORDER BY random() LIMIT 1);
	   losowa3 := (SELECT id_dodatku FROM dodatki ORDER BY random() LIMIT 1);
	   IF (SELECT (random() * 2)::INTEGER) = 0 THEN
              losowa3 := NULL;
	   END IF;
	   INSERT INTO szczegoly_zamowienia (id_zamowienia, id_produktu, id_dodatku) VALUES (rec.id_zamowienia, losowa2, losowa3);
	IF i = losowa1 THEN
	   EXIT;
	END IF;   
	i := i + 1;
	END LOOP;
   END LOOP;
   RETURN TRUE; 
END;
$GENERATOR$ 
LANGUAGE 'plpgsql';

-- Generate records
SELECT generuj_rekordy();