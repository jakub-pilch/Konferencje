USE master
IF EXISTS(SELECT *
          FROM sys.databases
          where name = 'Konferencje')
  DROP DATABASE Konferencje

CREATE DATABASE Konferencje
GO

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

IF OBJECT_ID('Uczestnicy', 'U') IS NOT NULL
  DROP TABLE Uczestnicy

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
  CONSTRAINT Cennik_CKPoprawnaCena CHECK (Cena >= 0),
  CONSTRAINT PoprawneZnizki CHECK (ProgI < ProgII AND (ProgI BETWEEN 0 AND 1) AND (ProgII BETWEEN 0 AND 1)),
  CONSTRAINT Cennik_CKUnikalny UNIQUE NONCLUSTERED (Cena, ZnizkaStudencka, ProgI, ProgII)
)

CREATE TABLE Lokalizacje (
  ID_Lokalizacji int         not null primary key identity (1, 1),
  Miasto         varchar(30) not null,
  Ulica          varchar(100) not null,
  KodPocztowy    varchar(8)  not null,
  NumerBudynku   smallint    not null,
  Constraint Lokalizacje_PoprawnyKodPocztowy Check (KodPocztowy like '[0-9][0-9]-[0-9][0-9][0-9]'),
  CONSTRAINT Lokalizacje_CKUnikalne UNIQUE NONCLUSTERED (Miasto, Ulica, KodPocztowy, NumerBudynku)
)

CREATE TABLE Konferencje (
  ID_Konferencji   int          not null primary key identity (1, 1),
  Nazwa            varchar(255) not null,
  DzienRozpoczecia date         not null,
  DzienZakonczenia date         not null,
  ID_Cennika       int          not null foreign key references CennikKonferencji (ID_Cennika),
  Lokalizacja      int          not null foreign key references Lokalizacje (ID_Lokalizacji),
  Constraint PoprawneDaty CHECK (DzienZakonczenia >= DzienRozpoczecia AND
                                 DATEDIFF(year, getdate(), DzienRozpoczecia) < 1),
  CONSTRAINT Konferencje_CKUnikalne UNIQUE NONCLUSTERED (Nazwa, DzienRozpoczecia, Lokalizacja)
)

CREATE TABLE DniKonferencji (
  ID_Dnia        int  not null primary key identity (1, 1),
  ID_Konferencji int  not null foreign key references Konferencje (ID_Konferencji),
  Data           date not null,
  LiczbaMiejsc   int  not null,
  Constraint Dni_PoprawnaLiczbaMiejsc CHECK (LiczbaMiejsc > 0),
  CONSTRAINT DniKonferencji_CKUnikalne UNIQUE NONCLUSTERED (ID_Konferencji, Data)
)

CREATE TABLE Warsztaty (
  ID_Warsztatu    int           not null primary key identity (1, 1),
  ID_Dnia         int           not null foreign key references DniKonferencji (ID_Dnia),
  Rozpoczecie     time          not null,
  Zakonczenie     time          not null,
  LiczbaMiejsc    int           not null,
  Cena            decimal(4, 2) null,
  ZnizkaStudencka decimal(4, 2) null,
  Temat           varchar(MAX)  not null,
  Constraint PoprawneNastepstwoCzasu CHECK (Rozpoczecie < Zakonczenie), 
  CONSTRAINT Warsztaty_CKCzasTrawnia CHECK (DATEDIFF(minute, Rozpoczecie, Zakonczenie) > 15),
  Constraint Warsztaty_PoprawnaLiczbaMiejsc CHECK (LiczbaMiejsc > 0)
)
CREATE TABLE Klienci (
  ID_Klienta  int         not null primary key identity (1, 1),
  Nazwa       varchar(30) null,
  NIP         char(9)     null unique,
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
  Constraint Rezerwacje_PoprawnaLiczbaMiejsc CHECK (LiczbaMiejsc > 0)
)

CREATE TABLE Uczestnicy (
  ID_Uczestnika int         not null primary key identity (1, 1),
  Imie          varchar(30) not null,
  Nazwisko      varchar(30) not null,
  PESEL         char(11)    not null unique
)

CREATE TABLE UczestnicyKonferencji (
  ID_Uczestnika            int not null foreign key references Uczestnicy (ID_Uczestnika),
  ID_RezerwacjiKonferencji int not null foreign key references RezerwacjeDni (ID_Rezerwacji)
    ON DELETE CASCADE,
  CONSTRAINT UK_PrimaryKey primary key (ID_Uczestnika, ID_RezerwacjiKonferencji)
)


CREATE TABLE UczestnicyWarsztatow (
  ID_Uczestnika            int not null,
  ID_RezerwacjiWarsztatu   int not null,
  ID_RezerwacjiKonferencji int not null,
  CONSTRAINT UW_ForeignKEY foreign key (ID_Uczestnika, ID_RezerwacjiKonferencji) references UczestnicyKonferencji (ID_Uczestnika, ID_RezerwacjiKonferencji),
  CONSTRAINT UW_PrimaryKey primary key (ID_Uczestnika, ID_RezerwacjiWarsztatu)
)

