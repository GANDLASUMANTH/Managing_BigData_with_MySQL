-- Takeaway: The most important things to take away from the strategies we used in these exercises are that: 
-- (1) real data sets are messy and it is your job as an analyst to find that mess so that you can take it into account, 
-- (2) you can design your SQL queries to accommodate data anomalies, and 
-- (3) avoid using averages of averages to summarize the performance of a group.
-- Note: Q28 and Q44

DATABASE ua_dillards;
HELP TABLE deptinfo;
SHOW TABLE deptinfo;
SELECT TOP 10 *
FROM deptinfo;
-- Get to know the schema, same to the other tables, and then create a Database_inform document

SELECT TOP 5 cost, retail, orgprice, sprice, amt 
FROM skstinfo sks JOIN trnsact t
ON sks.sku = t.sku; 
-- insepct the differences among all the prices 
-- sprice = amt , retail might be smaller than cost

-- Q1: To know how many distinct skus there are in pairs of the skuinfo, skstinfo and trnsact tables
SELECT COUNT(DISTINCT sku) FROM skuinfo;
SELECT COUNT(DISTINCT sku) FROM skstinfo;
SELECT COUNT(DISTINCT sku) FROM trnsact;
-- 1564178; 760212; 714499

-- Q2: To know how many insttances there are of each sku associated with each store in the trnsact table 
SELECT COUNT(DISTINCT t.sku) FROM trnsact t,skstinfo sks
WHERE t.store=sks.store
AND t.sku=sks.sku
-- 526366 
-- a lot of sku in trnsactare not in skstinfo??? 

-- Q3: How many different stores there are in the different tables 
SELECT COUNT(DISTINCT store) FROM strinfo;
SELECT COUNT(DISTINCT store) FROM store_msa;
SELECT COUNT(DISTINCT store) FROM skstinfo;
SELECT COUNT(DISTINCT store) FROM trnsact;
-- 453, 333, 357, 332
-- 20% stores in strinfo are discarded

-- Q4: Examine the skus in trnsact but not in skstinfo to see if anything in common
SELECT Top 50 * 
FROM trnsact 
WHERE sku NOT IN (
    SELECT sku FROM skstinfo
    )

-- Q5: What is the average profit per day? 
SELECT SUM(amt-quantity*cost)/COUNT(distinct saledate) AS avg_profit_per_day
FROM trnsact t
LEFT JOIN skstinfo sks
ON sks.sku=t.sku
AND sks.store = t.store
WHERE stype = 'P'
--$1527903.46

-- Q6: On what day was the total value(in$) of returned goods the greatest? 
SELECT TOP 3 saledate, SUM(amt) AS return_value
FROM trnsact
WHERE stype='R'
GROUP BY saledate
ORDER BY return_value DESC
-- 2004-12-27:$3,030,259.76

-- Q7: On what day was the total number of individual returned items the greatest?
SELECT TOP 3 saledate, SUM(quantity) AS return_qty
FROM trnsact
WHERE stype='R'
GROUP BY saledate
ORDER BY return_qty DESC
-- 2004-12-27: 82512

-- Q8: What is the maximum price paid for an item in our database? 
SELECT top 5 sku, MAX(sprice) AS max_sprice
FROM trnsact
WHERE stype = 'P'
GROUP BY sku
ORDER BY max_sprice DESC
-- sku 6200173: $6017

-- Q9: What is the minimum price paid for an item in our database? 
SELECT top 5 sku, MIN(sprice) AS min_sprice
FROM trnsact
WHERE stype = 'P'
GROUP BY sku
ORDER BY min_sprice
-- $0.00

-- Q9: How many departments have more than 100 brands associated with them, and what are their descriptions?
SELECT top 5 dep.dept, deptdesc, COUNT(DISTINCT brand) AS brand_num
FROM deptinfo dep
LEFT JOIN skuinfo sku
ON sku.dept=dep.dept
GROUP BY dep.dept,deptdesc
HAVING brand_num > 100
ORDER BY brand_num DESC
-- dept 447, deptdesc ENVIRON has 389 brands 

-- Q10: Retrieve the department descriptions of each of the skus in the sksinfo table
SELECT DISTINCT sks.sku, dep.dept, deptdesc
FROM deptinfo dep
LEFT JOIN skuinfo sku
ON sku.dept=dep.dept
Left Join skstinfo sks
ON sku.sku=sks.sku

