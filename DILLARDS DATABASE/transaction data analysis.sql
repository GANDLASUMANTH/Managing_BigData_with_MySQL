2.Question 2
How many distinct skus have the brand “Polo fas”, and are either size “XXL” or “black” in color?

SELECT DISTINCT(sku), brand, size, color
FROM ua_dillards.skuinfo
WHERE ( (brand LIKE '%polo%fas%') AND (color = 'black') ) OR ( (brand LIKE '%polo%fas%') AND (size LIKE '%XXL%') )
ORDER BY size asc;

3.Question 3
There was one store in the database which had only 11 days in one of its months (in other words, that store/month/year combination only contained 11 days of transaction data). In what city and state was this store located?

SELECT COUNT(DISTINCT saledate), trnsact.store, EXTRACT(month FROM saledate) AS "trns_month", EXTRACT(year FROM saledate) AS "trns_year", strinfo.state, strinfo.city
FROM ua_dillards.trnsact
LEFT JOIN ua_dillards.strinfo ON trnsact.store = strinfo.store
GROUP BY trnsact.store, EXTRACT(month FROM saledate), EXTRACT(year FROM saledate), strinfo.state, strinfo.city 
ORDER BY COUNT(DISTINCT saledate), trns_year, trns_month, trnsact.store, strinfo.state, strinfo.city asc;

4.Question 4
Which sku number had the greatest increase in total sales revenue from November to December?

SELECT trnsact.sku, EXTRACT(year FROM saledate), EXTRACT(month FROM saledate), amt
FROM ua_dillards.trnsact
GROUP BY trnsact.sku, EXTRACT(year FROM saledate), EXTRACT(month FROM saledate)
WHERE (stype = 'S' AND (EXTRACT(month FROM saledate)  = 11) ) OR (stype = 'S' AND ( EXTRACT(month FROM saledate) = 12) )
ORDER BY trnsact.sku, EXTRACT(year FROM saledate), EXTRACT(month FROM saledate)


check that value from extract is numeric and not character, else wrap value in quotes

Select sku, year, year_nov_amt_sum, year_dec_amt_sum, percnt_incr
From
join these tables

sku, year, year_nov_amt_sum

sku, year,  year_dec_amt_sum

Select following values from joined table

sku, year, year_nov_amt_sum, year_dec_amt_sum, percnt_incr

SELECT trnsact.sku, EXTRACT(year FROM trnsact.saledate) AS year, nov_subq.nov_amt_sum AS nov_amt_sum, dec_subq.dec_amt_sum AS dec_amt_sum, (dec_subq.dec_amt_sum / nov_subq.nov_amt_sum) AS percnt_incr

FROM ua_dillards.trnsact

LEFT JOIN 
	(SELECT trnsact.sku AS sku, EXTRACT(day FROM trnsact.saledate) AS subq_day, EXTRACT(month FROM trnsact.saledate) AS subq_month, EXTRACT(year FROM trnsact.saledate) AS subq_year, SUM(trnsact.amt) AS nov_amt_sum
	FROM ua_dillards.trnsact
	WHERE EXTRACT(year FROM trnsact.saledate) = 11 AND stype = 'P'
	GROUP BY trnsact.sku
	) AS nov_subq

	ON trnsact.sku = nov_subq.sku

LEFT JOIN 
	(SELECT trnsact.sku AS sku, EXTRACT(year FROM trnsact.saledate) AS year, SUM(trnsact.amt) AS dec_amt_sum
	FROM ua_dillards.trnsact
	WHERE EXTRACT(year FROM trnsact.saledate) = 12 AND stype = 'P'
	GROUP BY trnsact.sku, EXTRACT(year FROM trnsact.saledate)
	) AS dec_subq

	ON trnsact.sku = dec_subq.sku AND EXTRACT(year FROM trnsact.saledate) = dec_subq.year

WHERE stype = 'S' AND 

GROUP BY trnsact.sku

ORDER BY percnt_incr;


SELECT subq1.sku, 
	SUM( CASE WHEN subq_month = 11 THEN amt ELSE 0 END) AS nov_amt_sum, 
	SUM( CASE WHEN subq_month = 12 THEN amt ELSE 0 END ) AS dec_amt_sum, 
	SUM( CASE WHEN subq_month = 12 THEN amt ELSE 0 END ) - SUM( CASE WHEN subq_month = 11 THEN amt ELSE 0 END) AS month_diff

FROM 
	(SELECT trnsact.sku, EXTRACT(day FROM trnsact.saledate) AS subq_day, EXTRACT(month FROM trnsact.saledate) AS subq_month, EXTRACT(year FROM trnsact.saledate) AS subq_year, amt 
	FROM ua_dillards.trnsact 
	WHERE (subq_month = 11 OR subq_month = 12 ) AND stype = 'P'
	) AS subq1

GROUP BY subq1.sku
ORDER BY month_diff desc;

5.Question 5
What vendor has the greatest number of distinct skus in the transaction table that do not exist in the skstinfo table? (Remember that vendors are listed as distinct numbers in our data set).

SELECT skuinfo.vendor, COUNT(DISTINCT subq1.sku)
FROM 
	(SELECT DISTINCT trnsact.sku 
	FROM trnsact 
	LEFT JOIN skstinfo
		ON trnsact.sku = skstinfo.sku 
	WHERE skstinfo.sku IS NULL
	) AS subq1, 
	ua_dillards.skuinfo