CREATE TABLE Studenci (
  ID_Uczestnika int        not null primary key references Uczestnicy (ID_Uczestnika),
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

IF OBJECT_ID('KolizjaTrwaniaWarsztatu', N'FN') IS NOT NULL
  DROP FUNCTION KolizjaTrwaniaWarsztatu
GO

IF OBJECT_ID('CenaRezerwacjiWarsztatu', N'FN') IS NOT NULL
  DROP FUNCTION CenaRezerwacjiWarsztatu
GO

IF OBJECT_ID('LiczbaRezerwacjiMiejscKlienta', N'FN') IS NOT NULL
  DROP FUNCTION LiczbaRezerwacjiMiejscKlienta
GO

IF OBJECT_ID('WarsztatNalezyDoKonferencjiUczestnika', N'FN') IS NOT NULL
  DROP FUNCTION WarsztatNalezyDoKonferencjiUczestnika
GO

IF OBJECT_ID('ZarejestrowaniUczestnicyRezerwacjiDniaKonferencji', N'FN') IS NOT NULL
  DROP FUNCTION ZarejestrowaniUczestnicyRezerwacjiDniaKonferencji
GO

IF OBJECT_ID('ZarejestrowaniUczestnicyRezerwacjiWarsztatu', N'FN') IS NOT NULL
  DROP FUNCTION ZarejestrowaniUczestnicyRezerwacjiWarsztatu
GO

IF OBJECT_ID('PoprawnaDataDniaKonferencji', N'FN') IS NOT NULL
  DROP FUNCTION PoprawnaDataDniaKonferencji
GO

IF OBJECT_ID('PoprawnaLiczbaDniPrzypisanychDoKonferencji', N'FN') IS NOT NULL
  DROP FUNCTION PoprawnaLiczbaDniPrzypisanychDoKonferencji

IF OBJECT_ID('IleDoZaplatyDlaDanejRezerwacji', N'FN') IS NOT NULL
  DROP FUNCTION IleDoZaplatyDlaDanejRezerwacji
GO

IF OBJECT_ID('IleZaplaconoZaDanaRezerwacje', N'FN') IS NOT NULL
  DROP FUNCTION IleZaplaconoZaDanaRezerwacje
GO

CREATE FUNCTION WolneMiejscaWarsztat(@ID_Warsztatu int)
  RETURNS INT
AS

  BEGIN
    DECLARE @Liczba_miejsc AS int;
    SET @Liczba_miejsc = (SELECT LiczbaMiejsc FROM Warsztaty WHERE ID_Warsztatu = @ID_Warsztatu);

    DECLARE @Zarezerwowane AS int;
    SET @Zarezerwowane = (SELECT SUM(LiczbaMiejsc) FROM RezerwacjeWarsztatow 
	WHERE ID_Warsztatu = @ID_Warsztatu);

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

CREATE FUNCTION ZarejestrowaniUczestnicyRezerwacjiDniaKonferencji(@ID_Rezerwacji int)
  RETURNS int
AS
  BEGIN
    DECLARE @Zarejestrowani AS int;
    SET @Zarejestrowani = (SELECT COUNT(*) FROM UczestnicyKonferencji WHERE ID_RezerwacjiKonferencji = @ID_Rezerwacji);

    RETURN @Zarejestrowani;
  END
GO

CREATE FUNCTION ZarejestrowaniUczestnicyRezerwacjiWarsztatu(@ID_Rezerwacji int)
  RETURNS int
AS
  BEGIN

    DECLARE @Zarejestrowani AS int;
    SET @Zarejestrowani = (SELECT COUNT(*) FROM UczestnicyWarsztatow WHERE ID_RezerwacjiWarsztatu = @ID_Rezerwacji);

    RETURN @Zarejestrowani;

  END
GO

CREATE FUNCTION LiczbaRezerwacjiMiejscKlienta(@ID_Klienta int)
  RETURNS int
AS
  BEGIN
    DECLARE @RezerwacjeMiejsc AS int;

    SET @RezerwacjeMiejsc = (SELECT SUM(LiczbaMiejsc) FROM RezerwacjeDni WHERE ID_Klienta = @ID_Klienta)

    RETURN @RezerwacjeMiejsc

  END
GO

CREATE FUNCTION CenaRezerwacjiDniaKonferencji(@ID_Rezerwacji int)
  RETURNS money
AS
  BEGIN
    DECLARE @TygodnieDoKonferencji AS int;
    SET @TygodnieDoKonferencji = (SELECT DATEDIFF(week, DataRezerwacji, 
										(SELECT Data
										 FROM DniKonferencji
										 WHERE R.ID_Dnia = 
										 DniKonferencji.ID_Dnia))
                                  FROM RezerwacjeDni AS R
                                  WHERE ID_Rezerwacji = @ID_Rezerwacji)
    DECLARE @CenaZaOsobe AS money;

    IF @TygodnieDoKonferencji <= 4
      SET @CenaZaOsobe = (SELECT (Cena * ProgI)
                          FROM RezerwacjeDni AS R
                                 JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                 JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                 JOIN CennikKonferencji C on K.ID_Cennika = C.ID_Cennika)
    ELSE IF @TygodnieDoKonferencji <= 2
      SET @CenaZaOsobe = (SELECT (Cena * ProgII)
                          FROM RezerwacjeDni AS R
                                 JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                 JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                 JOIN CennikKonferencji C on K.ID_Cennika = C.ID_Cennika)
    ELSE
      SET @CenaZaOsobe = (SELECT (Cena)
                          FROM RezerwacjeDni AS R
                                 JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                 JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                 JOIN CennikKonferencji C on K.ID_Cennika = C.ID_Cennika)

    DECLARE @ZnizkaStudencka AS float;
    SET @ZnizkaStudencka = (SELECT ZnizkaStudencka
                            FROM RezerwacjeDni AS R
                                   JOIN DniKonferencji AS DK on R.ID_Dnia = DK.ID_Dnia
                                   JOIN Konferencje AS K ON DK.ID_Konferencji = K.ID_Konferencji
                                   JOIN CennikKonferencji C on K.ID_Cennika = C.ID_Cennika)

    DECLARE @LiczbaOsob AS int;
    SET @LiczbaOsob = (SELECT LiczbaMiejsc FROM RezerwacjeDni WHERE ID_Rezerwacji = @ID_Rezerwacji)

    DECLARE @LiczbaStudentow AS int;
    SET @LiczbaStudentow = (SELECT COUNT(*)
                            FROM RezerwacjeDni AS R
                                   JOIN UczestnicyKonferencji AS UK 
								   ON UK.ID_RezerwacjiKonferencji = R.ID_Rezerwacji
                                   JOIN Uczestnicy AS U ON U.ID_Uczestnika = UK.ID_Uczestnika
                                   JOIN Studenci S2 on U.ID_Uczestnika = S2.ID_Uczestnika)
    IF @ZnizkaStudencka IS NULL
      SET @ZnizkaStudencka = 1

    RETURN (@CenaZaOsobe * @ZnizkaStudencka * @LiczbaStudentow) + (@CenaZaOsobe * (@LiczbaOsob - @LiczbaStudentow))
  END
GO

CREATE FUNCTION CenaRezerwacjiWarsztatu(@ID_Rezerwacji int)
  RETURNS money
AS
  BEGIN
    DECLARE @LiczbaOsob AS int;
    SET @LiczbaOsob = (SELECT LiczbaMiejsc FROM RezerwacjeWarsztatow 
	WHERE ID_Rezerwacji = @ID_Rezerwacji)

    DECLARE @LiczbaStudentow AS int;
    SET @LiczbaStudentow = (SELECT COUNT(*)
                            FROM UczestnicyWarsztatow W
                                   JOIN UczestnicyKonferencji UK 
								   ON W.ID_Uczestnika = UK.ID_Uczestnika
                                   JOIN Uczestnicy AS U ON U.ID_Uczestnika = UK.ID_Uczestnika
                                   JOIN Studenci S on U.ID_Uczestnika = S.ID_Uczestnika
                            WHERE W.ID_RezerwacjiWarsztatu = @ID_Rezerwacji)

    DECLARE @CenaWarsztatu AS money;
    SET @CenaWarsztatu = (SELECT Cena
                          FROM Warsztaty W
                                 JOIN RezerwacjeWarsztatow R
                                   on W.ID_Warsztatu = R.ID_Warsztatu 
								   AND R.ID_Rezerwacji = @ID_Rezerwacji)

    DECLARE @ZnizkaStudencka AS float;
    SET @ZnizkaStudencka = (SELECT ZnizkaStudencka
                            FROM Warsztaty W
                                   JOIN RezerwacjeWarsztatow R
                                     on W.ID_Warsztatu = R.ID_Warsztatu 
									 AND R.ID_Rezerwacji = @ID_Rezerwacji)
    IF @ZnizkaStudencka IS NULL
      SET @ZnizkaStudencka = 1

    RETURN (@LiczbaStudentow * @CenaWarsztatu * @ZnizkaStudencka) 
			+ ((@LiczbaOsob - @LiczbaStudentow) * @CenaWarsztatu)


  END
GO


CREATE FUNCTION KolizjaTrwaniaWarsztatu(@ID_Uczestnika int, @RezerwacjaWarsztatu int)
  RETURNS bit
AS
  BEGIN

    DECLARE @Rozpoczecie AS time;
    DECLARE @Zakonczenie AS time;

    SET @Rozpoczecie = (SELECT Rozpoczecie
                        FROM Warsztaty AS W
                               JOIN RezerwacjeWarsztatow R
                                 on W.ID_Warsztatu = R.ID_Warsztatu 
								 AND R.ID_Rezerwacji = @RezerwacjaWarsztatu);
    SET @Zakonczenie = (SELECT Zakonczenie
                        FROM Warsztaty AS W
                               JOIN RezerwacjeWarsztatow R
                                 on W.ID_Warsztatu = R.ID_Warsztatu 
								 AND R.ID_Rezerwacji = @RezerwacjaWarsztatu);
    IF EXISTS(SELECT *
              FROM Warsztaty AS W
                     JOIN DniKonferencji DK on W.ID_Dnia = DK.ID_Dnia
                     JOIN RezerwacjeDni RD on DK.ID_Dnia = RD.ID_Dnia
                     JOIN UczestnicyKonferencji K
                       on RD.ID_Rezerwacji = K.ID_RezerwacjiKonferencji 
					   AND ID_Uczestnika = @ID_Uczestnika
              WHERE (@Zakonczenie > Rozpoczecie AND @Rozpoczecie < Rozpoczecie)
                 OR (@Zakonczenie < Zakonczenie AND @Rozpoczecie > Rozpoczecie)
                 OR (@Rozpoczecie < Zakonczenie AND @Zakonczenie > Zakonczenie))
      RETURN 1


    RETURN 0
  END
GO

CREATE FUNCTION WarsztatNalezyDoKonferencjiUczestnika(
	@ID_Uczestnika int, 
	@RezerwacjaWarsztatu int)
  RETURNS bit
AS
  BEGIN

    DECLARE @KonferencjaWarsztatu AS int;
    DECLARE @KonferencjaUczestnika AS int;

    SET @KonferencjaUczestnika = (SELECT RD.ID_Dnia
                                  FROM RezerwacjeDni RD
                                         JOIN UczestnicyKonferencji K
                                           on RD.ID_Rezerwacji = K.ID_RezerwacjiKonferencji 
										   AND K.ID_Uczestnika = @ID_Uczestnika)

    SET @KonferencjaWarsztatu = (SELECT W.ID_Dnia
                                 FROM Warsztaty W
                                        JOIN RezerwacjeWarsztatow R
                                          on W.ID_Warsztatu = R.ID_Warsztatu 
										  AND ID_Rezerwacji = @RezerwacjaWarsztatu)

    IF @KonferencjaUczestnika IS NOT NULL AND @KonferencjaWarsztatu IS NOT NULL AND
       @KonferencjaWarsztatu = @KonferencjaUczestnika
      RETURN 1

    RETURN 0
  END
GO


CREATE FUNCTION PoprawnaLiczbaDniPrzypisanychDoKonferencji(@ID_Konferencji int)
  RETURNS bit
AS
  BEGIN
    DECLARE @LiczbaDni AS int;
    SET @LiczbaDni = (SELECT COUNT(*) FROM DniKonferencji WHERE ID_Konferencji = @ID_Konferencji)

    DECLARE @DataRozpoczecia AS date;
    SET @DataRozpoczecia = (SELECT DzienRozpoczecia FROM Konferencje 
							WHERE ID_Konferencji = @ID_Konferencji)

    DECLARE @DataZakonczenia AS date;
    SET @DataZakonczenia = (SELECT DzienZakonczenia FROM Konferencje 
							WHERE ID_Konferencji = @ID_Konferencji)

    IF (@LiczbaDni <= DATEDIFF(day, @DataRozpoczecia, @DataZakonczenia) + 1)
      RETURN 1


    RETURN 0
  END
GO

CREATE FUNCTION PoprawnaDataDniaKonferencji(@ID_Dnia INT, @DataDnia DATE)
  RETURNS BIT
AS
  BEGIN
    DECLARE @DataRozpoczecia AS DATE;
    SET @DataRozpoczecia = (SELECT DzienRozpoczecia
                            FROM Konferencje
                                   JOIN DniKonferencji DK 
								   ON Konferencje.ID_Konferencji = DK.ID_Konferencji
                            WHERE ID_Dnia = @ID_Dnia)

    DECLARE @DataZakonczenia AS date;
    SET @DataZakonczenia = (SELECT DzienZakonczenia
                            FROM Konferencje
                                   JOIN DniKonferencji DK 
								   ON Konferencje.ID_Konferencji = DK.ID_Konferencji
                            WHERE ID_Dnia = @ID_Dnia)

    IF (@DataDnia BETWEEN @DataRozpoczecia AND @DataZakonczenia)
      RETURN 1

    RETURN 0
  END
GO


CREATE FUNCTION IleDoZaplatyDlaDanejRezerwacji(@ID_Rezerwacji int)
  RETURNS money
AS
  BEGIN
    DECLARE @CenaZaDzienRezerwacji MONEY
    SET @CenaZaDzienRezerwacji = dbo.CenaRezerwacjiDniaKonferencji(@ID_Rezerwacji)
    DECLARE @CenaZaWarsztatyWDanejRezerwacji MONEY
    SET @CenaZaWarsztatyWDanejRezerwacji =
    (SELECT SUM(dbo.CenaRezerwacjiWarsztatu(ID_Rezerwacji))
     FROM RezerwacjeWarsztatow
     WHERE RezerwacjaDnia = @ID_Rezerwacji
     GROUP BY RezerwacjaDnia)
    RETURN @CenaZaDzienRezerwacji + @CenaZaWarsztatyWDanejRezerwacji
  END
GO

CREATE FUNCTION IleZaplaconoZaDanaRezerwacje(@ID_Rezerwacji INT)
  RETURNS MONEY
AS
  BEGIN
    DECLARE @ZaplataZaKonferencje MONEY
    SET @ZaplataZaKonferencje =
    (SELECT SUM(Kwota) FROM Platnosci WHERE RezerwacjaDnia = @ID_Rezerwacji GROUP BY RezerwacjaDnia)
    DECLARE @ZaplataZaWarsztatyWKonferencji MONEY
    SET @ZaplataZaWarsztatyWKonferencji =
    (SELECT SUM(Kwota)
     FROM Platnosci
     WHERE RezerwacjaWarsztatu IN
           (SELECT ID_Rezerwacji FROM RezerwacjeWarsztatow WHERE RezerwacjaDnia = @ID_Rezerwacji)
     GROUP BY RezerwacjaDnia)
    RETURN @ZaplataZaKonferencje + @ZaplataZaWarsztatyWKonferencji
  END
GO

------------------------------------ Dodatkowe constrainty

ALTER TABLE UczestnicyWarsztatow
  ADD CONSTRAINT Rezerwacje_CKKolizjaWarsztatow CHECK (
  dbo.KolizjaTrwaniaWarsztatu(ID_Uczestnika, ID_RezerwacjiWarsztatu) = 0);
GO

ALTER TABLE UczestnicyWarsztatow
  ADD CONSTRAINT Rezerwacje_CKKonferencjaWarsztatu CHECK (dbo.WarsztatNalezyDoKonferencjiUczestnika(ID_Uczestnika,
                                                                                                    ID_RezerwacjiWarsztatu)
                                                          = 1)
GO

ALTER TABLE DniKonferencji
  ADD CONSTRAINT Dni_CKPoprawnaDataDnia CHECK (dbo.PoprawnaDataDniaKonferencji(ID_Dnia, Data) = 1) 
GO

ALTER TABLE DniKonferencji
  ADD CONSTRAINT Dni_CKPoprawnaLiczbaDni CHECK (dbo.PoprawnaLiczbaDniPrzypisanychDoKonferencji(ID_Konferencji) = 1)
GO


-------------------------- Procedury


-------------------------- Procedury wstawiania danych

IF OBJECT_ID('DodajUczestnika', 'P') IS NOT NULL
  DROP PROCEDURE DodajUczestnika

IF OBJECT_ID('DodajUczestnikaDniaKonferencji', 'P') IS NOT NULL
  DROP PROCEDURE DodajUczestnikaDniaKonferencji

IF OBJECT_ID('DodajUczestnikaWarsztatu', 'P') IS NOT NULL
  DROP PROCEDURE DodajUczestnikaWarsztatu

IF OBJECT_ID('DodajPlatnosc', 'P') IS NOT NULL
  DROP PROCEDURE DodajPlatnosc

IF OBJECT_ID('DodajLokalizacje', 'P') IS NOT NULL
  DROP PROCEDURE DodajLokalizacje
GO

if OBJECT_ID('DodajKlienta', N'P') is not null
  drop procedure DodajKlienta
GO

IF OBJECT_ID('DodajKonferencje', 'P') IS NOT NULL
  DROP PROCEDURE DodajKonferencje
GO

IF OBJECT_ID('DodajDzienKonferencji', 'P') IS NOT NULL
  DROP PROCEDURE DodajDzienKonferencji
GO

if OBJECT_ID('DodajWarsztat', N'P') is not null
  drop procedure DodajWarsztat
GO

if OBJECT_ID('DodajRezerwacjeDnia', N'P') is not null
  drop procedure DodajRezerwacjeDnia
GO

CREATE PROCEDURE DodajUczestnika
  (@Imie             varchar(30),
   @Nazwisko         varchar(30),
   @PESEL            varchar(8),
   @NumerLegitymacji int)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF EXISTS(SELECT * FROM Uczestnicy WHERE PESEL = @PESEL)
      RAISERROR ('Podany PESEL jest ju¿ zarejstrowany w obrêbie podanej rezerwacji', 10, 1)

    INSERT INTO Uczestnicy VALUES (@Imie, @Nazwisko, @PESEL);

    IF @NumerLegitymacji IS NOT NULL
      BEGIN
        IF EXISTS(SELECT *
                  FROM Studenci AS S
                         JOIN Uczestnicy AS U 
						 ON S.ID_Uczestnika = U.ID_Uczestnika AND U.PESEL != @PESEL)
          RAISERROR ('Podany numer legitymacji nale¿y do innego uczestnika', 10, 1)

        DECLARE @ID_Uczestnika AS int;
        SET @ID_Uczestnika = (SELECT ID_Uczestnika FROM Uczestnicy AS U WHERE @PESEL = U.PESEL);

        INSERT INTO Studenci VALUES (@ID_Uczestnika, @NumerLegitymacji)
      END
    COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg nvarchar(2048) = error_message()
		RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE DodajUczestnikaDniaKonferencji(@ID_Uczestnika int, @ID_Rezerwacji int)
AS
  BEGIN
    BEGIN TRY
    BEGIN TRANSACTION
    IF (@ID_Uczestnika IS NULL)
      RAISERROR ('Podane ID uczestnika jest nullem', 10, 1)

    IF (@ID_Rezerwacji IS NULL)
      RAISERROR ('Podane ID rezerwacji jest nullem', 10, 1)

    IF NOT EXISTS(SELECT * FROM RezerwacjeDni WHERE ID_Rezerwacji = @ID_Rezerwacji)
      RAISERROR ('Podane ID rezerwacji nie isntieje', 10, 1)


    DECLARE @LiczbaMiejsc AS int;
    SET @LiczbaMiejsc = (SELECT LiczbaMiejsc FROM RezerwacjeDni 
						WHERE ID_Rezerwacji = @ID_Rezerwacji)
    IF (NOT dbo.ZarejestrowaniUczestnicyRezerwacjiDniaKonferencji(@ID_Rezerwacji) < @LiczbaMiejsc)
      RAISERROR ('Rezerwacja jest pelna, nie mozna dodac kolejnego uczestnika', 10, 1);

    INSERT INTO UczestnicyKonferencji VALUES (@ID_Uczestnika, @ID_Rezerwacji);
    COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg nvarchar(2048) = error_message()
		RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO


CREATE PROCEDURE DodajUczestnikaWarsztatu
  (@ID_Rezerwacji            int,
   @ID_UczestnikaKonferencji int)
AS
  BEGIN
    BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRANSACTION

    IF (dbo.KolizjaTrwaniaWarsztatu(@ID_UczestnikaKonferencji, @ID_Rezerwacji) = 1)
      RAISERROR ('Podany uczestnik w tym czasie bierze udzial w innym warsztacie', 10, 1)

    IF (dbo.WarsztatNalezyDoKonferencjiUczestnika(@ID_UczestnikaKonferencji, @ID_Rezerwacji) = 0)
      RAISERROR ('Uczestnik nie bierze udzialu w konferencji na ktorej odbywa sie warsztat', 10, 1)

    DECLARE @LiczbaMiejsc AS int;
    SET @LiczbaMiejsc = (SELECT LiczbaMiejsc FROM RezerwacjeWarsztatow 
						 WHERE ID_Rezerwacji = @ID_Rezerwacji)
    IF (NOT dbo.ZarejestrowaniUczestnicyRezerwacjiWarsztatu(@ID_Rezerwacji) < @LiczbaMiejsc)
      RAISERROR ('Rezerwacja jest pelna, nie mozna dodac kolejnego uczestnika', 10, 1);

    DECLARE @ID_RezerwacjiKonferencji AS int;
    SET @ID_RezerwacjiKonferencji = (SELECT RD.ID_Rezerwacji
                                     FROM RezerwacjeDni RD
                                     JOIN RezerwacjeWarsztatow RW 
									 ON RD.ID_Rezerwacji = RW.RezerwacjaDnia)
    INSERT INTO UczestnicyWarsztatow 
	VALUES (@ID_UczestnikaKonferencji, @ID_Rezerwacji, @ID_RezerwacjiKonferencji)

    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg nvarchar(2048) = error_message()
		RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE DodajPlatnosc
  (@DataPlatnosci       date,
   @RezerwacjaWarsztatu bit,
   @ID_Rezerwacji       int,
   @Kwota               money)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF (@DataPlatnosci > GETDATE())
      RAISERROR ('Proba wprowadzenia platnosci z przyszla data', 10, 1);
    IF @RezerwacjaWarsztatu = 1
      BEGIN
        INSERT INTO Platnosci VALUES (@DataPlatnosci, NULL, @ID_Rezerwacji, @Kwota)
      END
    ELSE
      BEGIN
        INSERT INTO Platnosci VALUES (@DataPlatnosci, @ID_Rezerwacji, NULL, @Kwota)
      END
    COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
Go

CREATE PROCEDURE DodajLokalizacje
  (@Miasto       varchar(30),
   @Ulica        varchar(30),
   @KodPocztowy  varchar(8),
   @NumerBudynku smallint)
AS
  BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF EXISTS(SELECT *
              FROM Lokalizacje
              WHERE Miasto = @Miasto
                AND Ulica = @Ulica
                AND KodPocztowy = @KodPocztowy
                AND NumerBudynku = @NumerBudynku)
      RAISERROR ('Podana lokalizacja juz istnieje w bazie', 10, 1)
    IF (@KodPocztowy NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9]')
      RAISERROR ('Bledny format kodu pocztowego', 10, 1)

    INSERT INTO Lokalizacje VALUES (@Miasto, @Ulica, @KodPocztowy, @NumerBudynku)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
Go

CREATE PROCEDURE DodajCennik
  (@Cena            money,
   @ZnizkaStudencka float,
   @ProgI           float,
   @ProgII          float)
AS
  BEGIN
    BEGIN TRY
    BEGIN TRANSACTION
    IF (@Cena < 0)
      RAISERROR ('Proba wprowadzenia ujemnej ceny udzialu w dniu konferencji', 10, 1)
    IF (@ProgI > @ProgII)
      RAISERROR ('Podano progi cenowe w blednej kolejnosci', 10, 1)
    INSERT INTO CennikKonferencji VALUES (@Cena, @ZnizkaStudencka, @ProgI, @ProgII)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
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
      RAISERROR ('Brak imienia lub nazwiska', 10, 1)
    IF @Miasto IS NULL OR @Ulica IS NULL OR @KodPocztowy IS NULL
       OR @KodPocztowy NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9]'
       OR @NrBudynku IS NULL
      RAISERROR ('Adres jest niepoprawny', 10, 1)
    IF @NIP IS NOT NULL
       AND @NIP NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
      RAISERROR ('Niepoprawny NIP', 10, 1)
    IF EXISTS(SELECT * FROM Klienci WHERE NIP = @NIP)
      RAISERROR ('Podany NIP wystepuje w bazie.', 10, 1)
    INSERT into Klienci (Nazwa, NIP, Imie, Nazwisko, Miasto, Ulica, KodPocztowy, NrBudynku, NrLokalu, Telefon, EMail)
    VALUES (@Nazwa, @NIP, @Imie, @Nazwisko, @Miasto, @Ulica, @KodPocztowy, @NrBudynku, @NrLokalu, @Telefon, @Email)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
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
    IF (@DzienRozpoczecia > @DzienZakonczenia)
      RAISERROR ('Podane daty sa niepoprawne', 10, 1)
    INSERT INTO Konferencje (Nazwa, DzienRozpoczecia, DzienZakonczenia, ID_Cennika, Lokalizacja)
    VALUES (@Nazwa, @DzienRozpoczecia, @DzienZakonczenia, @ID_Cennika, @Lokalizacja)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
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
    DECLARE @DataRoz date
    SET @DataRoz =
    (select DzienRozpoczecia from Konferencje where ID_Konferencji = @ID_Konferencji)
    DECLARE @DataZak date
    SET @DataZak =
    (Select DzienZakonczenia from Konferencje where ID_Konferencji = @ID_Konferencji)
    IF @Data < @DataRoz OR @Data > @DataZak
      RAISERROR ('W podanym dniu nie ma podanej konferencji', 10, 1)
    INSERT INTO DniKonferencji (ID_Konferencji, Data, LiczbaMiejsc) VALUES (@ID_Konferencji, @Data, @LiczbaMiejsc)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
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
      RAISERROR ('ID_Dnia jest nullem', 10, 1)
    IF @Rozpoczecie IS NULL OR @Zakonczenie IS NULL
       OR @Zakonczenie <= @Rozpoczecie
      RAISERROR ('Niepoprawnie podany czas', 10, 1)
    IF @LiczbaMiejsc IS NOT NULL OR @LiczbaMiejsc <= 0
      RAISERROR ('Niepoprawna liczba miejsc', 10, 1)
    IF @Cena IS NULL OR @Cena < 0
      RAISERROR ('Niepoprawna cena', 10, 1)
    INSERT into Warsztaty (ID_Dnia, Rozpoczecie, Zakonczenie, LiczbaMiejsc, Cena, ZnizkaStudencka)
    VALUES (@ID_Dnia, @Rozpoczecie, @Zakonczenie, @LiczbaMiejsc, @Cena, @ZnizkaStudencka)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
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
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

