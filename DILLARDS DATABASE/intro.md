# Data-analysis-of-Dillards-Sales-Data-Using-SQL

Data analysis of Dillard’s sales trend

Dillard’s, Inc. is an American department store chain with 453 stores across 30 states, consisting of over 1.56 million SKUs / unique items.

Before beginning the analysis, the most important thing is to understand the data using given database Relational Schema. Then to get a reliable recommendation from the performed analysis, I cleaned missing data and outliers.

To analyze factors, affecting sales trends, I created a structured pyramid analysis plan.

SPAP (Structured Pyramid Analysis Plan)

# Analysing Dillards sales data to study customer purchasing patterns

As part of the course - 'Managing Big Data using MySQL' offered by Duke University, I learned to translate analysis questions into SQL queries.

Analysis Question: What factors affect customer purchasing at Dillards

I created a structured Pyramid Analysis Plan to understand the computations behind the factors explored. Below mentioned are the analyses I did -

Analyze sales trends across stores and months to determine if there are specific stores, departments, or times of year that are associated with better or worse sales performance.

a. checking average daily revenue per month

b. checking average daily revenue per month across stores

c. checking average daily revenue per store per month

Whether the characteristics of the geographic location in which a store resides correlates with the sales performance of the store.

a. checking average daily revenue in areas of low, medium and high education level

b. checking average daily revenue in areas of low and high income level

Analyzing monthly (or seasonal) sales effects

a. which department of a store has greatest increase in average daily revenue from November to December

b. which department of a store has greatest decrease in average daily revenue from August to September

Due to confidentiality purposes, I won't be able to share the data. I'll post my queries along with descriptions of what I tried to do with the query.

Key takeaways:

Learning how to split large, complex problems into smaller problems and reassemling later
Checking seasonal trends using month, year-aggregations, or standard deviations
Detecting outliers and missing data
Handling outliers and missing data by setting criterias in subqueries
Difference between the syntax for MySQL, Teradata
