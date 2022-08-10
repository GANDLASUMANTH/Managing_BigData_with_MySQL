/* 
Dillard's is a department store with ~300 stores and ~7 billion$ revenue. The Dillard's Teradata database made available contains 6 tables:

DEPTINFO (rows: 60)
STORE_MSA (rows: 333)
STRINFO (rows: 453)
SKUINFO (rows: 1,564,178)
SKSINFO (rows: 39,230,146)
TRNSACT (rows: 120,916,896)
*/


-- Information extraction on Dillard's database using Teradata SQL queries:

/*
Query 1: Find the highest priced item sold in each department in California stores, list sku, price, brand, department, city names in output.
*/

SELECT t.sku, t.sprice, s.brand, d.deptdesc, r.city
FROM trnsact AS t
INNER JOIN skuinfo AS s
ON t.sku = s.sku
INNER JOIN deptinfo AS d
ON s.dept = d.dept
INNER JOIN strinfo AS r
ON r.store = t.store
WHERE r.state = 'CA'
QUALIFY ROW_NUMBER() OVER(PARTITION BY s.dept ORDER BY t.sprice DESC) = 1
ORDER BY t.sprice DESC, d.deptdesc, s.brand, r.city
;


/*
Query 2: Find the top 5 highest priced item sold in each department, list sku, price, brand, department, city names in output.
*/

SELECT t.sku, t.sprice, s.brand, d.deptdesc, r.city 
FROM trnsact AS t
INNER JOIN skuinfo AS s
ON t.sku = s.sku
INNER JOIN deptinfo AS d
ON s.dept = d.dept
INNER JOIN strinfo AS r
ON r.store = t.store
QUALIFY ROW_NUMBER() OVER(PARTITION BY s.dept ORDER BY t.sprice DESC) <= 5
ORDER BY d.deptdesc ASC, t.sprice DESC;
;


/*
Query 3: How many distinct skus have the brand “Polo fas”, and are either size “XXL” or “black” in color?
*/

SELECT sku, size, color
FROM skuinfo
WHERE brand='Polo fas' AND (size='XXL' OR color='black');


/*
Query 4: Create a flat table in the database with information from all tables for the sku = '9417605'.
*/

SELECT *
FROM 
(
SELECT *
FROM trnsact
WHERE sku = '9417605'
)
AS t
INNER JOIN skuinfo AS u
ON t.sku = u.sku
INNER JOIN skstinfo AS k
ON k.sku = u.sku
INNER JOIN strinfo AS r
ON r.store = k.store
INNER JOIN store_msa AS m
ON m.store = t.store
;


/*
Query 5: List the number of transactions in the database by quarters of a season.
*/

SELECT CASE WHEN EXTRACT(MONTH FROM saledate) IN (1, 2, 3) THEN '1st'
            WHEN EXTRACT(MONTH FROM saledate) IN (4, 5, 6) THEN '2nd'
            WHEN EXTRACT(MONTH FROM saledate) IN (7, 8, 9) THEN '3rd'
            WHEN EXTRACT(MONTH FROM saledate) IN (10, 11, 12) THEN '4th'
            END AS quarter, count(saledate) AS num_transactions
FROM trnsact
GROUP BY quarter
ORDER BY quarter ASC
;


/*
Query 6: There was one store in the database which had only 11 days in one of its months (in other words, that store/month/year
combination only contained 11 days of transaction data). In what city and state was this store located?
*/

SELECT t2.city, t2.state, t2.store, t1.open_days
FROM (SELECT store, CAST(EXTRACT (YEAR FROM saledate) AS CHAR(4)) || '-' || CAST(EXTRACT (MONTH FROM saledate) 
               AS CHAR(2)) AS year_month, COUNT(DISTINCT saledate) AS open_days
      FROM trnsact
      WHERE year_month <> '2005-8'
      GROUP BY store, year_month
      HAVING open_days = 11) AS t1 
INNER JOIN (SELECT store, city, state
           FROM store_msa) AS t2
ON t1.store=t2.store;


/*
Query 7: Which sku number had the greatest increase in total sales revenue from November to December?
*/

SELECT TOP 3 sku, SUM(CASE WHEN year_month='2004-11' THEN sales END) AS Nov_sum,
                  SUM(CASE WHEN year_month='2004-12' THEN sales END) AS Dec_sum,
                  (Dec_sum - Nov_sum) AS Increase
FROM (SELECT sku, CAST(EXTRACT (YEAR FROM saledate) AS CHAR(4)) || '-' || CAST(EXTRACT (MONTH FROM saledate) 
                         AS CHAR(2)) AS year_month, SUM(amt) AS sales
      FROM trnsact
      WHERE year_month <> '2005-8' AND stype='P'
      GROUP BY sku, year_month) AS t1
GROUP BY sku                  
ORDER BY Increase DESC;


/*
Query 8: What is the brand of the sku with the greatest standard deviation in sprice? 
Only examine skus which have been part of over 100 transactions.
*/