--Modyfikacje
if OBJECT_ID('UsuniecieWarsztatu', N'P') is not null
  drop procedure UsuniecieWarsztatu
GO

if OBJECT_ID('UsuniecieUczestnikowRezerwacjiWarsztatu', N'P') is not null
  drop procedure UsuniecieUczestnikowRezerwacjiWarsztatu
GO

if OBJECT_ID('UsuniecieUczestnikowRezerwacjiDniaKonferencji', N'P') is not null
  drop procedure UsuniecieUczestnikowRezerwacjiDniaKonferencji
GO


if OBJECT_ID('AnulowanieRezerwacjiWarsztatu', N'P') is not null
  drop procedure AnulowanieRezerwacjiWarsztatu
GO

if OBJECT_ID('AnulowanieRezerwacjiDniaKonferencji', N'P') is not null
  drop procedure AnulowanieRezerwacjiDniaKonferencji
GO


if OBJECT_ID('ZmianaDanychKlienta', N'P') is not null
  drop procedure ZmianaDanychKlienta
GO

if OBJECT_ID('ZmianaWartosciCennika', N'P') is not null
  drop procedure ZmianaWartosciCennika
GO


CREATE PROCEDURE UsuniecieUczestnikowRezerwacjiWarsztatu(
  @ID_Rezerwacji int)
