USE Konferencje

EXEC dbo.DodajKlienta 'Bambaryło', 111111111, 'Jacek', 'Bambaryło', 'Kraków' , 'Dietla' , '44-444' , 2 , 2 , 111111111, 'jacek.bambaryło@op.pl';

SELECT *
FROM dbo.Klienci