-- Q11: What department, brand,style, and color had the greatest total value of returned items? 
With etc AS (SELECT DISTINCT dept, brand, style, color, SUM(amt) AS total_value
FROM trnsact t,skuinfo sku
WHERE t.sku=sku.sku AND stype = 'R'
GROUP BY dept, brand, style,color)

SELECT DISTINCT etc.dept, deptdesc, brand, style, color, total_value
FROM etc
LEFT JOIN deptinfo dep 
ON etc.dept=dep.dept
ORDER BY total_value DESC
-- Dept 4505 POLOMEN brand POLO FAS total return value $216633.59

-- Q12: In what state and zip code is the store that had the greatest total revenue during the time period monitored in our dataset? 
SELECT TOP 10 str.store, city, state, zip, SUM(amt) as revenue
FROM strinfo str 
LEFT JOIN trnsact t 
ON str.store=t.store
WHERE stype ='P'
GROUP BY str.store, city, state, zip
ORDER BY revenue DESC
-- Store 8402 in Metairie, LA: $ 24171416.58

-- Q13: What is the sku number of the item in the Dillard’s database that had the highest original sales price?
SELECT TOP 5 sku, orgprice
FROM trnsact
ORDER BY orgprice desc;
-- 6200173
 
-- Q14: How many states within the United States are Dillard’s stores located? 
SELECT DISTINCT state 
FROM strinfo; 
-- 31

-- Q15: What was the date of the earliest sale in the database where the sale price of the item did not equal the original price of the item, and what was the largest margin (original price minus sale price) of an item sold on that earliest date?
SELECT TOP 100 orgprice, sprice, orgprice-sprice AS margin, saledate
FROM trnsact
WHERE orgprice<>sprice
ORDER BY saledate ASC, margin DESC
--04/08/01, $510.00

-- Q16: On which day was Dillard’s income based on total sum of purchases the greatest
SELECT TOP 10 saledate, sum(amt) AS total_Sale
FROM TRNSACT 
WHERE stype = 'P'
GROUP BY saledate
ORDER BY total_Sale DESC;
-- 04/12/18

-- Q17: What is the deptdesc of the departments that have the top 3 greatest numbers of skus from the skuinfo table associated with them? 
SELECT TOP 3 s.dept, d.deptdesc, COUNT(DISTINCT s.sku) AS sku_num
FROM skuinfo s JOIN deptinfo d
ON s.dept=d.dept
GROUP BY s.dept, d.deptdesc
ORDER BY sku_num DESC;
-- INVEST, POLOMEN, BRIOSO

-- Q18: What is the average amount of profit Dillard’s made per day?  
SELECT SUM(amt-(cost*quantity))/ COUNT(DISTINCT saledate) AS avg_sales
FROM trnsact t JOIN skstinfo s
ON t.sku=s.sku AND t.store=s.store
WHERE stype='P';
--$1,527,903

-- Q19: What department (with department description), brand, style, and color brought in the greatest total amount of sales?    
SELECT TOP 10 d.deptdesc, s.dept, s.brand, s.style, s.color, SUM(t.AMT) AS total_Sale
FROM trnsact t, skuinfo s, deptinfo d
WHERE t.sku=s.sku 
AND s.dept=d.dept 
AND t.stype='P'
GROUP BY d.deptdesc, s.dept, s.brand, s.style, s.color
ORDER BY total_sale DESC;
-- Department 800 described as Clinique, brand Clinique, style 6142, color DDML

-- Q20: In what city and state is the store that had the greatest total sum of sales?
SELECT TOP 10 t.store, s.city, s.state, SUM(amt) AS total_sale
FROM trnsact t JOIN strinfo s
ON t.store=s.store
WHERE stype='P'
GROUP BY t.store, s.state, s.city
ORDER BY total_sale DESC;
-- Metairie, LA

-- Q21: How many states have more than 10 Dillards stores in them?    
SELECT COUNT(*) AS store_num
FROM strinfo
GROUP BY state
HAVING store_num>10
-- 15

-- Q22: How many distinct skus have the brand “Polo fas”, and are either size “XXL” or “black” in color?
SELECT COUNT (DISTINCT sku)
FROM skuinfo
WHERE brand='polo fas'
AND (size = 'XXL' OR color ='black')
-- 13623

-- Q23: How many distinct dates are there in the saledate column of the transaction table for each month/year combination? 
SELECT EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", COUNT(DISTINCT saledate) AS sale_days
FROM trnsact 
GROUP BY  "year", "month"
ORDER BY "year", "month" asc
-- from 2004/8 to 2005/8 

