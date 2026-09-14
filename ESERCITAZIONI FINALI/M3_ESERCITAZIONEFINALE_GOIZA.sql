-- =============================================================================
-- M3_ESERCITAZIONEFINALE_GOIZA / W8D4 / TOYSGROUP
-- =============================================================================
-- =============================================================================
-- TASK 1a: Progettazione concettuale
-- =============================================================================
/*
1 Entità, Attributi Chiave e Descrittivi:
    - Product (Entità) // Chiave primaria: ProductKey // Attributi Descrittivi: ProductName, Category
    - Region (Entità) // Chiave primaria: RegionKey // Attributi Descrittivi: Country, SalesRegion
    - Sales (Entità) // Chiave primaria: SalesKey // Attributi Descrittivi: SalesDate, Quantity, SalesAmount

 2 Cardinalità delle relazioni:
    - Product - Sales: 1:N (Un prodotto può essere venduto in 0 o molte transazioni di vendita; una transazione si riferisce a un solo prodotto).
    - Region - Sales: 1:N (Una regione può essere associata a 0 o molte transazioni di vendita; una transazione si riferisce a una sola regione).

 3 Gerarchie:
    - Product include Category // un attributo descrittivo di Product.
    - Region include State //  un attributo descrittivo della regione di vendita.
*/
-- =============================================================================
-- TASK 1b: Progettazione logica
-- =============================================================================
/*
 1 Tabella: Product
    - ProductKey (INT, PK)
    - ProductName (VARCHAR(100), NOT NULL)
    - Category (VARCHAR(50), NOT NULL)

 2 Tabella: Region
    - RegionKey (INT, PK)
    - Country (VARCHAR(50), NOT NULL)
    - SalesRegion (VARCHAR(50), NOT NULL)

 3 Tabella: Sales
    - SalesKey (INT, PK)
    - Productkey (INT, FK -> Product.ProductKey)Cardinalità N:1
    - Regionkey (INT, FK -> Region.RegionKey)Cardinalità N:1
    - SalesDate (DATE, NOT NULL)
    - Quantity (INT, NOT NULL)
    - SalesAmount (DECIMAL(10,2), NOT NULL)
*/
-- =============================================================================
-- TASK 2: DDL - Creazione delle tabelle
-- =============================================================================

-- Tramite il comando "create database" creo prima di tutto il relativo database ToysGroup su cui lavorare.
CREATE DATABASE ToysGroup;


-- Tramite il comando "use" indico al software il database da puntare.
USE ToysGroup;


CREATE TABLE Product (
	ProductKey INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL
);

CREATE TABLE Region (
	RegionKey INT PRIMARY KEY,
    Country VARCHAR(50) NOT NULL,
    SalesRegion VARCHAR(50) NOT NULL
);

CREATE TABLE Sales (
	SalesKey INT PRIMARY KEY,
    ProductKey INT NOT NULL,
    RegionKey INT NOT NULL,
    SalesDate DATE NOT NULL,
    Quantity INT NOT NULL,
    SalesAmount DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Sales_Product 
		FOREIGN KEY (ProductKey) REFERENCES Product(ProductKey),
    CONSTRAINT FK_Sales_Region 
		FOREIGN KEY (RegionKey) REFERENCES Region(RegionKey)
);

-- =============================================================================
-- TASK 3: Popolamento dati
-- =============================================================================

-- 1. Inserimento prodotti (almeno 4 prodotti distribuiti su 2 categorie)
INSERT INTO Product (ProductKey, ProductName, Category) VALUES
(101, 'Bikes-100', 'Bikes'),
(102, 'Bikes-200', 'Bikes'),
(103, 'Action Figure Hero', 'Toys'),
(104, 'Puzzle 1000 Pieces', 'Toys'),
(105, 'Bikes-300', 'Bikes'); 

-- 2. Inserimento regioni (almeno 3 stati distribuiti su 2 regioni di vendita)
INSERT INTO Region (RegionKey, Country, SalesRegion) VALUES
(1, 'France', 'WestEurope'),
(2, 'Germany', 'WestEurope'),
(3, 'Italy', 'SouthEurope');

