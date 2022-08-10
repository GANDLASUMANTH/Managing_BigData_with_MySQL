Database ua_dillards;

--Question 2
SELECT COUNT (DISTINCT sku)
FROM skuinfo
WHERE brand='Polo fas' AND (size='XXL' OR color='black');

--Question 3
SELECT DISTINCT EXTRACT (MONTH from t.saledate) AS NumMonth,EXTRACT (YEAR from t.saledate) AS NumYear, COUNT (DISTINCT t.saledate) AS SaleDays, s.store, s.city
FROM trnsact t JOIN strinfo s
ON t.store=s.store
GROUP BY NumMonth, NumYear, s.store, s.city
ORDER BY SaleDays ASC;

--Question 4
SELECT TOP 10 sku, SUM(CASE WHEN EXTRACT (MONTH from saledate)=11 THEN amt END) AS NovSales,
SUM (CASE WHEN EXTRACT (MONTH from saledate)=12 THEN amt END) AS DecSales,
(DecSales-NovSales) AS LargestDiff
FROM TRNSACT
WHERE stype='P'
GROUP BY sku
ORDER BY LargestDiff DESC;

--Question 5
SELECT NewTable.totalskuT, COUNT (DISTINCT sk.sku) AS totalskusk, (NewTable.totalskuT-totalskusk) AS SkuDiff, NewTable.vendor
FROM (SELECT COUNT(DISTINCT t.sku)AS totalskuT, s.vendor, t.store
FROM skuinfo s JOIN trnsact t
ON s.sku=t.sku
GROUP BY s.vendor, t.store) AS NewTable
JOIN skstinfo sk
ON sk.store=NewTable.store
GROUP BY NewTable.vendor 
ORDER BY SkuDiff DESC;

--Question 6
SELECT STDDEV_POP(t.sprice) AS SDEV, s.sku, s.brand, COUNT(t.amt) AS transactions
FROM skuinfo s JOIN trnsact t
ON s.sku=t.sku
GROUP BY s.sku, s.brand
HAVING transactions >100
ORDER BY SDEV DESC;

--Question 7
SELECT COUNT (DISTINCT t.saledate) AS count_days, s.store, (SUM(t.amt)/count_days)AS DailyRev,
SUM (CASE WHEN EXTRACT (MONTH from t.saledate)=11 THEN t.amt END) AS NovSales,
SUM (CASE WHEN EXTRACT (MONTH from t.saledate)=12 THEN t.amt END) AS DecSales,
(DecSales-NovSales) AS LargestDiff, s.city
FROM trnsact t JOIN strinfo s
ON t.store=s.store
GROUP BY s.store, s.city
HAVING count_days>=20
ORDER BY LargestDiff DESC;

--Question 11
SELECT s.city, NewTable.dept, NewTable.LargestDiff
FROM (SELECT sk.dept, t.store,COUNT (DISTINCT t.saledate) AS count_days,
(CASE WHEN EXTRACT (MONTH from t.saledate)=11 THEN (SUM(t.amt)/count_days) END) AS NovSales,
(CASE WHEN EXTRACT (MONTH from t.saledate)=12 THEN (SUM(t.amt)/count_days) END) AS DecSales,
(DecSales/NovSales) AS LargestDiff
FROM skuinfo sk JOIN trnsact t
ON sk.sku=t.sku
GROUP BY sk.dept, t.store
HAVING NovSales>1000 AND DecSales>1000) AS NewTable
JOIN strinfo s
ON s.store = NewTable.store
GROUP BY s.city, NewTable.dept, t.store
ORDER BY LargestDiff DESC;
