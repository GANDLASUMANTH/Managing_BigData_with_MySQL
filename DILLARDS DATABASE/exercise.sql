## These are the hardest and most complicated queries I built for the last quiz. 
## (The last Quiz had 15 questions. These are two of the last. The prior questions were preparing you for the last ones)

## Question 1
## Write a query that determines the month in which each store had its maximum number of sku units returned. During
## which month did the greatest number of stores have their maximum number of sku units returned?

SELECT	CASE	when max_month_table.month_num = 1 then 'January' 
		when max_month_table.month_num = 2 then 'February' 
		when max_month_table.month_num = 3 then 'March' 
		when max_month_table.month_num = 4 then 'April' 
		when max_month_table.month_num = 5 then 'May' 
		when max_month_table.month_num = 6 then 'June' 
		when max_month_table.month_num = 7 then 'July' 
		when max_month_table.month_num = 8 then 'August' 
		when max_month_table.month_num = 9 then 'September' 
		when max_month_table.month_num = 10 then 'October' 
		when max_month_table.month_num = 11 then 'November' 
		when max_month_table.month_num = 12 then 'December' 
	END,
	COUNT(*)

FROM 	(
	SELECT DISTINCT 
	extract(year from saledate) as year_num,
	extract(month from saledate) as month_num,
	CASE when extract(year from saledate) = 2004 AND extract(month from saledate) = 8 then 'exclude' END as exclude_flag,
	store,
	SUM(quantity) AS tot_returns,
	ROW_NUMBER () over (PARTITION BY store ORDER BY tot_returns DESC) AS month_rank
	
	FROM trnsact
	
	WHERE stype='R' AND exclude_flag IS NULL AND store||EXTRACT(YEAR from saledate)||EXTRACT(MONTH from saledate)
		IN 	(
			SELECT store||EXTRACT(YEAR from saledate)||EXTRACT(MONTH from saledate)
			FROM trnsact
			GROUP BY store, EXTRACT(YEAR from saledate), EXTRACT(MONTH from saledate)	
			HAVING COUNT(DISTINCT saledate)>= 20
			)
	GROUP BY store, month_num, year_num QUALIFY month_rank=1
	) as max_month_table
	
GROUP BY max_month_table.month_num

ORDER BY max_month_table.month_num
## End of question 1



## Question 2
## Which department within a particular store had the greatest decrease in average daily sales revenue from August to
## September, and in what city and state was that store located?

SELECT 	s.city, s.state, d.deptdesc, t.store,
	CASE when extract(year from t.saledate) = 2005 AND extract(month from t.saledate) = 8 then 'exclude'END as exclude_flag,
	SUM(case WHEN EXTRACT(MONTH from saledate) =’8’ THEN amt END) as August,
	SUM(case WHEN EXTRACT(MONTH from saledate) =’9’ THEN amt END) as September,
	COUNT(DISTINCT (case WHEN EXTRACT(MONTH from saledate) ='8' then saledate END)) as Aug_numdays,
	COUNT(DISTINCT (case WHEN EXTRACT(MONTH from saledate) ='9' then saledate END)) as Sept_numdays,
	(August/Aug_numdays)-(September/Sept_numdays) AS dip

FROM	trnsact t JOIN strinfo s ON t.store=s.store 
	JOIN skuinfo si ON t.sku=si.sku 
	JOIN deptinfo d ON si.dept=d.dept

WHERE 	t.stype='P' AND exclude_㐌ag IS NULL 
	AND t.store||EXTRACT(YEAR from t.saledate)||EXTRACT(MONTH from t.saledate)
		IN	(
			SELECT store||EXTRACT(YEAR from saledate)||EXTRACT(MONTH from saledate)
			FROM trnsact
			GROUP BY store, EXTRACT(YEAR from saledate), EXTRACT(MONTH from saledate)
			HAVING COUNT(DISTINCT saledate)>= 20
			)

GROUP BY s.city, s.state, d.deptdesc, t.store, exclude_㐌ag

ORDER BY dip DESC;
## End of question 2



## This is the last query I built for the semi-final quiz.
SELECT	CASE	when msa_high between 50 and 60 then 'low'
		when msa_high between 60 and 70 then 'medium'
  		when msa_high > 70 then 'high'
	END AS HSE,
	SUM(CASE WHEN HSE='low' THEN Revenue/NS END) as lowEd,
	SUM(CASE WHEN HSE='medium' THEN Revenue/NS END) as mediumEd,
	SUM(CASE WHEN HSE='high' THEN Revenue/NS END) as highEd

FROM 	store_msa m join 
		(
		SELECT COUNT(DISTINCT saledate) as NS,
 		(EXTRACT(YEAR from saledate)||EXTRACT(MONTH from saledate)) as yearmonth,
		store,
		SUM(amt) as Revenue,
 		CASE	WHEN (EXTRACT(MONTH from saledate)=8 and EXTRACT(YEAR from saledate)=2005) or (stype<>'P') THEN 'Yes' 
		  	ELSE 'No'
		   END AS Exclude
		FROM trnsact t 
		WHERE Exclude='No'
		GROUP BY store, yearmonth, Exclude
       		HAVING NS>=20
		) AS SalesStoreDateCorr 
 	on  m.store = SalesStoreDateCorr.store

GROUP BY HSE