-- 3. Inserimento transazioni (almeno 10 transazioni distribuite su più anni)
INSERT INTO Sales (SalesKey, ProductKey, RegionKey, SalesDate, Quantity, SalesAmount) VALUES
(1, 101, 1, '2024-01-15', 2, 300.00),
(2, 102, 1, '2024-03-20', 1, 250.00),
(3, 103, 2, '2024-05-10', 5, 100.00),
(4, 101, 2, '2024-11-05', 3, 450.00),
(5, 104, 3, '2025-01-12', 4, 80.00),
(6, 102, 3, '2025-02-18', 2, 500.00),
(7, 103, 1, '2025-04-22', 10, 200.00),
(8, 101, 3, '2025-07-30', 1, 150.00),
(9, 104, 2, '2025-09-14', 2, 40.00),
(10, 102, 1, '2025-10-01', 3, 750.00),
(11, 102, 1, '2026-09-01', 3, 750.00),
(12, 103, 1, '2026-01-01', 5, 750.00),
(13, 103, 1, '2026-01-01', 7, 750.00);

-- =============================================================================
-- TASK 4a: Integrità e JOIN
-- =============================================================================

SELECT * FROM Sales;
SELECT * FROM Product;
SELECT * FROM Region;

-- 1. Verifica dell'univocità della chiave primaria per ciascuna tabella

SELECT ProductKey, COUNT(*) AS CountPK FROM Product GROUP BY ProductKey HAVING COUNT(*) > 1;
SELECT RegionKey, COUNT(*) AS CountPK FROM Region GROUP BY RegionKey HAVING COUNT(*) > 1;
SELECT SalesKey, COUNT(*) AS CountPK FROM Sales GROUP BY SalesKey HAVING COUNT(*) > 1;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ToysGroup'
  AND TABLE_NAME IN ('Product', 'Region', 'Sales')
  AND CONSTRAINT_NAME = 'PRIMARY';


-- 2 & 3. INNER JOIN con colonna booleana (più di 180 giorni dalla data vendita).

-- Uso per leggibilitá supponendo di elaborare un report di una filiale in Italia, degli alias in Italiano.

SELECT 
    p.ProductKey as CodicePrdotto,
    p.Category as Categoria,
    r.Country as Stato,
    r.SalesRegion as ZonaVendita,
    s.SalesDate as DataVendita,
    CASE 
        WHEN DATEDIFF(CURRENT_DATE(), s.SalesDate) > 180 THEN 1 
        ELSE 0 
    END AS OrdineHaPiudi180giorni
FROM Sales s
INNER JOIN Product p ON s.ProductKey = p.ProductKey
INNER JOIN Region r ON s.RegionKey = r.RegionKey;

-- =============================================================================
-- TASK 4b: Aggregazioni e raggruppamenti
-- =============================================================================

-- Uso per leggibilitá supponendo di elaborare un report di una filiale in Italia, degli alias in Italiano.

-- 1. Fatturato totale per prodotto e per anno
SELECT 
    ProductKey AS CodiceProdotto,
    YEAR(SalesDate) AS AnnoDiVendita,
    SUM(SalesAmount) AS TotaleVendite
FROM Sales
GROUP BY ProductKey, YEAR(SalesDate);

-- 2. Fatturato totale per stato e per anno, ordinato per data e fatturato decrescente

SELECT 
    r.Country as Stato,
    YEAR(s.SalesDate) AS AnnoDiVendita,
    SUM(s.SalesAmount) AS TotaleVendite
FROM Sales s
INNER JOIN Region r 
	ON s.RegionKey = r.RegionKey
GROUP BY 
	r.Country, YEAR(s.SalesDate)
ORDER BY 
	AnnoDiVendita ASC, TotaleVendite DESC;

-- 3. Categoria di prodotto più richiesta dal mercato (misurata come quantità totale venduta)

-- Versione 1 agendo limitato ad una sola riga ordinando in ordine descrescente la prima mi da la categoria con maggiori vendita
SELECT 
    p.Category AS Categoria,
    SUM(s.Quantity) AS TotaleQuantitaVenduta
FROM Sales s
INNER JOIN Product p 
	ON s.ProductKey = p.ProductKey
GROUP BY 
	p.Category
ORDER BY 
	TotaleQuantitaVenduta DESC
LIMIT 1;

-- Versione 2 mando in output la categoria con maggiori vendite agendo con la clausola having che trova la corrispondenza perché ho bisogno di filtrare sulla somma
SELECT 
	p.Category AS Categoria, 
    SUM(s.Quantity) AS TotaleQuantitaVenduta
FROM Sales s
JOIN Product p 
	ON s.ProductKey = p.ProductKey
GROUP BY p.Category
HAVING SUM(s.Quantity) = (
    SELECT 
		MAX(TotaleCategoria)
    FROM (
        SELECT 
			SUM(s2.Quantity) AS TotaleCategoria
			FROM Sales s2
			JOIN Product p2 
				ON s2.ProductKey = p2.ProductKey
			GROUP BY 
				p2.Category
    ) AS Sub
);