AS
  BEGIN
    BEGIN TRY
    BEGIN TRANSACTION

    IF (@ID_Rezerwacji IS NULL)
      RAISERROR ('Jako ID podano NULL', 10, 1)

    DELETE FROM UczestnicyWarsztatow WHERE ID_RezerwacjiWarsztatu = @ID_Rezerwacji

    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE UsuniecieUczestnikowRezerwacjiDniaKonferencji(
  @ID_Rezerwacji int)
AS
  BEGIN
    BEGIN TRY
    BEGIN TRANSACTION

    IF (@ID_Rezerwacji IS NULL)
      RAISERROR ('Jako ID podano NULL', 10, 1)

    DELETE FROM UczestnicyKonferencji WHERE ID_RezerwacjiKonferencji = @ID_Rezerwacji

    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE AnulowanieRezerwacjiWarsztatu(@ID_Rezerwacji int)
AS
  BEGIN
    BEGIN TRY
    BEGIN TRANSACTION
    IF (@ID_Rezerwacji IS NULL)
      RAISERROR ('Jako ID podano null', 10, 1)

    EXEC dbo.UsuniecieUczestnikowRezerwacjiWarsztatu @ID_Rezerwacji;

    DELETE FROM RezerwacjeWarsztatow WHERE @ID_Rezerwacji = ID_Rezerwacji;

    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE AnulowanieRezerwacjiDniaKonferencji(@ID_Rezerwacji int)