-- Q24: Which sku had the greatest total sales during the combined summer months of June, July and August?
SELECT sku,
SUM(CASE WHEN "month" = 6 THEN amt END) AS amt_6,
SUM(CASE WHEN "month" = 7 THEN amt END) AS amt_7,
SUM(CASE WHEN "month" = 8 THEN amt END) AS amt_8,
amt_6+amt_7+amt_8 AS total_amt
FROM (
SELECT EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", sku, amt
FROM trnsact 
WHERE "month" IN (6,7,8)
AND stype = 'P'
) AS sub
GROUP BY sku
ORDER BY total_amt desc
-- sku 4108011: $1646017.38

-- Q25: How many distinct dates are there in the saledate column of the transaction table in the datebase? 
SELECT DISTINCT store, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", COUNT(DISTINCT saledate) AS day_num
FROM trnsact 
GROUP BY "month","year",store
ORDER BY day_num 
-- a lot missing data

-- Q26: What is the average daily revenue for each store/month/year based on saledate > 20 days? 
SELECT DISTINCT store, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", SUM(amt)/COUNT(DISTINCT saledate) AS avg_revenue_day
FROM trnsact
WHERE stype ='P' 
AND ("year" <> 2005 OR "month" <> 8) 
GROUP BY "month","year",store
HAVING COUNT(DISTINCT saledate) > 20
ORDER BY avg_revenue_day
-- Requirement to clean the data: No returned, sale days over 20, and excludes Aug. 2005

-- Q27: What is the average daily revenue brought in by Dillard's stores in areas of high, medium or low levels of high school education? 
-- Define areas of “low” education as those that have high school graduation rates between 50-60%, areas of “medium” education as those 60.01-70%, and areas of “high” education above 70%.
WITH etc AS (
SELECT SUM(amt) as revenue, COUNT(DISTINCT saledate) AS days, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", store
FROM trnsact 
WHERE stype ='P'  
AND ("year" <> 2005 OR "month" <> 8) 
GROUP BY "month","year" ,store
HAVING COUNT(DISTINCT saledate) > 20
) 

SELECT 
(CASE WHEN msa_high > 70 THEN 'high_edu'
     WHEN msa_high <= 70 AND msa_high > 60 THEN 'medium_edu'
     WHEN msa_high <= 60 AND msa_high > 50 THEN 'low_edu'
     END) AS edu_level,
SUM(revenue)/ SUM(days) AS avg_revenue_day 
FROM store_msa s, etc 
WHERE s.store = etc.store
GROUP BY edu_level
-- Low_edu: $34159.76; medium_edu: $25037.89; high_edu: $20937.31

-- Q28: Compare the average daily revenues of the stores with the highest median msa_income and the lowest median msa_income. In what city and state were these stores, and which store had a higher average daily revenue?
WITH etc AS (
SELECT SUM(amt) as revenue, COUNT(DISTINCT saledate) AS days, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", store
FROM trnsact 
WHERE stype ='P'  
AND ("year" <> 2005 OR "month" <> 8) 
GROUP BY "month","year" ,store
HAVING COUNT(DISTINCT saledate) > 20
) 

SELECT s.store, state, city, SUM(revenue)/ SUM(days) AS avg_revenue_day 
FROM etc, store_msa s
WHERE s.store = etc.store
AND msa_income IN (
(SELECT max(msa_income) FROM store_msa),
(SELECT min(msa_income) FROM store_msa))
GROUP BY s.store, state, city
-- Store 3902 in SPANISH FORT, AL : $17884.08; Store 2707 in MCALLEN, TX: $56601.99
--?? You might want to use a subquery to examine the details of the maximum and minimum msa_income values at the same time.

-- Q29: What is the brand of the sku with the greatest standard deviation in sprice? Only skus over 100 transactions. 
SELECT brand, stddev_pop(sprice) AS sprice_dev
FROM trnsact t, skuinfo sku
WHERE t.sku=sku.sku
GROUP BY brand
HAVING COUNT(DISTINCT register)>100
ORDER BY sprice_dev desc
-- HICKEY-F:$212.1; KAY UNGE:$150.20; HART SCH:$140.80