-- =============================================================================
-- TASK 4c: Subquery e CTE
-- =============================================================================

-- Uso per leggibilitá supponendo di elaborare un report di una filiale in Italia, degli alias in Italiano.

-- 1. Calcolare la quantità media venduta per prodotto nell'ultimo anno censito

SELECT 
    AVG(QuantitaTotale) AS MediaQuantitaUltimoAnno
FROM (
    SELECT 
        s.ProductKey,
        SUM(s.Quantity) AS QuantitaTotale
    FROM Sales s
    WHERE YEAR(s.SalesDate) = 
		(SELECT 
			MAX(YEAR(SalesDate)) 
		FROM Sales)
    GROUP BY s.ProductKey
) AS SubQueryAvg;

-- 2.Utilizzare la subquery del punto 1 in una condizione WHERE per filtrare i prodotti sopra la media

SELECT 
    ProductKey AS CodiceProdotto,
    SUM(Quantity) AS QuantitaTotale
FROM Sales
WHERE YEAR(SalesDate) = (SELECT MAX(YEAR(SalesDate)) FROM Sales)
GROUP BY ProductKey
HAVING SUM(Quantity) > (
    SELECT AVG(QuantitaTotale)
    FROM (
        SELECT SUM(Quantity) AS QuantitaTotale
        FROM Sales
        WHERE YEAR(SalesDate) = (SELECT MAX(YEAR(SalesDate)) FROM Sales)
        GROUP BY ProductKey
    ) AS SubQueryMedia
);

-- 3. Stesso calcolo utilizzando una CTE
WITH VenditeUltimoAnno AS (
    SELECT 
        ProductKey as CodiceProdotto,
        SUM(Quantity) AS QuantitaTotale
    FROM Sales
    WHERE YEAR(SalesDate) = (SELECT MAX(YEAR(SalesDate)) FROM Sales)
    GROUP BY ProductKey
),
QuantitaMedia AS (
    SELECT AVG(QuantitaTotale * 1.0) AS MediaQuantita
    FROM VenditeUltimoAnno
)
SELECT 
    vua.CodiceProdotto,
    vua.QuantitaTotale
FROM VenditeUltimoAnno vua
CROSS JOIN QuantitaMedia qm
WHERE vua.QuantitaTotale > qm.MediaQuantita;

-- =============================================================================
-- TASK 4d: Window Functions
-- =============================================================================

-- Uso per leggibilitá supponendo di elaborare un report di una filiale in Italia, degli alias in Italiano.


-- 1. Classifica prodotto per fatturato totale all'interno della propria categoria

SELECT 
    p.ProductKey as CodiceProdotto,
    p.Category as Categoria,
    SUM(s.SalesAmount) AS TotaleVendite,
    DENSE_RANK() OVER (
        PARTITION BY p.Category 
        ORDER BY SUM(s.SalesAmount) DESC
    ) AS PosizioneClassificaCategorie
FROM Sales s
	INNER JOIN Product p 
    ON s.ProductKey = p.ProductKey
GROUP BY p.ProductKey, p.Category;

-- 2. Totale progressivo del fatturato della regione fino a ciascuna data

