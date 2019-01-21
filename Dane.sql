USE Konferencje

EXEC dbo.DodajKlienta 'Bambaryło', 111111111, 'Jacek', 'Bambaryło', 'Kraków' , 'Dietla' , '44-444' , 2 , 2 , 111111111, 'jacek.bambaryło@op.pl';

EXEC dbo.DodajCennik 10,0.75,0.7,0.8

EXEC dbo.DodajLokalizacje 'Kraków','Dietla','44-444',1;

EXEC dbo.DodajKonferencje 'Konfa','01-10-2019','01-11-2019',1,1

EXEC dbo.DodajDzienKonferencji 1,'01-10-2019',10;

SELECT * FROM dbo.Konferencje
SELECT *
FROM dbo.Klienci
SELECT * FROM dbo.DniKonferencji