-- Q30: Examine all the transactions for the sku with the greatest standard deviaion in sprice but only sku over 100 transactions. 
SELECT brand, stddev_pop(sprice) AS sprice_dev
FROM trnsact t, skuinfo sku
WHERE t.sku=sku.sku
GROUP BY brand
ORDER BY sprice_dev desc
-- ALAN MIC:$387.80; CREMIEUX:$221.50; MARUSHKA:$221.10

-- Analyzing monthly(or seasonal) sales effects: 
-- Q31: What was the average daily revenue Dillard#s brought in during each month of the year? 
SELECT EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month",SUM(amt)/COUNT(DISTINCT saledate) AS avg_revenue_day
FROM trnsact 
WHERE stype ='P'  
AND ("year" <> 2005 OR "month" <> 8) 
GROUP BY "year" ,"month"
HAVING COUNT(DISTINCT saledate) > 20
ORDER BY avg_revenue_day desc
-- Dec. 2004 highest: $11333356.01; 2rd is Feb.2005; 3th is June 2005

-- Q32: Which store, in which city and state of what store, had the greatest % in crease in average daily sales revenue from Nov. to Dec. 
WITH etc AS (
SELECT store, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", SUM(amt) AS revenue, COUNT(DISTINCT saledate) AS days
FROM trnsact 
WHERE stype ='P'  
AND "month" IN (11,12)
GROUP BY "year" ,"month", store
HAVING COUNT(DISTINCT saledate) > 20
) 

SELECT TOP 3 etc.store, city, state,
SUM(CASE WHEN "month" = 11 THEN revenue/days END) AS rev_11,
SUM(CASE WHEN "month" = 12 THEN revenue/days END) AS rev_12,
(rev_12-rev_11)/rev_11 AS growth_rate
FROM etc, strinfo str
WHERE etc.store=str.store
GROUP BY etc.store, city, state
ORDER BY growth_rate desc
-- Store 3809 in Helena, MT has grown by 124%

-- Q33: What is the city and state of the sotre that had the greatest decrease in average daily revenue from Aug. to Sep.
WITH etc AS (
SELECT store, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", SUM(amt) AS revenue, COUNT(DISTINCT saledate) AS days
FROM trnsact 
WHERE stype ='P'  
AND "month" IN (8,9)
GROUP BY "year" ,"month", store
HAVING COUNT(DISTINCT saledate) > 20
) 

SELECT etc.store, city, state,
SUM(CASE WHEN "month" = 8 THEN revenue/days END) AS rev_8,
SUM(CASE WHEN "month" = 9 THEN revenue/days END) AS rev_9,
(rev_8-rev_9)/rev_8 AS growth_rate
FROM etc, strinfo str
WHERE etc.store=str.store
GROUP BY etc.store, city, state
ORDER BY growth_rate desc
-- Store 4003 in Wesst Des Moines, IL decreased by 215% 

-- Q34: Determin the month of maximum total revenue for each store. 
-- Q34: Count the number of stores whose month of maximun total revenue was in each of the 12 months. 
WITH CTE AS(
SELECT DISTINCT store, "month", revenue,
ROW_NUMBER() OVER(PARTITION BY store ORDER BY revenue DESC) AS revenue_max
From (
SELECT store, EXTRACT(year from saledate) AS "year",EXTRACT(month from saledate) AS "month", SUM(amt) AS revenue
FROM trnsact 
WHERE stype ='P' 
AND ("year" <> 2005 OR "month" <> 8)  
GROUP BY store, "year","month"
HAVING COUNT(DISTINCT saledate) > 20
) as sub
)

SELECT store, "month"
FROM cte
WHERE revenue_max=1
-- almost all in Dec, the revenue is the highest. 

WITH CTE AS(
SELECT DISTINCT store, "month", revenue,
ROW_NUMBER() OVER(PARTITION BY store ORDER BY revenue DESC) AS revenue_max
From (
SELECT store, EXTRACT(year from saledate) AS "year",EXTRACT(month from saledate) AS "month", SUM(amt) AS revenue
FROM trnsact 
WHERE stype ='P' 
AND ("year" <> 2005 OR "month" <> 8)  
GROUP BY store, "year","month"
HAVING COUNT(DISTINCT saledate) > 20
) as sub
)

SELECT "month", COUNT(DISTINCT store) AS store_num
FROM cte
WHERE revenue_max=1
GROUP BY "month"
-- Dec. 321 stores; March and July: 3 stores each; Sep.: 1 store 

