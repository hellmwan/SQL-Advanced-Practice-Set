--Soru: tblEvent tablosuna yeni bir olay eklenirken; 
--eğer eklenen olayın ülkesi 'Space' ise işlemi iptal edip (rollback) "Uzay olayları henüz kaydedilemez!" mesajı veren, 
--değilse eklenen olayın kategorisini ekrana basan trigger.

CREATE TRIGGER tr_OlayKontrolSistemi 
ON tblEvent 
AFTER INSERT 
AS
BEGIN
    IF (SELECT tblCountry.CountryName FROM tblCountry JOIN inserted ON tblCountry.CountryID = inserted.CountryID) = 'Space'
    BEGIN
        PRINT 'Uzay olayları henüz kaydedilemez!'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        SELECT tblCategory.CategoryName AS 'Eklenen Kategori'
        FROM tblCategory
        JOIN inserted ON tblCategory.CategoryID = inserted.CategoryID
    END
END

--Soru: Dışarıdan bir kategori adı alan; bu kategorideki olayları, eğer olay sayısı 3'ten az ise "Yetersiz Veri" mesajı veren, 
--3 veya daha fazla ise olayları listeleyen prosedür.

CREATE PROCEDURE sp_KategoriAnaliz (@Kategori NVARCHAR(50)) 
AS
BEGIN
    DECLARE @Sayi INT
    SELECT @Sayi = COUNT(tblEvent.EventID) FROM tblEvent 
    JOIN tblCategory ON tblEvent.CategoryID = tblCategory.CategoryID
    WHERE tblCategory.CategoryName = @Kategori

    IF @Sayi < 3
        PRINT 'Yetersiz Veri'
    ELSE
        SELECT tblEvent.EventName, tblEvent.EventDate FROM tblEvent
        JOIN tblCategory ON tblEvent.CategoryID = tblCategory.CategoryID
        WHERE tblCategory.CategoryName = @Kategori
END

--Soru: Parametre olarak EventID alan ve o olayın kaç yıldır veritabanında olduğunu (bugünkü yıldan farkını) döndüren bir fonksiyon yazıp, 
--bu fonksiyonu 'Politics' kategorisindeki olaylar için kullanınız.

CREATE FUNCTION fn_OlayYasiBul (@EID INT) RETURNS INT 
AS
BEGIN
    RETURN (SELECT YEAR(GETDATE()) - YEAR(EventDate) FROM tblEvent WHERE EventID = @EID)
END
-- Kullanımı:
SELECT EventName, dbo.fn_OlayYasiBul(EventID) AS 'Olay Yaşı' FROM tblEvent
JOIN tblCategory ON tblEvent.CategoryID = tblCategory.CategoryID
WHERE tblCategory.CategoryName = 'Politics'

--Soru: Hiç olayı (event) bulunmayan ülkelerin isimlerinin sonuna ' - PASİF' yazısını ekleyen SQL kodunu yazınız.

UPDATE tblCountry
SET CountryName = CountryName || ' - PASİF'
WHERE CountryID NOT IN (SELECT DISTINCT CountryID FROM tblEvent)

--Soru: 'Europe' ve 'Asia' kıtalarındaki ülkelerin, her birinin toplam olay sayısını; 
--olay sayısı 2'den büyük olanlar için azalan sırada listeleyiniz.

SELECT tblCountry.CountryName 
AS 'Ülke Adı', COUNT(tblEvent.EventID) AS 'Toplam'
FROM tblEvent
JOIN tblCountry ON tblEvent.CountryID = tblCountry.CountryID
JOIN tblContinent ON tblCountry.ContinentID = tblContinent.ContinentID
WHERE tblContinent.ContinentName IN ('Europe', 'Asia')
GROUP BY tblCountry.CountryName
HAVING COUNT(tblEvent.EventID) > 2
ORDER BY COUNT(tblEvent.EventID) DESC

--Soru: 'France' (Fransa) ülkesinde gerçekleşen ve 1800 ile 1900 yılları arasında olmayan (dışında kalan) tüm olayları siliniz.

DELETE tblEvent
FROM tblEvent
JOIN tblCountry ON tblEvent.CountryID = tblCountry.CountryID
WHERE tblCountry.CountryName = 'France'
  AND YEAR(tblEvent.EventDate) NOT BETWEEN 1800 AND 1900

--Soru: Bir olay güncellendiğinde (UPDATE), olayın eski tarihini ve yeni tarihini ekrana 
--"X olayı Y tarihinden Z tarihine güncellendi" şeklinde yazdıran trigger.

CREATE TRIGGER tr_TarihLog 
ON tblEvent 
AFTER UPDATE 
AS
BEGIN
    SELECT 
        inserted.EventName + ' olayı ' + 
        CAST(deleted.EventDate AS NVARCHAR) + ' tarihinden ' + 
        CAST(inserted.EventDate AS NVARCHAR) + ' tarihine güncellendi' AS 'Güncelleme Bilgisi'
    FROM inserted
    JOIN deleted ON inserted.EventID = deleted.EventID
END

--Soru: Tüm olayları listeleyiniz; ancak EventDetails kısmı boş (NULL) olanların yerine 'Detay Girilmemiş' yazısı görünsün.

SELECT EventName, ISNULL(EventDetails, 'Detay Girilmemiş') AS 'Açıklama'
FROM tblEvent

--Soru: Dışarıdan bir hafta numarası (1-52) alan ve o haftada gerçekleşen olayları ülke adlarıyla birlikte listeleyen prosedür.

CREATE PROCEDURE sp_HaftalikRapor (@Hafta INT) AS
BEGIN
    SELECT tblEvent.EventName, tblCountry.CountryName, tblEvent.EventDate
    FROM tblEvent
    JOIN tblCountry ON tblEvent.CountryID = tblCountry.CountryID
    WHERE DATEPART(WEEK, tblEvent.EventDate) = @Hafta
END