AS
  BEGIN
    BEGIN TRY
    BEGIN TRANSACTION
    IF (@ID_Rezerwacji IS NULL)
      RAISERROR ('Jako ID podano null', 10, 1)

    DECLARE CursorWarsztatu CURSOR FOR SELECT ID_Rezerwacji
                                       FROM RezerwacjeWarsztatow AS RW
                                       WHERE RW.RezerwacjaDnia = @ID_Rezerwacji
    DECLARE @IDRezerwacjiWarsztatu AS int;
    WHILE @@FETCH_STATUS = 0
      BEGIN
        FETCH NEXT FROM CursorWarsztatu
        INTO @IDRezerwacjiWarsztatu;
        EXEC dbo.AnulowanieRezerwacjiWarsztatu @IDRezerwacjiWarsztatu;
      END
    CLOSE CursorWarsztatu;
    DEALLOCATE CursorWarsztatu;
    EXEC dbo.UsuniecieUczestnikowRezerwacjiDniaKonferencji @ID_Rezerwacji;

    DELETE FROM RezerwacjeDni WHERE @ID_Rezerwacji = ID_Rezerwacji;

    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE ZmianaCennikaKonferencji(@ID_Konferencji int, @ID_Cennika int)
AS
  BEGIN
    BEGIN TRY
    BEGIN TRANSACTION
    IF (@ID_Konferencji IS NULL)
      RAISERROR ('Podane ID konferencji jest nullem', 10, 1)
    IF (@ID_Cennika IS NULL)
      RAISERROR ('Podane ID cennika jest nullem', 10, 1)

    IF EXISTS(SELECT *
              FROM DniKonferencji AS DK
                     JOIN RezerwacjeDni RD on DK.ID_Dnia = RD.ID_Dnia
              WHERE ID_Konferencji = @ID_Konferencji)
      RAISERROR ('Dla konferencji istnieja rezerwacje, nie mozna zmienic cennika', 10, 1)

    UPDATE Konferencje SET ID_Cennika = @ID_Cennika WHERE ID_Konferencji = @ID_Konferencji
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE ZmianaWartosciCennika(
	@ID_Cennika int, 
	@Cena money, 
	@ZnizkaStudencka float, 
	@ProgI float,
	@ProgII     float)
