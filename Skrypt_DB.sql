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