-- Q35: Determine the month of maximum average daily revnue. 
-- Q35: Count the number of stores whose month of maximum average daily revenue was in each of the 12 months.
SELECT DISTINCT store, "month", revenue_per_day,
ROW_NUMBER() OVER(PARTITION BY store ORDER BY revenue_per_day DESC) AS revenue_max
From (
SELECT store, EXTRACT(year from saledate) AS "year",EXTRACT(month from saledate) AS "month", SUM(amt)/COUNT(DISTINCT saledate) AS revenue_per_day
FROM trnsact 
WHERE stype ='P' 
AND ("year" <> 2005 OR "month" <> 8)  
GROUP BY store, "year","month"
HAVING COUNT(DISTINCT saledate) > 20
-- still Dec. is overwhelming 

WITH cte AS(
SELECT DISTINCT store, "month", revenue_per_day,
ROW_NUMBER() OVER(PARTITION BY store ORDER BY revenue_per_day DESC) AS revenue_max
From (
SELECT store, EXTRACT(year from saledate) AS "year",EXTRACT(month from saledate) AS "month", SUM(amt)/COUNT(DISTINCT saledate) AS revenue_per_day
FROM trnsact 
WHERE stype ='P' 
AND ("year" <> 2005 OR "month" <> 8)  
GROUP BY store, "year","month"
HAVING COUNT(DISTINCT saledate) > 20
) as sub
)

SELECT "month", COUNT(DISTINCT store) AS store_num
FROM cte
WHERE revenue_max=1
GROUP BY "month"
-- Dec: 317 stores, March: 4 stores; July: 3 stores; Feb: 2 stores; Sep. and May: 1 store each

-- Q36: There was one store in the database which had only 11 days in one of its months. In what city and state was this store located?
SELECT EXTRACT(month from saledate) AS "month",  count(distinct EXTRACT(day from saledate)) AS days, city, state
FROM trnsact t, strinfo s
WHERE t.store = s.store
GROUP BY state,city, "month"
ORDER BY days
-- September 1day in VERO BEACHFL; March 11days in ATLANTA GA

-- Q37: Which sku number had the greatest increase in total sales revenue from November to December?
SELECT top 5 sku, 
SUM(CASE WHEN "month" =11 THEN revenue END) AS revenue_11,
SUM(CASE WHEN "month" =12 THEN revenue END) AS revenue_12,
revenue_12 - revenue_11 AS revenue_growth 
FROM(
SELECT sku, EXTRACT(month FROM saledate) as "month", SUM(amt) AS revenue
FROM trnsact 
WHERE "month" in (11,12)
GROUP BY sku, "month"
) AS sub
GROUP BY sku
ORDER BY revenue_growth DESC
-- sku 3949538

-- Q38: What vendor has the greatest number of distinct skus in the transaction table that do not exist in the skstinfo table?  
SELECT top 5 vendor, COUNT(DISTINCT sku) AS sku_num
FROM skuinfo sku
WHERE sku IN
(SELECT sku FROM trnsact
EXCEPT
SELECT sku FROM skstinfo)
GROUP BY vendor
ORDER BY sku_num desc
-- Vendor 5715232

-- Q39: What is the brand of the sku with the greatest standard deviation in sprice?  Only examine skus which have been part of over 100 transactions.
SELECT top 5 brand, sub.sku, sprice_dev
FROM skuinfo sku, 
(SELECT sku, STDDEV_POP(sprice) AS sprice_dev,count(sku) AS sku_num
FROM trnsact 
GROUP BY sku
HAVING sku_num>100) AS sub
WHERE sku.sku = sub.sku
ORDER BY sprice_dev desc
-- Hart Sch

-- Q40: What is the city and state of the store which had the greatest increase in average daily revenue from November to December?
SELECT top 5 str.store, city, state,
SUM(CASE WHEN "month" =11 THEN revenue_per_day END) AS revenue_11,
SUM(CASE WHEN "month" =12 THEN revenue_per_day END) AS revenue_12,
revenue_12 - revenue_11 AS revenue_per_day_growth 
FROM(
SELECT store, EXTRACT(month FROM saledate) as "month", SUM(amt)/COUNT(DISTINCT saledate) AS revenue_per_day
FROM trnsact 
WHERE "month" in (11,12)
GROUP BY store,"month"
) AS sub, strinfo str
WHERE sub.store=str.store
GROUP BY str.store,city,state
ORDER BY revenue_per_day_growth DESC
-- Metairie, LA

-- Q41: Divide the msa_income groups up so that msa_incomes between 1 and 20,000 are labeled 'low', msa_incomes between 20,001 and 30,000 are labeled 'med-low', msa_incomes between 30,001 and 40,000 are labeled 'med-high', and msa_incomes between 40,001 and 60,000 are labeled 'high'.  Which of these groups has the highest average daily revenue 
WITH etc AS (
SELECT SUM(amt) as revenue, COUNT(DISTINCT saledate) AS days, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", store
FROM trnsact 
WHERE stype ='P'  
AND ("year" <> 2005 OR "month" <> 8) 
GROUP BY "month","year" ,store
HAVING COUNT(DISTINCT saledate) > 20
) 

SELECT 
(CASE WHEN msa_income > 40000 AND msa_income <= 60000 THEN 'high'
      WHEN msa_income > 30000 AND msa_income <= 40000 THEN 'medium_high'
      WHEN msa_income > 20000 AND msa_income <= 30000 THEN 'medium'
      WHEN msa_income > 0 AND msa_income <= 20000 THEN 'low'
      END) AS income_level,
SUM(revenue)/ SUM(days) AS avg_revenue_day 
FROM store_msa s, etc 
WHERE s.store = etc.store
GROUP BY income_level
-- high: $18129.42; medium_high:$21999.69; medium:$19312.10; low:$34159.76

-- Q42: Divide stores up so that stores with msa populations between 1 and 100,000 are labeled 'very small', stores with msa populations between 100,001 and 200,000 are labeled 'small', stores with msa populations between 200,001 and 500,000 are labeled 'med_small', stores with msa populations between 500,001 and 1,000,000 are labeled 'med_large', stores with msa populations between 1,000,001 and 5,000,000 are labeled “large”, and stores with msa_population greater than 5,000,000 are labeled “very large”.  What is the average daily revenue for a store in a “very large” population msa?
WITH etc AS (
SELECT SUM(amt) as revenue, COUNT(DISTINCT saledate) AS days, EXTRACT(year from saledate) AS "year", EXTRACT(month from saledate) AS "month", store
FROM trnsact 
WHERE stype ='P'  
AND ("year" <> 2005 OR "month" <> 8) 
GROUP BY "month","year" ,store
HAVING COUNT(DISTINCT saledate) > 20
) 

SELECT 
(CASE WHEN msa_pop > 1000000 AND msa_pop <= 5000000 THEN 'large'
      WHEN msa_pop > 500000 AND msa_pop <= 1000000 THEN 'med_large'
      WHEN msa_pop > 200000 AND msa_pop <= 500000 THEN 'med_small'
      WHEN msa_pop > 100000 AND msa_pop <= 200000 THEN 'small'
      WHEN msa_pop > 0 AND msa_pop <= 100000 THEN 'very small'
      ELSE 'very large'
      END) AS pop_level,
SUM(revenue)/ SUM(days) AS avg_revenue_day 
FROM store_msa s, etc 
WHERE s.store = etc.store
GROUP BY pop_level
-- very large: $25451.53; large: $22107.57; med_large: $24341.59; med_small: $21208.43; small: $16355.16; very small: §12688.25

-- Q43: Which department in which store had the greatest percent increase in average daily sales revenue from November to December, and what city and state was that store located in?   Only examine departments whose total sales were at least $1,000 in both November and December.

SELECT TOP 3 deptdesc, city, state,
COUNT(DISTINCT(CASE WHEN EXTRACT(month from saledate) = 11 THEN saledate END)) AS days_11,
COUNT(DISTINCT(CASE WHEN EXTRACT(month from saledate) = 12 THEN saledate END)) AS days_12,
SUM(CASE WHEN EXTRACT(month from saledate) = 11 THEN amt END) AS rev_11,
SUM(CASE WHEN EXTRACT(month from saledate) = 12 THEN amt END) AS rev_12,
(rev_12/days_12-rev_11/days_11)/(rev_11/days_11) * 100 AS growth_rate
FROM trnsact t JOIN strinfo str ON t.store=str.store
JOIN skuinfo sku ON t.sku=sku.sku
JOIN deptinfo dep ON dep.dept = sku.dept
WHERE stype ='P'  
GROUP BY deptdesc, city, state
HAVING COUNT(DISTINCT saledate) > 20
AND rev_11> 1000 AND rev_12 > 1000
ORDER BY growth_rate desc
-- Louisvl in Salina, KS: growth at 596%

-- Q44: Which department within a particular store had the greatest decrease in average daily sales revenue from August to September, and in what city and state was that store located?
SELECT TOP 3 deptdesc, city, state,
COUNT(DISTINCT(CASE WHEN EXTRACT(month from saledate) = 8 THEN saledate END)) AS days_8,
COUNT(DISTINCT(CASE WHEN EXTRACT(month from saledate) = 9 THEN saledate END)) AS days_9,
SUM(CASE WHEN EXTRACT(month from saledate) = 8 THEN amt END) AS rev_8,
SUM(CASE WHEN EXTRACT(month from saledate) = 9 THEN amt END) AS rev_9,
(rev_9/days_9-rev_8/days_8)/(rev_8/days_8) * 100 AS decrease_rate
FROM trnsact t JOIN strinfo str ON t.store=str.store
JOIN skuinfo sku ON t.sku=sku.sku
JOIN deptinfo dep ON dep.dept = sku.dept
WHERE stype ='P' 
AND EXTRACT(year from saledate) = 2004 
GROUP BY deptdesc, city, state
HAVING days_8 > 20 AND days_9>20
AND (rev_8 > 1000 AND rev_9 > 1000)
ORDER BY decrease_rate 
-- ??

-- Q45: Identify which department, in which city and state of what store, had the greatest DECREASE in the number of items sold from August to September.  How many fewer items did that department sell in September compared to August?
SELECT TOP 3 deptdesc,t.store, city, state,
COUNT(DISTINCT(CASE WHEN EXTRACT(month from saledate) = 8 THEN saledate END)) AS days_8,
COUNT(DISTINCT(CASE WHEN EXTRACT(month from saledate) = 9 THEN saledate END)) AS days_9,
SUM(CASE WHEN EXTRACT(month from saledate) = 8 THEN quantity END) AS qty_8,
SUM(CASE WHEN EXTRACT(month from saledate) = 9 THEN quantity END) AS qty_9,
qty_8-qty_9 AS decrease_qty
FROM trnsact t JOIN strinfo str ON t.store=str.store
JOIN skuinfo sku ON t.sku=sku.sku
JOIN deptinfo dep ON dep.dept = sku.dept
WHERE stype ='P' 
AND EXTRACT(year from saledate) = 2004 
GROUP BY deptdesc, city, state, t.store
HAVING days_8 > 20 AND days_9>20
ORDER BY decrease_qty desc
-- clinique departmetn in store 9103 in Lousiville, KY: 13491

-- Q46: For each store, determine the month with the minimum average daily revenue (as defined in Teradata Week 5 Exercise Guide) .  For each of the twelve months of the year,  count how many stores' minimum average daily revenue was in that month.  During which month(s) did over 100 stores have their minimum average daily revenue?
SELECT "month", COUNT(store)
FROM(
SELECT DISTINCT store, "month", revenue_per_day,
ROW_NUMBER() OVER(PARTITION BY store ORDER BY revenue_per_day DESC) AS revenue_min
From (
SELECT store, EXTRACT(year from saledate) AS "year",EXTRACT(month from saledate) AS "month", SUM(amt)/COUNT(DISTINCT saledate) AS revenue_per_day
FROM trnsact 
WHERE stype ='P' 
AND ("year" <> 2005 OR "month" <> 8)  
GROUP BY store, "year","month"
HAVING COUNT(DISTINCT saledate) > 20 
) AS sub
) AS sub_1
WHERE revenue_min=12
GROUP BY "month"
-- Aug.: 120, Jan.: 73; Sep: 72

-- Q47: Write a query that determines the month in which each store had its maximum number of sku units returned.  During which month did the greatest number of stores have their maximum number of sku units returned?
SELECT "month", sum(qty)
FROM(
SELECT DISTINCT store, "month", qty,
ROW_NUMBER() OVER(PARTITION BY store ORDER BY qty DESC) AS return_max
From (
SELECT store, EXTRACT(year from saledate) AS "year",EXTRACT(month from saledate) AS "month", COUNT(sku) AS qty
FROM trnsact 
WHERE stype ='R' 
AND ("year" <> 2005 OR "month" <> 8)  
GROUP BY store, "year","month"
HAVING COUNT(DISTINCT saledate) > 20 
) AS sub
) AS sub_1
WHERE return_max=1
GROUP BY "month"
-- Dec: 950092; July: 25294; Feb: 19351