AS
  BEGIN

    SET NOCOUNT ON;
    BEGIN TRY
    BEGIN TRANSACTION
    IF (@ID_Cennika IS NULL)
      RAISERROR ('Podane ID jest nullem', 10, 1)

    IF EXISTS(SELECT * FROM Konferencje WHERE ID_Cennika = @ID_Cennika)
      RAISERROR ('Nie mozna zmienic cennika, jesli jest uzywany przez chociaz jedna konferencje', 10, 1);

    IF (@Cena IS NOT NULL)
      IF (@Cena < 0)
        RAISERROR ('Podano ujemna cen?', 10, 1)
      ELSE
        UPDATE CennikKonferencji SET Cena = @Cena WHERE ID_Cennika = @ID_Cennika

    IF (@ZnizkaStudencka NOT BETWEEN 0 AND 1)
      RAISERROR ('Podano nieprawidlowa wartosc znizki', 10, 1)
    ELSE
      UPDATE CennikKonferencji SET ZnizkaStudencka = @ZnizkaStudencka WHERE ID_Cennika = @ID_Cennika

    IF (@ProgI IS NOT NULL)
      IF (@ProgI > (SELECT ProgII FROM CennikKonferencji WHERE ID_Cennika = @ID_Cennika))
        RAISERROR ('Prog I musi byc nizszy badz rowny progowi II', 10, 1)
      ELSE
        IF (@ProgI NOT BETWEEN 0 AND 1)
          RAISERROR ('Podano nieprawidlowa wartosc progu cenowego', 10, 1)
        ELSE
          UPDATE CennikKonferencji SET ProgI = @ProgI WHERE ID_Cennika = @ID_Cennika

    IF (@ProgII IS NOT NULL)
      IF (@ProgII < (SELECT ProgI FROM CennikKonferencji WHERE ID_Cennika = @ID_Cennika))
        RAISERROR ('Prog II byc nizszy badz rowny progowi I', 10, 1)
      ELSE
        IF (@ProgII NOT BETWEEN 0 AND 1)
          RAISERROR ('Podano nieprawdilowa wartosc porgu cenowego', 10, 1)
        ELSE
          UPDATE CennikKonferencji SET ProgII = @ProgII WHERE ID_Cennika = @ID_Cennika
    COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

