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

GO

CREATE TABLE CennikKonferencji (
  ID_Cennika      int   not null primary key identity (1, 1),
  Cena            money not null,
  ZnizkaStudencka float not null,
  ProgI           float not null,
  ProgII          float not null,
  CONSTRAINT PoprawneZnizki CHECK (ProgI < ProgII)
)

CREATE TABLE Lokalizacje (
  ID_Lokalizacji int         not null primary key identity (1, 1),
  Miasto         varchar(30) not null,
  Ulica          varchar(30) not null,
  KodPocztowy    varchar(8)  not null,
  NumerBudynku   smallint    not null,
  Constraint Lokalizacje_PoprawnyKodPocztowy Check (KodPocztowy like '[0-9][0-9]-[0-9][0-9][0-9]')
)

CREATE TABLE Konferencje (
  ID_Konferencji   int         not null primary key identity (1, 1),
  Nazwa            varchar(30) not null,
  DzienRozpoczecia date        not null,
  DzienZakonczenia date        not null,
  ID_Cennika       int         not null foreign key references CennikKonferencji (ID_Cennika),
  Lokalizacja      int         not null foreign key references Lokalizacje (ID_Lokalizacji),
  Constraint PoprawneDaty CHECK (DzienZakonczenia >= DzienRozpoczecia)
)

CREATE TABLE DniKonferencji (
  ID_Dnia        int  not null primary key identity (1, 1),
  ID_Konferencji int  not null foreign key references Konferencje (ID_Konferencji),
  Data           date not null,
  LiczbaMiejsc   int  not null,
  Constraint Dni_PoprawnaLiczbaMiejsc CHECK (LiczbaMiejsc > 0)
)