WHERE subq1.sku = skuinfo.sku
GROUP BY skuinfo.vendor
ORDER BY COUNT(DISTINCT subq1.sku) desc;


6.Question 6
What is the brand of the sku with the greatest standard deviation in sprice? Only examine skus which have been part of over 100 transactions.

SELECT skuinfo.brand, subq1.sku, subq1.std_dev, subq1.trans
FROM (SELECT sku,  STDDEV_POP(sprice) AS std_dev, COUNT(sprice) AS trans
	FROM trnsact
	WHERE stype='P'
	GROUP BY sku 
	HAVING trans > 100) AS subq1 
LEFT JOIN skuinfo
ON subq1.sku = skuinfo.sku
ORDER BY subq1.std_dev DESC


7.Question 7
What is the city and state of the store which had the greatest increase in average daily revenue (as defined in Teradata Week 5 Exercise Guide) from November to December?

SELECT subq1.store,
 subq1.city,
 subq1.state,
 SUM(CASE WHEN trans_month = 11 THEN amt ELSE 0 END) / COUNT(DISTINCT CASE WHEN trans_month = 11 THEN subq1.store_saledate END) AS nov_avg,
 COUNT(DISTINCT CASE WHEN trans_month = 11 THEN subq1.store_saledate ELSE NULL END) AS nov_distinct_days,
 SUM(CASE WHEN trans_month = 12 THEN amt ELSE 0 END) / COUNT(DISTINCT CASE WHEN trans_month = 12 THEN subq1.store_saledate END) AS dec_avg,
 COUNT(DISTINCT CASE WHEN trans_month = 12 THEN subq1.store_saledate ELSE NULL END) AS dec_distinct_days,
 ( SUM(CASE WHEN trans_month = 12 THEN subq1.amt ELSE 0 END) / COUNT(DISTINCT CASE WHEN trans_month = 12 THEN subq1.store_saledate END) - SUM(CASE WHEN trans_month=11 THEN subq1.amt ELSE 0 END) / COUNT(DISTINCT CASE WHEN trans_month = 11 THEN subq1.store_saledate END) ) / ( SUM(CASE WHEN trans_month=11 THEN subq1.amt ELSE 0 END) / COUNT(DISTINCT CASE WHEN trans_month = 11 THEN subq1.store_saledate END) )*100 AS percent_change

FROM (SELECT trnsact.store, strinfo.city, strinfo.state, (trnsact.store || 'x' || trnsact.saledate) AS store_saledate, EXTRACT(YEAR FROM trnsact.saledate) AS trans_year, EXTRACT(MONTH FROM trnsact.saledate) AS trans_month, EXTRACT(DAY FROM trnsact.saledate) AS trans_day, amt
	FROM ua_dillards.trnsact
	LEFT JOIN ua_dillards.strinfo
	ON trnsact.store=strinfo.store
	WHERE (trans_month = 11 OR trans_month = 12) AND stype = 'P' 
	) AS subq1

GROUP BY subq1.store, subq1.city, subq1.state

ORDER BY percent_change desc;



8.Question 8
Compare the average daily revenue (as defined in Teradata Week 5 Exercise Guide) of the store with the highest msa_income and the store with the lowest median msa_income (according to the msa_income field). In what city and state were these two stores, and which store had a higher average daily revenue?

percent_change 100*(a2 - a1) / a1 

SELECT TOP 1 store, city, state, MAX(msa_income)
FROM store_msa
GROUP BY store, city, state
ORDER BY MAX(msa_income) desc;

SELECT TOP 1 store, city, state, MIN(msa_income)
FROM store_msa
GROUP BY store, city, state
ORDER BY MIN(msa_income) asc;



9.Question 9
Divide the msa_income groups up so that msa_incomes between 1 and 20,000 are labeled 'low', msa_incomes between 20,001 and 30,000 are labeled 'med-low', msa_incomes between 30,001 and 40,000 are labeled 'med-high', and msa_incomes between 40,001 and 60,000 are labeled 'high'. Which of these groups has the highest average daily revenue (as defined in Teradata Week 5 Exercise Guide) per store?


10.Question 10
Divide stores up so that stores with msa populations between 1 and 100,000 are labeled 'very small', stores with msa populations between 100,001 and 200,000 are labeled 'small', stores with msa populations between 200,001 and 500,000 are labeled 'med_small', stores with msa populations between 500,001 and 1,000,000 are labeled 'med_large', stores with msa populations between 1,000,001 and 5,000,000 are labeled “large”, and stores with msa_population greater than 5,000,000 are labeled “very large”. What is the average daily revenue (as defined in Teradata Week 5 Exercise Guide) for a store in a “very large” population msa?


11.Question 11
Which department in which store had the greatest percent increase in average daily sales revenue from November to December, and what city and state was that store located in? Only examine departments whose total sales were at least $1,000 in both November and December.


12.Question 12
Which department within a particular store had the greatest decrease in average daily sales revenue from August to September, and in what city and state was that store located?


13.Question 13
Identify which department, in which city and state of what store, had the greatest DECREASE in the number of items sold from August to September. How many fewer items did that department sell in September compared to August?


14.Question 14
For each store, determine the month with the minimum average daily revenue (as defined in Teradata Week 5 Exercise Guide) . For each of the twelve months of the year, count how many stores' minimum average daily revenue was in that month. During which month(s) did over 100 stores have their minimum average daily revenue?


15.Question 15
Write a query that determines the month in which each store had its maximum number of sku units returned. During which month did the greatest number of stores have their maximum number of sku units returned?