CREATE PROCEDURE ZmianaDanychKlienta(
  @ID_Klienta  int,
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
    IF @ID_Klienta IS NULL
      RAISERROR ('ID_Klienta jest nullem', 10, 1)
    IF (@Imie IS NOT NULL AND @Nazwisko IS NOT NULL) OR
       (@Miasto IS NOT NULL AND @Ulica IS NOT NULL AND
        @KodPocztowy IS NOT NULL AND @NrBudynku IS NOT NULL) OR
       @Telefon IS NOT NULL OR @EMail IS NOT NULL
      IF @Imie IS NOT NULL AND @Nazwisko IS NOT NULL
        UPDATE KLIENCI
        SET Imie     = @imie,
            Nazwisko = @Nazwisko
        where ID_Klienta = @ID_Klienta
    IF @Miasto IS NOT NULL AND @Ulica IS NOT NULL AND
       @KodPocztowy IS NOT NULL AND @NrBudynku IS NOT NULL
      UPDATE KLIENCI
      SET Miasto      = @Miasto,
          Ulica       = @Ulica,
          KodPocztowy = @KodPocztowy,
          NrBudynku   = @NrBudynku
      where ID_Klienta = @ID_Klienta
    IF @NrLokalu IS NOT NULL
      UPDATE KLIENCI SET NrLokalu = @NrLokalu WHERE ID_Klienta = @ID_Klienta
    IF @Telefon IS NOT NULL
      UPDATE KLIENCI SET Telefon = @Telefon WHERE ID_Klienta = @ID_Klienta
    IF @EMail IS NOT NULL
      UPDATE KLIENCI SET EMail = @EMail WHERE ID_Klienta = @ID_Klienta
    ELSE
      RAISERROR ('Niepoprawnie podane dane', 10, 1)
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
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
      RAISERROR ('ID_Konferencji jest nullem', 10, 1)
    IF EXISTS
    (select ID_Rezerwacji
     from RezerwacjeDni
     where ID_Dnia in
           (select ID_Dnia from DniKonferencji where ID_Konferencji = @ID_Konferencji))
      RAISERROR ('Nie mozesz usunac konferencji -
				istnieje juz dla niej rezerwacja', 10, 1)
    DELETE FROM Warsztaty
    where ID_Dnia in
          (select ID_Dnia from DniKonferencji WHERE ID_Konferencji = @ID_Konferencji)
    DELETE FROM DniKonferencji where ID_Konferencji = @ID_Konferencji
    DELETE FROM Konferencje where ID_Konferencji = @ID_Konferencji
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
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
      RAISERROR ('ID_Warsztatu jest nullem', 10, 1)
    IF EXISTS
    (select ID_Rezerwacji from RezerwacjeWarsztatow WHERE ID_Warsztatu = @ID_Warsztatu)
      RAISERROR ('Nie mozesz usunac warsztatu -
				istnieje juz dla niego rezerwacja', 10, 1)
    ELSE
      DELETE FROM Warsztaty where ID_Warsztatu = @ID_Warsztatu
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

-- Widoki

if OBJECT_ID('NadchodzaceKonferencje', N'V') is not null
  drop VIEW NadchodzaceKonferencje
GO

if OBJECT_ID('NadchodzaceWarsztaty', N'V') is not null
  drop VIEW NadchodzaceWarsztaty
GO

if OBJECT_ID('NajpopularniejszeKonferencje', N'V') is not null
  drop VIEW NajpopularniejszeKonferencje
GO

if OBJECT_ID('NaleznosciKlientow', N'V') is not null
  drop VIEW NaleznosciKlientow
GO

if OBJECT_ID('NaleznosciKlientowPoTerminie', N'V') is not null
  drop VIEW NaleznosciKlientowPoTerminie
GO

if OBJECT_ID('NajpopularniejszeWarsztaty', N'V') is not null
  drop VIEW NajpopularniejszeWarsztaty
GO

IF OBJECT_ID('RezerwacjeBezKompletnejRejestracjiUczestnikow', N'V') is not null
  DROP VIEW RezerwacjeBezKompletnejRejestracjiUczestnikow
GO

IF OBJECT_ID('UczestnicyWszystkichKonferencji', N'V') is not null
  DROP VIEW UczestnicyWszystkichKonferencji
GO

IF OBJECT_ID('UczestnicyWszystkichWarsztatow', N'V') is not null
  DROP VIEW UczestnicyWszystkichWarsztatow
GO

IF OBJECT_ID('NajaktywniejsiKlienci', N'V') is not null
  DROP VIEW NajaktywniejsiKlienci
GO

CREATE VIEW RezerwacjeBezKompletnejRejestracjiUczestnikow
  AS
    SELECT ID_Rezerwacji,
           ID_Klienta,
           'Dzien konferencji' AS 'Typ rejestracji',
           LiczbaMiejsc - [dbo].ZarejestrowaniUczestnicyRezerwacjiDniaKonferencji(ID_Rezerwacji) 
		   AS 'Brakujace miejsca'
    FROM RezerwacjeDni
    WHERE [dbo].ZarejestrowaniUczestnicyRezerwacjiDniaKonferencji(ID_Rezerwacji) < LiczbaMiejsc

    UNION

    SELECT ID_Rezerwacji,
           (SELECT ID_Klienta FROM RezerwacjeDni AS RD WHERE RD.ID_Rezerwacji = RW.RezerwacjaDnia),
           'Warsztat'                                                                         AS 'Typ rejestracji',
           LiczbaMiejsc - [dbo].ZarejestrowaniUczestnicyRezerwacjiWarsztatu(RW.ID_Rezerwacji) AS 'Brakujace miejsca'
    FROM RezerwacjeWarsztatow AS RW
    WHERE [dbo].ZarejestrowaniUczestnicyRezerwacjiWarsztatu(RW.ID_Rezerwacji) < LiczbaMiejsc;
GO

CREATE VIEW UczestnicyWszystkichKonferencji
  AS
    SELECT Imie, Nazwisko, U.ID_Uczestnika, ID_Klienta, ID_RezerwacjiKonferencji, DK.ID_Dnia, ID_Konferencji
    FROM Uczestnicy AS U
           JOIN UczestnicyKonferencji AS UK ON UK.ID_Uczestnika = U.ID_Uczestnika
           JOIN RezerwacjeDni AS RD ON RD.ID_Rezerwacji = UK.ID_RezerwacjiKonferencji
           JOIN DniKonferencji DK on RD.ID_Dnia = DK.ID_Dnia
GO

CREATE VIEW UczestnicyWszystkichWarsztatow
  AS
    SELECT Imie,
           Nazwisko,
           U.ID_Uczestnika,
           ID_Klienta,
           ID_RezerwacjiWarsztatu,
           DK.ID_Dnia,
           ID_Warsztatu,
           ID_Konferencji
    FROM Uczestnicy AS U
           JOIN UczestnicyKonferencji AS UK ON UK.ID_Uczestnika = U.ID_Uczestnika
           JOIN UczestnicyWarsztatow AS UW ON UW.ID_Uczestnika = UK.ID_Uczestnika
           JOIN RezerwacjeWarsztatow AS RW ON RW.ID_Rezerwacji = UW.ID_RezerwacjiWarsztatu
           JOIN RezerwacjeDni AS RD ON RW.RezerwacjaDnia = RD.ID_Rezerwacji
           JOIN DniKonferencji DK on RD.ID_Dnia = DK.ID_Dnia
GO

CREATE VIEW RezerwacjeKlientow
  AS
    SELECT Imie, Nazwisko, K.ID_Klienta, ID_Rezerwacji, 'Dzien konferencji' AS 'Typ rezerwacji'
    FROM Klienci AS K
           JOIN RezerwacjeDni RD on K.ID_Klienta = RD.ID_Klienta

    UNION
    SELECT Imie, Nazwisko, K.ID_Klienta, RW.ID_Rezerwacji, 'Warsztat' AS 'Typ rezerwacji'
    FROM Klienci AS K
           JOIN RezerwacjeDni RD on K.ID_Klienta = RD.ID_Klienta
           JOIN RezerwacjeWarsztatow AS RW ON RW.RezerwacjaDnia = RD.ID_Rezerwacji
GO


CREATE VIEW NajaktywniejsiKlienci
  AS
    SELECT TOP 10 Imie,
               Nazwisko,
               K.ID_Klienta,
               [dbo].LiczbaRezerwacjiMiejscKlienta(K.ID_Klienta) AS 'Liczba zarezerwowanych miejsc'
    FROM Klienci AS K
    ORDER BY [dbo].LiczbaRezerwacjiMiejscKlienta(K.ID_Klienta)
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

CREATE VIEW NajpopularniejszeKonferencje
  AS
    SELECT TOP 25 k.ID_Konferencji,
               Nazwa AS [Nazwa konferencji],
               CAST(SUM(rd.LiczbaMiejsc) / SUM(dk.LiczbaMiejsc) AS DECIMAL(5, 4)) AS [Stosunek zajetych do wszystkich]
    FROM Konferencje k
           LEFT JOIN DniKonferencji dk ON k.ID_Konferencji = dk.ID_Konferencji
           LEFT JOIN RezerwacjeDni rd ON rd.ID_Dnia = dk.ID_Dnia
    WHERE k.DzienZakonczenia < GETDATE()
    GROUP BY k.ID_Konferencji, Nazwa
    ORDER BY [Stosunek zajetych do wszystkich] DESC
GO


CREATE VIEW NajpopularniejszeWarsztaty
  AS
    SELECT TOP 25 w.ID_Warsztatu,
               w.Temat,
               kon.Nazwa,
               CAST(sum(rw.LiczbaMiejsc) / w.LiczbaMiejsc AS DECIMAL(5, 4)) AS [Stosunek miejsc zajetych do wszystkich]
    FROM Warsztaty w
           join RezerwacjeWarsztatow rw on rw.ID_Warsztatu = w.ID_Warsztatu
           join DniKonferencji dk on dk.ID_Dnia = w.ID_Dnia
           join Konferencje kon on kon.ID_Konferencji = dk.ID_Konferencji
    Group by w.ID_Warsztatu, w.Temat, kon.Nazwa, w.LiczbaMiejsc
    ORDER BY [Stosunek miejsc zajetych do wszystkich] DESC
GO

CREATE VIEW NaleznosciKlientow
  AS
    SELECT k.ID_Klienta,
           kon.ID_Konferencji,
           kon.Nazwa,
           ISNULL(dbo.IleDoZaplatyDlaDanejRezerwacji(rd.ID_Rezerwacji), 0)
             -
           ISNULL(dbo.IleZaplaconoZaDanaRezerwacje(rd.ID_Rezerwacji), 0) AS [Zalegla oplata]
    FROM RezerwacjeDni rd
           join DniKonferencji dk on dk.ID_Dnia = rd.ID_Dnia
           join Konferencje kon on kon.ID_Konferencji = dk.ID_Konferencji
           right join Klienci k on rd.ID_Klienta = k.ID_Klienta
    Group by k.ID_Klienta, kon.ID_Konferencji, kon.Nazwa, rd.ID_Rezerwacji
GO

CREATE VIEW NaleznosciKlientowPoTerminie
  AS
    SELECT k.ID_Klienta,
           kon.ID_Konferencji,
           kon.Nazwa,
           ISNULL(dbo.IleDoZaplatyDlaDanejRezerwacji(rd.ID_Rezerwacji), 0)
             -
           ISNULL(dbo.IleZaplaconoZaDanaRezerwacje(rd.ID_Rezerwacji), 0) AS [Zalegla oplata]
    FROM RezerwacjeDni rd
           join DniKonferencji dk on dk.ID_Dnia = rd.ID_Dnia
           join Konferencje kon on kon.ID_Konferencji = dk.ID_Konferencji
           right join Klienci k on rd.ID_Klienta = k.ID_Klienta
    WHERE dbo.IleDoZaplatyDlaDanejRezerwacji(rd.ID_Rezerwacji)
            - dbo.IleZaplaconoZaDanaRezerwacje(rd.ID_Rezerwacji) > 0
      AND DATEDIFF(dd, rd.DataRezerwacji, GetDate()) >= 7
    Group by k.ID_Klienta, kon.ID_Konferencji, kon.Nazwa, rd.ID_Rezerwacji
GO

-- Procedury zwracajace dane

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

-- Procedura korzystaj¹ca z widoku
if OBJECT_ID('AnulowanieZaleglychRezerwacji', N'P') is not null
  drop PROCEDURE AnulowanieZaleglychRezerwacji
GO

CREATE PROCEDURE AnulowanieZaleglychRezerwacji
AS
  BEGIN
    BEGIN TRY

    DECLARE CursorRezerwacji CURSOR FOR SELECT RD.ID_Rezerwacji
                                        FROM NaleznosciKlientowPoTerminie AS N
                                        JOIN DniKonferencji AS DK 
										ON DK.ID_Konferencji = N.ID_Konferencji
                                        JOIN RezerwacjeDni AS RD
                                        ON RD.ID_Klienta = N.ID_Klienta AND RD.ID_Dnia = DK.ID_Dnia;
    DECLARE @IDRezerwacjiDnia AS int;
    WHILE @@FETCH_STATUS = 0
      BEGIN
        FETCH NEXT FROM CursorRezerwacji
        INTO @IDRezerwacjiDnia;
        EXEC dbo.AnulowanieRezerwacjiDniaKonferencji @IDRezerwacjiDnia;
      END

    CLOSE CursorWarsztatu;
    DEALLOCATE CursorWarsztatu;

    BEGIN TRANSACTION
    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION
    DECLARE @msg nvarchar(2048) = error_message()
    RAISERROR (@msg, 10, 1)
    END CATCH
  END
GO

--triggery
if OBJECT_ID('BrakWolnychMiejscNaDzienKonferencji', N'TR') is not null
  drop TRIGGER BrakWolnychMiejscNaDzienKonferencji
GO

if OBJECT_ID('WarsztatWTymSamymCzasie', N'TR') is not null
  drop TRIGGER WarsztatWTymSamymCzasie
GO

if OBJECT_ID('CzyWarsztatNalezyDoKonferencjiUczestnika', N'TR') is not null
  drop TRIGGER CzyWarsztatNalezyDoKonferencjiUczestnika
GO

if OBJECT_ID('CzyPoprawnaDataDniaKonferencji', N'TR') is not null
  drop TRIGGER CzyPoprawnaDataDniaKonferencji
GO

if OBJECT_ID('CzyPoprawnaLiczbaDniKonferencji', N'TR') is not null
  drop TRIGGER CzyPoprawnaLiczbaDniKonferencji
 GO

CREATE TRIGGER BrakWolnychMiejscNaDzienKonferencji
ON dbo.UczestnicyKonferencji
AFTER INSERT
AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @ID_Konferencji int
		SET @ID_Konferencji = (SELECT ID_Dnia FROM dbo.RezerwacjeDni 
								WHERE ID_Rezerwacji = 
								(SELECT ID_RezerwacjiKonferencji FROM Inserted))
							
		IF dbo.WolneMiejscaDzienKonferencji(@ID_Konferencji) = 0
		BEGIN
			RAISERROR ('Na konferencji nie ma ju¿ wolnych miejsc', 10, 1)
		END
	END
GO

CREATE TRIGGER CzyWarsztatNalezyDoKonferencjiUczestnika
ON dbo.UczestnicyWarsztatow
AFTER INSERT
AS
	BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_RezerwacjiWarsztatu int
	SET @ID_RezerwacjiWarsztatu = (SELECT Inserted.ID_RezerwacjiWarsztatu FROM Inserted)
	DECLARE @ID_Uczestnika INT 
	SET @ID_Uczestnika = (SELECT ID_Uczestnika FROM Inserted)					
	IF dbo.WarsztatNalezyDoKonferencjiUczestnika(@ID_Uczestnika,@ID_RezerwacjiWarsztatu) = 0
	BEGIN
		RAISERROR ('Uczestnik nie jest zarejestrowany na odpowiednia konferencje', 10, 1)
	END
END
GO

CREATE TRIGGER CzyPoprawnaDataDniaKonferencji
ON dbo.DniKonferencji
AFTER INSERT
AS
	BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_Dnia int
	SET @ID_Dnia = (SELECT Inserted.ID_Dnia FROM Inserted)
	DECLARE @Data date
	SET @Data = (SELECT Inserted.Data FROM Inserted)					
	IF dbo.PoprawnaDataDniaKonferencji(@ID_Dnia, @Data) = 0
	BEGIN
		RAISERROR ('Wpisana data nie zawiera sie w ramach konferencji', 10, 1)
	END
END
GO

CREATE TRIGGER CzyPoprawnaLiczbaDniKonferencji
ON dbo.DniKonferencji
AFTER INSERT
AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @ID_Konferencji int
		SET @ID_Konferencji = (SELECT Inserted.ID_Konferencji FROM Inserted)					
		IF dbo.PoprawnaLiczbaDniPrzypisanychDoKonferencji(@ID_Konferencji) = 0
		BEGIN
			RAISERROR ('Do konferencji przypisana jest za duza liczba dni', 10, 1)
	END
END
GO

CREATE TRIGGER WarsztatWTymSamymCzasie
ON dbo.UczestnicyWarsztatow
AFTER INSERT
AS
	BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_RezerwacjiWarsztatu int
	SET @ID_RezerwacjiWarsztatu = (SELECT Inserted.ID_RezerwacjiWarsztatu FROM Inserted)
	DECLARE @ID_Uczestnika INT 
	SET @ID_Uczestnika = (SELECT ID_Uczestnika FROM Inserted)					
	IF dbo.KolizjaTrwaniaWarsztatu(@ID_Uczestnika,@ID_RezerwacjiWarsztatu) = 1
	BEGIN
		RAISERROR ('Ten uczestnik ma w tym czasie inny warsztat', 10, 1)
	END
END
GO