SELECT u.sku, u.brand
FROM (SELECT TOP 1 sku, COUNT(saledate) AS numTran, STDDEV_SAMP(sprice) AS SD
      FROM trnsact
      WHERE stype='P'
      GROUP BY sku
      HAVING numTran > 100
      ORDER BY SD DESC) AS sku100
LEFT JOIN skuinfo AS u
ON sku100.sku=u.sku;


/*
Query 9: What is the city and state of the store which had the greatest increase in average daily revenue from November to December?
*/

SELECT s.store, s.city, s.state, s.store, Nov_daily, Dec_daily, (Dec_daily - Nov_daily) AS inc
FROM store_msa s
INNER JOIN (
SELECT store, SUM(Nov_sum)/SUM(Nov_days) AS Nov_daily, SUM(Dec_sum)/SUM(Dec_days) AS Dec_daily
FROM (SELECT store, CASE WHEN year_month='2004-11' THEN sales END AS Nov_sum,
                          CASE WHEN year_month='2004-12' THEN sales END AS Dec_sum,
                          CASE WHEN year_month='2004-11' THEN open_days END AS Nov_days,
                          CASE WHEN year_month='2004-12' THEN open_days END AS Dec_days
           FROM (SELECT store, CAST(EXTRACT (YEAR FROM saledate) AS CHAR(4)) || '-' || CAST(EXTRACT (MONTH FROM saledate) 
                         AS CHAR(2)) AS year_month, COUNT(DISTINCT saledate) AS open_days, SUM(amt) AS sales
                 FROM trnsact
                 WHERE year_month <> '2005-8' AND stype='P'
                 GROUP BY store, year_month
                 HAVING open_days >= 21
                 ) AS t1

     ) AS t2
GROUP BY store
) AS t
ON s.store=t.store
ORDER BY inc DESC;
                  

/*
Query 10: Write a query that determines the month in which each store had its maximum number of sku units returned. During which 
month did the greatest number of stores have their maximum number of sku units returned?
*/

SELECT mon, COUNT(store) AS worst_month
FROM 
(
SELECT store, CASE year_month WHEN '2005-1' THEN 'Jan'
                              WHEN '2005-2' THEN 'Feb'
                              WHEN '2005-3' THEN 'Mar'
                              WHEN '2005-4' THEN 'Apr'
                              WHEN '2005-5' THEN 'May'
                              WHEN '2005-6' THEN 'Jun'
                              WHEN '2005-7' THEN 'Jul'
                              WHEN '2004-8' THEN 'Aug'
                              WHEN '2004-9' THEN 'Sep'
                              WHEN '2004-10' THEN 'Oct'
                              WHEN '2004-11' THEN 'Nov'
                              WHEN '2004-12' THEN 'Dec'
                END AS mon, rtd,
                ROW_NUMBER() OVER (PARTITION BY store ORDER BY rtd DESC) AS max_rtd
FROM (SELECT store, CAST(EXTRACT (YEAR FROM saledate) AS CHAR(4)) || '-' || CAST(EXTRACT (MONTH FROM saledate) 
               AS CHAR(2)) AS year_month, COUNT(sku) AS rtd
      FROM trnsact
      WHERE year_month <> '2005-8' AND stype='R'
      GROUP BY store, year_month) AS t1
QUALIFY max_rtd=1
) AS t2
GROUP BY mon
ORDER BY worst_month DESC;


/*
Query 11: Compare the average daily revenue of the store with the highest msa_income and the store with the lowest median
msa_income (according to the msa_income field). In what city and state were these two stores, and which store had a higher
average daily revenue?
*/

-- highest income
SELECT s.store, s.city, s.state, s.msa_income, t.daily_revenue
FROM store_msa s
INNER JOIN (
SELECT store, SUM(sales)/SUM(open_days) AS daily_revenue
FROM(
SELECT store, CAST(EXTRACT (YEAR FROM saledate) AS CHAR(4)) || '-' || CAST(EXTRACT (MONTH FROM saledate) 
                         AS CHAR(2)) AS year_month, COUNT(DISTINCT saledate) AS open_days, SUM(amt) AS sales
                 FROM trnsact
                 WHERE year_month <> '2005-8' AND stype='P'
                 GROUP BY store, year_month
                 HAVING open_days >= 21
) AS t1
GROUP BY store
) AS t
ON t.store=s.store
ORDER BY s.msa_income DESC;

-- lowest income
SELECT s.store, s.city, s.state, s.msa_income, t.daily_revenue
FROM store_msa s
INNER JOIN (
SELECT store, SUM(sales)/SUM(open_days) AS daily_revenue
FROM(
SELECT store, CAST(EXTRACT (YEAR FROM saledate) AS CHAR(4)) || '-' || CAST(EXTRACT (MONTH FROM saledate) 
                         AS CHAR(2)) AS year_month, COUNT(DISTINCT saledate) AS open_days, SUM(amt) AS sales
                 FROM trnsact
                 WHERE year_month <> '2005-8' AND stype='P'
                 GROUP BY store, year_month
                 HAVING open_days >= 21
) AS t1
GROUP BY store
) AS t
ON t.store=s.store
ORDER BY s.msa_income ASC;