CREATE TABLE Warsztaty (
  ID_Warsztatu    int           not null primary key identity (1, 1),
  ID_Dnia         int           not null foreign key references DniKonferencji (ID_Dnia),
  Rozpoczecie     time          not null,
  Zakonczenie     time          not null,
  LiczbaMiejsc    int           not null,
  Cena            decimal(4, 2) null,
  ZnizkaStudencka decimal(4, 2) null,
  Constraint PoprawneNastepstwoCzasu CHECK (Rozpoczecie < Zakonczenie),
  Constraint Warsztaty_PoprawnaLiczbaMiejsc CHECK (LiczbaMiejsc > 0)
)
CREATE TABLE Klienci (
  ID_Klienta  int         not null primary key identity (1, 1),
  Nazwa       varchar(30) null,
  NIP         char(9)     null,
  Imie        varchar(30) not null,
  Nazwisko    varchar(30) not null,
  Miasto      varchar(30) not null,
  Ulica       varchar(30) not null,
  KodPocztowy varchar(8)  not null,
  NrBudynku   smallint    not null,
  NrLokalu    smallint    null,
  Telefon     varchar(20) null,
  EMail       varchar(30) null,
  Constraint PoprawnyNip Check (NIP LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  Constraint Klienci_PoprawnyKodPocztowy Check (KodPocztowy like '[0-9][0-9]-[0-9][0-9][0-9]')
)

CREATE TABLE RezerwacjeDni (
  ID_Rezerwacji  int      not null primary key identity (1, 1),
  ID_Klienta     int      not null foreign key references Klienci (ID_Klienta),
  ID_Dnia        int      not null foreign key references DniKonferencji (ID_Dnia),
  LiczbaMiejsc   smallint not null,
  DataRezerwacji date     not null,
  Constraint PoprawnaLiczbaMiejsc CHECK (LiczbaMiejsc > 0)
)

CREATE TABLE RezerwacjeWarsztatow (
  ID_Rezerwacji  int  not null primary key identity (1, 1),
  RezerwacjaDnia int  not null foreign key references RezerwacjeDni (ID_Rezerwacji),
  LiczbaMiejsc   int  not null,
  ID_Warsztatu   int  not null foreign key references Warsztaty (ID_Warsztatu),
  DataRezerwacji date not null,
  Constraint PoprawnaLiczbaMiejsc CHECK (LiczbaMiejsc > 0)
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
  ID_Uczestnika int        not null primary key references UczestnicyKonferencji (ID_Uczestnika),
  NrLegitymacji varchar(6) not null
)

CREATE TABLE Platnosci (
  ID_Platnosci        int           not null primary key identity (1, 1),
  DataPlatnosci       date          not null,
  RezerwacjaDnia      int           null foreign key references RezerwacjeDni (ID_Rezerwacji),
  RezerwacjaWarsztatu int           null foreign key references RezerwacjeWarsztatow (ID_Rezerwacji),
  Kwota               decimal(8, 2) not null,
  Constraint PoprawnaKwota CHECK (Kwota > 0)
)

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
      SET @CenaZaOsobe = (SELECT (Cena)
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
    BEGIN TRY
    BEGIN TRANSACTION
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
    COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
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

if OBJECT_ID('DodajKlienta', N'P') is not null
  drop procedure DodajKlienta
GO

CREATE PROCEDURE DodajKlienta(
  @Nazwa       varchar(30) = null,
  @NIP         char(9) = null,
  @Imie        varchar(30),
  @Nazwisko    varchar(30),
  @Miasto      varchar(30),
  @Ulica       varchar(30),
  @KodPocztowy varchar(8),
  @NrBudynku   smallint,
  @NrLokalu    smallint = null,
  @Telefon     varchar(20) = null,
  @Email       varchar(30) = null
)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF @Imie IS NULL OR @Nazwisko IS NULL
      THROW 51000, 'Brak imienia lub nazwiska', 1
    IF @Miasto IS NULL OR @Ulica IS NULL OR @KodPocztowy IS NULL OR @KodPocztowy NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9]'
       OR @NrBudynku IS NULL
      THROW 51000, 'Adres jest niepelny', 1
    IF @NIP IS NOT NULL AND @NIP NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
      THROW 51000, 'NIP jest niepoprawny', 1
    INSERT into Klienci (Nazwa, NIP, Imie, Nazwisko, Miasto, Ulica, KodPocztowy, NrBudynku, NrLokalu, Telefon, EMail)
    VALUES (@Nazwa, @NIP, @Imie, @Nazwisko, @Miasto, @Ulica, @KodPocztowy, @NrBudynku, @NrLokalu, @Telefon, @Email)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO

IF OBJECT_ID('DodajKonferencje', 'P') IS NOT NULL
  DROP PROCEDURE DodajKonferencje
GO

CREATE PROCEDURE DodajKonferencje(
  @Nazwa            varchar(24),
  @DzienRozpoczecia date,
  @DzienZakonczenia date,
  @ID_Cennika       int,
  @Lokalizacja      int
)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    INSERT INTO Konferencje (Nazwa, DzienRozpoczecia, DzienZakonczenia, ID_Cennika, Lokalizacja)
    VALUES (@Nazwa, @DzienRozpoczecia, @DzienZakonczenia, @ID_Cennika, @Lokalizacja)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO

IF OBJECT_ID('DodajDzienKonferencji', 'P') IS NOT NULL
  DROP PROCEDURE DodajDzienKonferencji
GO

CREATE PROCEDURE DodajDzienKonferencji(
  @ID_Konferencji int,
  @Data           date,
  @LiczbaMiejsc   int
)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    INSERT INTO DniKonferencji (ID_Konferencji, Data, LiczbaMiejsc)
    VALUES (@ID_Konferencji, @Data, @LiczbaMiejsc)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO

if OBJECT_ID('DodajWarsztat', N'P') is not null
  drop procedure DodajWarsztat
GO

CREATE PROCEDURE DodajWarsztat(
  @ID_Dnia         int,
  @Rozpoczecie     time,
  @Zakonczenie     time,
  @LiczbaMiejsc    int,
  @Cena            decimal(4, 2) = null,
  @ZnizkaStudencka decimal(4, 2) = null
)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF @ID_Dnia IS NULL
      THROW 51000, 'ID_Dnia jest nullem', 1
    IF @Rozpoczecie IS NULL OR @Zakonczenie IS NULL OR @Zakonczenie <= @Rozpoczecie
      THROW 51000, 'Niepoprawnie podany czas', 1
    IF @LiczbaMiejsc IS NOT NULL or @LiczbaMiejsc <= 0
      THROW 51000, 'Niepoprawna liczba miejsc', 1
    INSERT into Warsztaty (ID_Dnia, Rozpoczecie, Zakonczenie, LiczbaMiejsc, Cena, ZnizkaStudencka)
    VALUES (@ID_Dnia, @Rozpoczecie, @Zakonczenie, @LiczbaMiejsc, @Cena, @ZnizkaStudencka)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO

if OBJECT_ID('DodajRezerwacjeDnia', N'P') is not null
  drop procedure DodajRezerwacjeDnia
GO

CREATE PROCEDURE DodajRezerwacjeDnia(
  @ID_Klienta     int,
  @ID_Dnia        int,
  @LiczbaMiejsc   smallint,
  @DataRezerwacji date
)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF @ID_Klienta IS NULL
      THROW 51000, 'ID_Klienta jest nullem', 1
    IF @ID_Dnia IS NULL
      THROW 51000, 'ID_Dnia jest nullem', 1
    IF @LiczbaMiejsc IS NOT NULL or @LiczbaMiejsc <= 0
      THROW 51000, 'Niepoprawna liczba miejsc', 1
    IF dbo.WolneMiejscaDzienKonferencji(@ID_Dnia) >= @LiczbaMiejsc
      BEGIN
        INSERT into RezerwacjeDni (ID_Klienta, ID_Dnia, LiczbaMiejsc, DataRezerwacji)
        VALUES (@ID_Klienta, @ID_Dnia, @LiczbaMiejsc, @DataRezerwacji)
      END
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO

--Modyfikacje

if OBJECT_ID('ZmianaDanychKlienta', N'P') is not null
  drop procedure ZmianaDanychKlienta
GO

CREATE PROCEDURE ZmianaDanychKlienta(
  @ID_Klienta  int,
  @Imie        varchar(30), --zmiana imienia i nazwiska (?)
  @Nazwisko    varchar(30),
  @Miasto      varchar(30),
  @Ulica       varchar(30),
  @KodPocztowy varchar(8),
  @NrBudynku   smallint,
  @NrLokalu    smallint = null,
  @Telefon     varchar(20) = null,
  @Email       varchar(30) = null
)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF @Imie IS NOT NULL AND @Nazwisko IS NOT NULL
      UPDATE KLIENCI
      SET Imie     = @imie,
          Nazwisko = @Nazwisko
      where ID_Klienta = @ID_Klienta
    ELSE IF @Miasto IS NOT NULL AND @Ulica IS NOT NULL AND
            @KodPocztowy IS NOT NULL AND @NrBudynku IS NOT NULL
      UPDATE KLIENCI
      SET Miasto      = @Miasto,
          Ulica       = @Ulica,
          KodPocztowy = @KodPocztowy,
          NrBudynku   = @NrBudynku
      where ID_Klienta = @ID_Klienta

    IF @NrLokalu IS NOT NULL
      UPDATE TKLIENCI SET NrLokalu = @NrLokalu where ID_Klienta = @ID_Klienta
    ELSE IF @Telefon IS NOT NULL
      UPDATE KLIENCI SET Telefon = @Telefon where ID_Klienta = @ID_Klienta
    ELSE IF @EMail IS NOT NULL
      UPDATE KLIENCI SET EMail = @EMail where ID_Klienta = @ID_Klienta
    ELSE
      THROW 51000, 'Podales nieprawidlowe dane', 1
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO


if OBJECT_ID('UsuniecieKonferencji', N'P') is not null
  drop procedure UsuniecieKonferencji
GO

CREATE PROCEDURE UsuniecieKonferencji
    @ID_Konferencji int
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF @ID_Konferencji IS NULL
      THROW 51000, 'ID_Konferencji jest nullem', 1
    IF EXISTS
    (select ID_Rezerwacji
     from RezerwacjeDni
     where ID_Dnia in
           (select ID_Dnia from DniKonferencji where ID_Konferencji = @ID_Konferencji))
      THROW 51001, 'Nie mozesz usunac konferencji - istnieje juz dla niej rezerwacja', 1
    DELETE FROM Warsztaty
    where ID_Dnia in
          (select ID_Dnia from DniKonferencji where ID_Konferencji = @ID_Konferencji)
    DELETE FROM DniKonferencji where ID_Konferencji = @ID_Konferencji
    DELETE FROM Konferencje where ID_Konferencji = @ID_Konferencji
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO


if OBJECT_ID('UsuniecieWarsztatu', N'P') is not null
  drop procedure UsuniecieWarsztatu
GO

CREATE PROCEDURE UsuniecieWarsztatu(
  @ID_Warsztatu int
)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF @ID_Warsztatu IS NULL
      THROW 51000, 'ID_Warsztatu jest nullem', 1
    IF EXISTS
    (select ID_Rezerwacji from RezerwacjeWarsztatow where ID_Warsztatu = @ID_Warsztatu)
      DELETE FROM Warsztaty where ID_Warsztatu = @ID_Warsztatu
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    END CATCH
  END
GO

-- Widoki

if OBJECT_ID('NadchodzaceKonferencje', N'V') is not null
  drop VIEW NadchodzaceKonferencje
GO

CREATE VIEW NadchodzaceKonferencje
  AS
    SELECT ID_Konferencji,
           Nazwa,
           Miasto + ', ' + Ulica + ' ' + NumerBudynku + ', ' + KodPocztowy as Adres,
           DzienRozpoczecia,
           DzienZakonczenia,
           DATEDIFF(dd, DzienRozpoczecia, DzienZakonczenia)                as [Czas Trwania]
    FROM Konferencje k
           join Lokalizacje l ON k.Lokalizacja = l.ID_Lokalizacji
    WHERE DzienRozpoczecia > GETDATE()
GO


if OBJECT_ID('NadchodzaceWarsztaty', N'V') is not null
  drop VIEW NadchodzaceWarsztaty
GO

CREATE VIEW NadchodzaceWarsztaty
  AS
    SELECT ID_Warsztatu,
           k.Nazwa                                as [Nazwa konferencji],
           Data,
           Rozpoczecie,
           Zakonczenie,
           Cena,
           ZnizkaStudencka,
           w.LiczbaMiejsc,
           dbo.WolneMiejscaWarsztat(ID_Warsztatu) as [Wolne miejsca]
    FROM Warsztaty w
           join DniKonferencji dk on w.ID_Dnia = dk.ID_Dnia
           join Konferencje k ON k.ID_Konferencji = dk.ID_Konferencji
    WHERE DzienRozpoczecia > GETDATE()
GO

if OBJECT_ID('NajpopularniejszeKonferencje', N'V') is not null
  drop VIEW NajpopularniejszeKonferencje
GO

CREATE VIEW NajpopularniejszeKonferencje
  AS
    SELECT k.ID_Konferencji,
           Nazwa                                       as [Nazwa konferencji],
           sum(rd.LiczbaMiejsc) / sum(dk.LiczbaMiejsc) as [Stosunek zajetych do wszystkich]
    FROM Konferencje k
           left join DniKonferencji dk ON k.ID_Konferencji = dk.ID_Konferencji
           left join RezerwacjeDni rd on rd.ID_Dnia = dk.ID_Dnia
    Group by k.ID_Konferencji, Nazwa
GO


if OBJECT_ID('NajpopularniejszeWarsztaty', N'V') is not null
  drop VIEW NajpopularniejszeWarsztaty
GO

CREATE VIEW NajpopularniejszeWarsztaty
  AS
    SELECT w.ID_Warsztatu, sum(rw.LiczbaMiejsc) / sum(w.LiczbaMiejsc) as [Stosunek zajetych do wszystkich]
    FROM Warsztaty w
           left join RezerwacjeWarsztatow rw on rw.ID_Warsztatu = w.ID_Warsztatu
    Group by w.ID_Warsztatu
GO

if OBJECT_ID('NaleznosciKlientow', N'V') is not null
  drop VIEW NaleznosciKlientow
GO

CREATE VIEW NaleznosciKlientow
  AS
    SELECT k.ID_Klienta,
           dbo.CenaRezerwacjiDniaKonferencji(rd.ID_Rezerwacji) + sum(rw.LiczbaMiejsc * w.Cena) as [Zalegla oplata]
    FROM RezerwacjeDni rd
           join RezerwacjeWarsztatow rw on rw.ID_Rezerwacji = rd.ID_Dnia
           join Warsztaty w on w.ID_Warsztatu = rw.ID_Warsztatu
           right join Klienci k on rd.ID_Klienta = k.ID_Klienta
           left join Platnosci p on p.RezerwacjaDnia = rd.ID_Rezerwacji or p.RezerwacjaWarsztatu = rw.ID_Rezerwacji
    where (p.RezerwacjaDnia != rd.ID_Rezerwacji and p.RezerwacjaWarsztatu is null)
       or (p.RezerwacjaWarsztatu = rw.ID_Rezerwacji and p.RezerwacjaDnia is null)
    Group by k.ID_Klienta, rd.ID_Rezerwacji
GO


if OBJECT_ID('NaleznosciKlientowPoTerminie', N'V') is not null
  drop VIEW NaleznosciKlientowPoTerminie
GO

CREATE VIEW NaleznosciKlientowPoTerminie
  AS
    SELECT k.ID_Klienta,
           dbo.CenaRezerwacjiDniaKonferencji(rd.ID_Rezerwacji) + sum(rw.LiczbaMiejsc * w.Cena) as [Zalegla oplata]
    FROM RezerwacjeDni rd
           join RezerwacjeWarsztatow rw on rw.ID_Rezerwacji = rd.ID_Dnia
           join Warsztaty w on w.ID_Warsztatu = rw.ID_Warsztatu
           join DniKonferencji dk on dk.ID_Dnia = rd.ID_Dnia
           right join Klienci k on rd.ID_Klienta = k.ID_Klienta
           left join Platnosci p on p.RezerwacjaDnia = rd.ID_Rezerwacji or p.RezerwacjaWarsztatu = rw.ID_Rezerwacji
    where ((p.RezerwacjaDnia != rd.ID_Rezerwacji and p.RezerwacjaWarsztatu is null)
             or
           (p.RezerwacjaWarsztatu = rw.ID_Rezerwacji and p.RezerwacjaDnia is null))
      and DATEDIFF(dd, dk.Data, GetDate()) >= 7
    Group by k.ID_Klienta, rd.ID_Rezerwacji
GO

-- Procedury zwracaj¹ce dane
if OBJECT_ID('WarsztatyDlaKonferencji', N'P') is not null
  drop PROCEDURE WarsztatyDlaKonferencji
GO

CREATE PROCEDURE WarsztatyDlaKonferencji(
  @ID_Konferencji int
)
AS
  BEGIN
    IF @ID_Konferencji IS NULL
      THROW 51000, 'ID_Konferencji jest nullem', 1
    SELECT ID_Warsztatu,
           k.Nazwa                                as [Nazwa konferencji],
           Data,
           Rozpoczecie,
           Zakonczenie,
           Cena,
           ZnizkaStudencka,
           w.LiczbaMiejsc,
           dbo.WolneMiejscaWarsztat(ID_Warsztatu) as [Wolne miejsca]
    FROM Warsztaty w
           join DniKonferencji dk on w.ID_Dnia = dk.ID_Dnia
           join Konferencje k ON k.ID_Konferencji = dk.ID_Konferencji
    WHERE k.ID_Konferencji = @ID_Konferencji
  END
GO

