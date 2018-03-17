USE AdventureWorks
GO

--How many products are there in the database? How many categories and subcategories?
SELECT COUNT(ProductID) AS [Iloœæ produktów]
FROM Production.Product

SELECT COUNT(ProductCategoryID) AS [Iloœæ kategorii]
FROM Production.ProductCategory

SELECT COUNT(ProductSubcategoryID) AS [Iloœæ podkategorii]
FROM Production.ProductSubcategory

--Select products that do not have a defined color
SELECT Production.Product.Name AS [Nazwa produktu]
FROM Production.Product
WHERE Color IS NULL;

--Select annual turnover of the store in individual years.
SELECT 
	YEAR(OrderDate) AS [Rok],
	SUM(TotalDue) AS [Obrót]
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate);


--How many transactions were made at individual years?
SELECT 
	YEAR(TransactionDate) AS [Rok],
	COUNT(TransactionID) as [Transakcje]
FROM (
			SELECT TransactionID, TransactionDate 
			FROM Production.TransactionHistory
			UNION
			SELECT TransactionID, TransactionDate 
			FROM Production.TransactionHistoryArchive
) AS Transakcje
GROUP BY YEAR(Transakcje.TransactionDate)
ORDER BY YEAR(Transakcje.TransactionDate);

--Select products that have not been bought by any customer group by category.
SELECT	P.[Name] AS [Nazwa produktu],
		PC.[Name] AS [Kategoria]
FROM Production.Product P
RIGHT JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
RIGHT JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail)
GROUP BY PC.[Name], P.[Name] 

--Calculate the minimum and maximum amount of the discount granted for products in individual sub-categories
SELECT	PS.[Name] AS [Podkategoria],
		MAX(DiscountPct * ListPrice) AS [Maksymalna kwota],
		MIN(DiscountPct * ListPrice) AS [Minimalna kwota]
FROM Sales.SpecialOffer SO
JOIN Sales.SpecialOfferProduct SP ON SO.SpecialOfferID = SP.SpecialOfferID
JOIN Production.Product P ON P.ProductID = SP.ProductID
JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
WHERE DiscountPct != 0
GROUP BY PS.[Name];

--Select products whose price is higher than the average price of products in the store.
SELECT 
	P.[Name] AS [Produkt],
	P.[ListPrice] AS [Cena]
FROM Production.Product P
WHERE P.[ListPrice] > (SELECT AVG([ListPrice]) FROM Production.Product)
ORDER BY P.[ListPrice], P.[Name];

--How many products are sold in individual months on average?
SELECT 
    Month(SOH.OrderDate) AS [Miesi¹c],
    SUM(SOD.OrderQty)/ (
          SELECT DateDiff(year, MIN(OrderDate), MAX(OrderDate))
          FROM Sales.SalesOrderHeader
    ) AS [Œrednia sprzeda¿]
FROM Sales.SalesOrderHeader SOH
INNER JOIN Sales.SalesOrderDetail SOD
    ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY Month(SOH.OrderDate)
ORDER BY [Miesi¹c];

--How much on average does the customer wait for the delivery of ordered products? Prepare a statement depending on the country.
SELECT 
	ST.[Name] AS [Kraj],
 	AVG(DATEDIFF(DAY,OrderDate,DueDate)) AS [Czas oczekiwania]
FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN Sales.SalesTerritory ST
ON SOH.TerritoryID = ST.TerritoryID
GROUP BY ST.[Name];
