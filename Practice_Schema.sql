-- 1. Kıtalar Tablosu
CREATE TABLE tblContinent (
    ContinentID INTEGER PRIMARY KEY AUTOINCREMENT,
    ContinentName VARCHAR(50) NOT NULL,
    Summary TEXT
);

-- 2. Kategoriler Tablosu
CREATE TABLE tblCategory (
    CategoryID INTEGER PRIMARY KEY AUTOINCREMENT,
    CategoryName VARCHAR(50) NOT NULL
);

-- 3. Ülkeler Tablosu
CREATE TABLE tblCountry (
    CountryID INTEGER PRIMARY KEY AUTOINCREMENT,
    CountryName VARCHAR(100) NOT NULL,
    ContinentID INTEGER,
    FOREIGN KEY (ContinentID) REFERENCES tblContinent(ContinentID)
);

-- 4. Olaylar Tablosu (Merkezi Tablo)
CREATE TABLE tblEvent (
    EventID INTEGER PRIMARY KEY AUTOINCREMENT,
    EventName VARCHAR(255) NOT NULL,
    EventDetails TEXT,
    EventDate DATETIME,
    CountryID INTEGER,
    CategoryID INTEGER,
    FOREIGN KEY (CountryID) REFERENCES tblCountry(CountryID),
    FOREIGN KEY (CategoryID) REFERENCES tblCategory(CategoryID)
);