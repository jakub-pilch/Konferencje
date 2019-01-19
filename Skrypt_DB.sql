USE master
IF EXISTS(SELECT *
          FROM sys.databases
          where name = 'Konferencje')
  DROP DATABASE Konferencje

CREATE DATABASE Konferencje

USE Konferencje

IF OBJECT_ID('CennikKonferencji', 'U') IS NOT NULL
  DROP TABLE CennikKonferencji

IF OBJECT_ID('Lokalizacje', 'U') IS NOT NULL
  DROP TABLE Lokalizacje

IF OBJECT_ID('Konferencje', 'U') IS NOT NULL
  DROP TABLE Konferencje
IF OBJECT_ID('DniKonferencji', 'U') IS NOT NULL
  DROP TABLE DniKonferencji

IF OBJECT_ID('Warsztaty', 'U') IS NOT NULL
  DROP TABLE Warsztaty

IF OBJECT_ID('Klienci', 'U') IS NOT NULL
  DROP TABLE Klienci

IF OBJECT_ID('RezerwacjeDni', 'U') IS NOT NULL
  DROP TABLE RezerwacjeDni

IF OBJECT_ID('RezerwacjeWarsztatow', 'U') IS NOT NULL
  DROP TABLE RezerwacjeWarsztatow

IF OBJECT_ID('UczestnicyKonferencji', 'U') IS NOT NULL
  DROP TABLE UczestnicyKonferencji

IF OBJECT_ID('UczestnicyWarsztatow', 'U') IS NOT NULL
  DROP TABLE UczestnicyWarsztatow

IF OBJECT_ID('Studenci', 'U') IS NOT NULL
  DROP TABLE Studenci

IF OBJECT_ID('Platnosci', 'U') IS NOT NULL
  DROP TABLE Platnosci

CREATE TABLE CennikKonferencji (
  ID_Cennika      int   not null primary key identity (1, 1),
  Cena            money not null,
  ZnizkaStudencka float not null,
  ProgI           float not null,
  ProgII          float not null,
  ProgIII         float not null,
  CHECK (ProgI < ProgII)
)

CREATE TABLE Lokalizacje (
  ID_Lokalizacji int         not null primary key identity (1, 1),
  Miasto         varchar(16) not null,
  Ulica          varchar(16) not null,
  KodPocztowy    varchar(8)  not null,
  NumerBudynku   smallint    not null
)

CREATE TABLE Konferencje (
  ID_Konferencji   int         not null primary key identity (1, 1),
  Nazwa            varchar(24) not null,
  DzienRozpoczecia date        not null,
  DzienZakonczenia date        not null,
  ID_Cernnika      int         not null foreign key references CennikKonferencji (ID_Cennika),
  Lokalizacja      int         not null foreign key references Lokalizacje (ID_Lokalizacji),
  CHECK (DzienZakonczenia >= DzienRozpoczecia)
)


CREATE TABLE DniKonferencji (
  ID_Dnia        int  not null primary key identity (1, 1),
  ID_Konferencji int  not null foreign key references Konferencje (ID_Konferencji),
  Data           date not null,
  LiczbaMiejsc   int  not null
)

CREATE TABLE Warsztaty (
  ID_Warsztatu    int           not null primary key identity (1, 1),
  ID_Dnia         int           not null foreign key references DniKonferencji (ID_Dnia),
  Rozpoczecie     time          not null,
  Zakonczenie     time          not null,
  LiczbaMiejsc    int           not null,
  Cena            decimal(4, 2) null,
  ZnizkaStudencka decimal(4, 2) null,
  CHECK (Rozpoczecie < Zakonczenie)
)

CREATE TABLE Klienci (
  ID_Klienta   int         not null primary key identity (1, 1),
  Nazwa        varchar(16) null,
  NIP          int         null unique,
  Imie         varchar(16) not null,
  Nazwisko     varchar(16) not null,
  Miasto       varchar(16) not null,
  Ulica        varchar(16) not null,
  Kod_pocztowy varchar(8)  not null,
  NrBudynku    smallint    not null,
  Telefon      int         null,
  E_Mail       int         null
)

CREATE TABLE RezerwacjeDni (
  ID_Rezerwacji  int      not null primary key identity (1, 1),
  ID_Klienta     int      not null foreign key references Klienci (ID_Klienta),
  ID_Dnia        int      not null foreign key references DniKonferencji (ID_Dnia),
  LiczbaMiejsc   smallint not null,
  DataRezerwacji date     not null,
)

CREATE TABLE RezerwacjeWarsztatow (
  ID_Rezerwacji  int  not null primary key identity (1, 1),
  RezerwacjaDnia int  not null foreign key references RezerwacjeDni (ID_Rezerwacji),
  LiczbaMiejsc   int  not null,
  ID_Warsztatu   int  not null foreign key references Warsztaty (ID_Warsztatu),
  DataRezerwacji date not null
)