SELECT 
    s.SalesKey as CodiceVenditore,
    s.RegionKey as CodiceRegione,
    r.SalesRegion as RegioneVendita,
    s.SalesDate as DataVendita,
    s.SalesAmount as ImportoVendita,
    SUM(s.SalesAmount) OVER (
        PARTITION BY s.RegionKey 
        ORDER BY s.SalesDate, s.SalesKey
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS TotaleProgressivo
FROM Sales s
INNER JOIN Region r 
ON s.RegionKey = r.RegionKey;

-- 3. Confronto del fatturato di ogni transazione con la transazione precedente della stessa regione

-- Creo una CTE che calcola il prezzo precente

WITH cpp as (
	SELECT
		s.SalesKey as CodiceVenditore,
		s.RegionKey as CodiceRegione,
		r.SalesRegion as RegioneVendita,
		s.SalesDate as DataVendita,
		s.SalesAmount as ImportoVendita,
		LAG(s.SalesAmount) OVER (
				PARTITION BY s.RegionKey 
				ORDER BY s.SalesDate, s.SalesKey
		) AS PrezzoPrecedente
	FROM Sales s
    INNER JOIN Region r 
		ON s.RegionKey = r.RegionKey
)

-- Utilizzo la CTE andando a pulire la query dai null con una struttura condizionale
SELECT 
    cpp.CodiceVenditore,
    cpp.CodiceRegione,
    cpp.RegioneVendita,
    cpp.DataVendita,
    cpp.ImportoVendita,
    CASE
		WHEN PrezzoPrecedente IS NULL THEN 'NessunaTransazionePrecedente'
		ELSE PrezzoPrecedente
	END AS ImportoPrecedente
FROM cpp;

-- =============================================================================
-- TASK 4e: Prodotti invenduti e VIEW
-- =============================================================================

-- 1. Prodotti mai venduti (Approccio 1: LEFT JOIN / Sottrazione)

SELECT 
    p.ProductKey as CodicePrdotto,
    p.ProductName as NomeProdotto
FROM Product p
LEFT JOIN Sales s ON p.ProductKey = s.ProductKey
WHERE s.SalesKey IS NULL;

-- 2. Prodotti mai venduti (Approccio 2: NOT IN / Confronto di insiemi)

SELECT 
    p.ProductKey as CodicePrdotto,
    p.ProductName as NomeProdotto
FROM Product p
WHERE p.ProductKey NOT IN (
    SELECT DISTINCT s.ProductKey 
    FROM Sales s 
    WHERE s.ProductKey IS NOT NULL
);

-- 3. Vista sui prodotti (Denormalizzata: codice, nome, categoria)

CREATE OR REPLACE VIEW DettaglioProdotti AS
SELECT 
    ProductKey as codiceProdotto,
    ProductName as nomeProdotto,
    Category as categoria
FROM Product;

SELECT * FROM DettaglioProdotti;

-- 4. Vista per informazioni geografiche e vendite

CREATE OR REPLACE VIEW DettaglioZonaGeografica AS
SELECT 
    s.SalesKey AS codiceVendita,
    s.SalesDate AS dataVendita,
    s.SalesAmount AS importoVendita,
    s.Quantity AS quantita,
    r.RegionKey AS codiceRegione,
    r.Country AS RegioneVendita,
    r.SalesRegion AS Zona
FROM Sales s
INNER JOIN Region r ON s.RegionKey = r.RegionKey;

SELECT * FROM DettaglioZonaGeografica;

-- =============================================================================
-- TASK extra Governance & Privacy applicata
-- =============================================================================

-- Caso 1: Vista pubblica
-- Causa della violazione: Esposizione del costo d'acquisto (PurchaseCost) all'esterno/rivenditori. 
-- Versione corretta:

CREATE OR REPLACE VIEW vw_prodotti_rivenditori AS
SELECT 
    ProductID, 
    ProductName, 
    Category 
FROM Product;

-- Caso 2: Scheda fornitori

-- Mancanza di limitazione dell'accesso/mascheramento per dati di contatto
-- condivisi con reparti non autorizzati (Marketing) in violazione del principio di minimizzazione dei dati (GDPR).
-- Versione corretta:

CREATE TABLE SupplierContact (
    SupplierID INT PRIMARY KEY,
    Phone VARCHAR(20),
    CONSTRAINT FK_SupplierContact_Supplier FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

-- Creazione di una vista filtrata/mascherata per il reparto marketing
CREATE OR REPLACE VIEW vw_SupplierContact_Marketing AS
SELECT 
    SupplierID,
    CONCAT('***-***-', RIGHT(Phone, 4)) AS MaskedPhone
FROM SupplierContact;

-- Caso 3: Vista commerciale

-- Causa della violazione: Esposizione del costo di acquisto e del margine aziendale all'interno della vista destinata alla forza commerciale/vendite.
-- Versione corretta:

CREATE OR REPLACE VIEW vw_sales_commerciale AS
SELECT 
    SalesID, 
    SalesAmount 
FROM Sales;

-- Caso 4: Log di reporting
-- Causa della violazione: Assenza di una politica di conservazione/scadenza dei dati
-- Versione corretta:
-- Creazione tabella log con colonna di scadenza/retention

CREATE TABLE ReportAccessLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    QueryText TEXT,
    AccessDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    RetentionExpiryDate DATETIME GENERATED ALWAYS AS (DATE_ADD(AccessDate, INTERVAL 90 DAY)) STORED
);
-- Evento schedulato in MySQL per la cancellazione automatica dei log vecchi (es. > 90 giorni)
CREATE EVENT purge_old_access_logs
ON SCHEDULE EVERY 1 DAY
DO
  DELETE FROM ReportAccessLog 
  WHERE AccessDate < NOW() - INTERVAL 90 DAY;