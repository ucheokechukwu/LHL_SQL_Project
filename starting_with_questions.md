-- Answer the following questions and provide the SQL queries used to find the answer.

    
-- **Question 1: Which cities and countries have the highest level of transaction revenues on the site?**

```-- SQL Queries:

SELECT country, city, SUM(revenue)
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId"

GROUP BY country, city
ORDER BY sum(revenue) DESC;

SELECT country, SUM(revenue)
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId"

GROUP BY country
ORDER BY sum(revenue) DESC;```





```
Answer:
-- The country is *USA 32.4K*
-- The city is *New York, USA. 11.3K*```


**Question 2: What is the average number of products ordered FROM visitors in each city and country?**

```-- SQL Queries:

SELECT country, city, AVG(units_sold)::float
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId"
WHERE units_sold !=0
GROUP BY  country, city
ORDER BY AVG(units_sold) DESC;

SELECT country, AVG(units_sold)::float
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId"
WHERE units_sold !=0
GROUP BY  country
ORDER BY AVG(units_sold) DESC;

-- Answer:
-- City - *Chicago, United States has 5* the highest average
-- Country - *Canada has 2.33*
```


**Question 3: Is there any pattern in the types (product categories) 
--of products ordered from visitors in each city and country?**
```
-- SQL Queries:
SELECT country, city, MAX ("productCategory")
FROM all_sessions
    INNER JOIN products
    ON all_sessions."productSKU" = products."productSKU"
WHERE "productCategory" !='Uncategorized'
GROUP BY  country, city
ORDER BY MAX ("productCategory");

-- SQL Queries:
SELECT country, MAX ("productCategory")
FROM all_sessions
    INNER JOIN products
    ON all_sessions."productSKU" = products."productSKU"
WHERE "productCategory" !='Uncategorized'
GROUP BY  country
ORDER BY MAX ("productCategory");

--Filtering with brand names
SELECT country, MAX ("productCategory")
FROM all_sessions
    INNER JOIN products
    ON all_sessions."productSKU" = products."productSKU"
WHERE "productCategory" !='Uncategorized' and "productCategory" LIKE '%Brand%'
GROUP BY  country
ORDER BY MAX ("productCategory");


-- Answer:
-- Accesories, Android Brand, and Apparels are the top 10 most popular results
-- Filtering with brand categories, *Google* is the most popular brand

```
**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**
```
-- SQL Queries:

with max_selling_products_by_country AS
    (SELECT country, city, MAX("productSKU") 
    FROM all_sessions
    GROUP BY  country, city)
-- joining with modified products table to get the productName
SELECT country, city, products."productName"
FROM max_selling_products_by_country
    INNER JOIN products
    ON max_selling_products_by_country.max = products."productSKU"
ORDER BY country, city;

-

with max_selling_products_by_country AS
    (SELECT country, MAX("productSKU") 
    FROM all_sessions
    GROUP BY  country)
-- joining with modified products table to get the productName
SELECT country, products."productName"
FROM max_selling_products_by_country
    INNER JOIN products
    ON max_selling_products_by_country.max = products."productSKU"
ORDER BY country;

-- Answer: Out of the top 10 results, 6 items were *stationary/office*. 
-- Out of the top 20 results, 14 items were *stationary/office*. 
```

**Question 5: Can we summarize the impact of revenue generated FROM each city/country?**
```
-- SQL Queries:
--per city
SELECT SUM(revenue)
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId";
-- Query for Total sum

SELECT country, city, (sum(revenue)*100 / 
                        (SELECT sum(revenue)
                        FROM analytics
                            INNER JOIN visitorLocation
                            ON analytics."visitId" = visitorLocation."visitId"))::numeric(100,2) as percent_of_revenue
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId"

GROUP BY country, city
ORDER BY sum(revenue) DESC;
 
-- New York (33%) and SunnyVale(20%) and Mountain View (14%)
-- are all US cities with the highest results
-- but see csv data for more details  


--per country
SELECT SUM(revenue)
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId";
-- Query for Total sum

SELECT country, (sum(revenue)*100 / 
                        (SELECT sum(revenue)
                        FROM analytics
                            INNER JOIN visitorLocation
                            ON analytics."visitId" = visitorLocation."visitId"))::numeric(100,2) as percent_of_revenue
FROM analytics
    INNER JOIN visitorLocation
    ON analytics."visitId" = visitorLocation."visitId"

GROUP BY country
ORDER BY sum(revenue) DESC;

-- Answer:

-- United States has the highest result at 96.26%
-- it is possible that the scores are also due to the avalaible data. 
```