CREATE TABLE UczestnicyKonferencji (
  ID_Uczestnika int         not null primary key identity (1, 1),
  Imie          varchar(16) not null,
  Nazwisko      varchar(16) not null,
  Rezerwacja    int         not null foreign key references RezerwacjeDni (ID_Rezerwacji)
)

CREATE TABLE UczestnicyWarsztatow (
  ID_Uczestnika int not null primary key references UczestnicyKonferencji (ID_Uczestnika),
  ID_Rezerwacji int not null foreign key references RezerwacjeWarsztatow (ID_Rezerwacji)
)

CREATE TABLE Studenci (
  ID_Uczestnika int not null primary key references UczestnicyKonferencji (ID_Uczestnika),
  NrLegitymacji int not null
)

CREATE TABLE Platnosci (
  ID_Platnosci        int   not null primary key identity (1, 1),
  DataPlatnosci       date  not null,
  RezerwacjaDnia      int   null foreign key references RezerwacjeDni (ID_Rezerwacji),
  RezerwacjaWarsztatu int   null foreign key references RezerwacjeWarsztatow (ID_Rezerwacji),
  Kwota               money not null
)


GO
----------------- Funkcje

IF OBJECT_ID('WolneMiejscaWarsztat', N'FN') IS NOT NULL
  DROP FUNCTION WolneMiejscaWarsztat
GO

IF OBJECT_ID('WolneMiejscaDzienKonferencji', N'FN') IS NOT NULL
  DROP FUNCTION WolneMiejscaDzienKonferencji
GO

IF OBJECT_ID('CenaRezerwacjiDniaKonferencji', N'FN') IS NOT NULL
  DROP FUNCTION CenaRezerwacjiDniaKonferencji
GO

CREATE FUNCTION WolneMiejscaWarsztat(@ID_Warsztatu int)
  RETURNS INT
AS

  BEGIN
    DECLARE @Liczba_miejsc AS int;
    SET @Liczba_miejsc = (SELECT LiczbaMiejsc FROM Warsztaty WHERE ID_Warsztatu = @ID_Warsztatu);

    DECLARE @Zarezerwowane AS int;
    SET @Zarezerwowane = (SELECT SUM(LiczbaMiejsc) FROM RezerwacjeWarsztatow WHERE ID_Warsztatu = @ID_Warsztatu);

    IF @Zarezerwowane IS NULL
      SET @Zarezerwowane = 0;

    RETURN (@Liczba_miejsc - @Zarezerwowane);
  END

GO

CREATE FUNCTION WolneMiejscaDzienKonferencji(@ID_Dnia int)
  RETURNS int
AS
  BEGIN

    DECLARE @Liczba_Miejsc AS int;
    SET @Liczba_Miejsc = (SELECT LiczbaMiejsc FROM DniKonferencji WHERE ID_Dnia = @ID_Dnia);

    DECLARE @Zarezerwowane AS int;
    SET @Zarezerwowane = (SELECT SUM(LiczbaMiejsc) FROM RezerwacjeDni WHERE ID_Dnia = @ID_Dnia);

    IF @Zarezerwowane IS NULL
      SET @Zarezerwowane = 0

    RETURN (@Liczba_Miejsc - @Zarezerwowane)

  END
GO

CREATE FUNCTION CenaRezerwacjiDniaKonferencji(@ID_Rezerwacji int)
  RETURNS int
AS
  BEGIN
    DECLARE @TygodnieDoKonferencji AS int;
    SET @TygodnieDoKonferencji = (SELECT DATEDIFF(week, DataRezerwacji, (SELECT Data
                                                                         FROM DniKonferencji
                                                                         WHERE R.ID_Dnia = DniKonferencji.ID_Dnia))
                                  FROM RezerwacjeDni AS R
                                  WHERE ID_Rezerwacji = @ID_Rezerwacji)
    DECLARE @CenaZaOsobe AS money;

    IF @TygodnieDoKonferencji <= 4
      SET @CenaZaOsobe = (SELECT (Cena * ProgI)
                          FROM RezerwacjeDni AS R
                                 JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                 JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                 JOIN CennikKonferencji C on K.ID_Cernnika = C.ID_Cennika)
    ELSE IF @TygodnieDoKonferencji <= 2
      SET @CenaZaOsobe = (SELECT (Cena * ProgII)
                          FROM RezerwacjeDni AS R
                                 JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                 JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                 JOIN CennikKonferencji C on K.ID_Cernnika = C.ID_Cennika)
    ELSE
      SET @CenaZaOsobe = (SELECT (Cena * ProgIII)
                          FROM RezerwacjeDni AS R
                                 JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                 JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                 JOIN CennikKonferencji C on K.ID_Cernnika = C.ID_Cennika)

    DECLARE @ZnizkaStudencka AS float;
    SET @ZnizkaStudencka = (SELECT ZnizkaStudencka
                            FROM RezerwacjeDni AS R
                                   JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                   JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                   JOIN CennikKonferencji C on K.ID_Cernnika = C.ID_Cennika)

    DECLARE @LiczbaOsob AS int;
    SET @LiczbaOsob = (SELECT LiczbaMiejsc FROM RezerwacjeDni WHERE ID_Rezerwacji = @ID_Rezerwacji)

    DECLARE @LiczbaStudentow AS int;
    SET @LiczbaStudentow = (SELECT COUNT(*)
                            FROM RezerwacjeDni AS R
                                   JOIN UczestnicyKonferencji AS K ON K.Rezerwacja = R.ID_Rezerwacji
                                   JOIN Studenci S2 on K.ID_Uczestnika = S2.ID_Uczestnika)

    RETURN (@CenaZaOsobe * @ZnizkaStudencka * @LiczbaStudentow) + (@CenaZaOsobe * (@LiczbaOsob - @LiczbaStudentow))
  END
GO

-------------------------- Procedury


-------------------------- Procedury wstawiania danych

IF OBJECT_ID('DodajUczestnikaKonferencji', 'P') IS NOT NULL
  DROP PROCEDURE DodajUczestnikaKonferencji

IF OBJECT_ID('DodajUczestnikaKonferencji', 'P') IS NOT NULL
  DROP PROCEDURE DodajUczestnikaWarsztatu

IF OBJECT_ID('DodajPlatnosc', 'P') IS NOT NULL
  DROP PROCEDURE DodajPlatnosc

IF OBJECT_ID('DodajLokalizacje', 'P') IS NOT NULL
  DROP PROCEDURE DodajLokalizacje

GO

CREATE PROCEDURE DodajUczestnikaKonferencji
  (@ID_Rezerwacji    int,
   @Imie             varchar(16),
   @Nazwisko         varchar(16),
   @NumerLegitymacji int)
AS
  BEGIN
    SET NOCOUNT ON;

    INSERT INTO UczestnicyKonferencji VALUES (@Imie, @Nazwisko, @ID_Rezerwacji);

    IF @NumerLegitymacji IS NOT NULL
      BEGIN
        DECLARE @ID_Uczestnika AS int;
        SET @ID_Uczestnika = (SELECT ID_Uczestnika
                              FROM UczestnicyKonferencji AS UK
                              WHERE UK.Imie = @Imie
                                AND UK.Nazwisko = @Nazwisko
                                AND UK.Rezerwacja = @ID_Rezerwacji);

        INSERT INTO Studenci VALUES (@ID_Uczestnika, @NumerLegitymacji)
      END
  END

GO

CREATE PROCEDURE DodajUczestnikaWarsztatu
  (@ID_Rezerwacji            int,
   @ID_UczestnikaKonferencji int)
AS
  BEGIN
    SET NOCOUNT ON;

    INSERT INTO UczestnicyWarsztatow VALUES (@ID_UczestnikaKonferencji, @ID_Rezerwacji)

  END
GO

CREATE PROCEDURE DodajPlatnosc
  (@DataPlatnosci       date,
   @RezerwacjaWarsztatu bit,
   @ID_Rezerwacji       int,
   @Kwota               money)
AS
  BEGIN
    IF @RezerwacjaWarsztatu = 1
      BEGIN
        INSERT INTO Platnosci VALUES (@DataPlatnosci, NULL, @ID_Rezerwacji, @Kwota)
      END
    ELSE
      BEGIN
        INSERT INTO Platnosci VALUES (@DataPlatnosci, @ID_Rezerwacji, NULL, @Kwota)
      END
  END
Go

CREATE PROCEDURE DodajLokalizacje
  (@Miasto       varchar(16),
   @Ulica        varchar(16),
   @KodPocztowy  varchar(8),
   @NumerBudynku smallint)
AS
  BEGIN
    INSERT INTO Lokalizacje VALUES (@Miasto, @Ulica, @KodPocztowy, @NumerBudynku)
  END
Go

CREATE PROCEDURE DodajCennik
  (@Cena            money,
   @ZnizkaStudencka float,
   @ProgI           float,
   @ProgII          float,
   @ProgIII         float)
AS
  BEGIN
    INSERT INTO CennikKonferencji VALUES (@Cena, @ZnizkaStudencka, @ProgI, @ProgII, @ProgIII)
  END
GO