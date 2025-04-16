use first
select * from city;-- city_id,city_name,population,estimated_rent,city_rank
select * from customers;-- customer_id,customer_name,city_id,
select * from products;-- product_id,product_name,price
select * from sales;-- sale_id,sale_date,product_id,customer_id,total,rating

# 1. **Coffee Consumers Count**  
select c.city_name,c.population*0.25 from city as c 

-- 2. **Total Revenue from Coffee Sales**  
--    What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT city_name,
       Sum(total) AS 'total revenue'
FROM   sales AS s
       JOIN customers AS c
         ON s.customer_id = c.customer_id
       JOIN city AS ci
         ON ci.city_id = c.city_id
WHERE  sale_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP  BY city_name with ROLLUP


-- 3. **Sales Count for Each Product**  
--   How many units of each coffee product have been sold?

WITH temp
     AS (SELECT s.sale_id,
                p.product_name
         FROM   sales AS s
                JOIN products AS p
                  ON s.product_id = p.product_id)
SELECT product_name,
       Count(sale_id)AS 'Total count'
FROM   temp
GROUP  BY product_name 
ORDER BY product_name ASC;

-- 4. **Average Sales Amount per City**  
--    What is the average sales amount per customer in each city?

SELECT city_name,
       Sum(total) / Count(DISTINCT( s.customer_id ))AS 'Average pp'
FROM   sales AS s
       JOIN customers AS c
         ON s.customer_id = c.customer_id
       JOIN city AS ci
         ON ci.city_id = c.city_id
GROUP  BY city_name 

-- 5. **City Population and Coffee Consumers**  
--    Provide a list of cities along with their populations and estimated coffee consumers.

select count(customer_name) from customers group by city_id;

-- 6. **Top Selling Products by City**  
--    What are the top 3 selling products in each city based on sales volume?

WITH temp AS (
    SELECT 
        s.sale_id,
        s.product_id,
        p.product_name,
        ci.city_name
    FROM sales AS s
    JOIN products AS p 
        ON s.product_id = p.product_id
    JOIN customers AS c 
        ON c.customer_id = s.customer_id
    JOIN city AS ci 
        ON ci.city_id = c.city_id
),
agg AS (
    SELECT 
        city_name,
        product_name,
        COUNT(product_id) AS `Total No. Sold`
    FROM temp
    GROUP BY city_name, product_name
),
ranked AS (
    SELECT 
        city_name,
        product_name,
        `Total No. Sold`,
        ROW_NUMBER() OVER (
            PARTITION BY city_name 
            ORDER BY `Total No. Sold` DESC
        ) AS rn
    FROM agg
)
SELECT 
    city_name,
    product_name,
    `Total No. Sold`
FROM ranked
WHERE rn <= 3

-- 7. **Customer Segmentation by City**  
--    How many unique customers are there in each city who have purchased coffee products?
select city_name,count(distinct(c.customer_id)) from sales as s join customers as c on c.customer_id=s.customer_id join city as ci on ci.city_id=c.city_id group by city_name

-- 8. **Average Sale vs Rent**  
--    Find each city and their average sale per customer and avg rent per customer
-- set @wwe=(select city_name,count(distinct(customer_id))from customers as c join city as ci on ci.city_id=c.city_id group by city_name) 
SELECT city_name,
       Sum(total) / Count(DISTINCT( s.customer_id ))        AS 'average sales',
       ci.estimated_rent / Count(DISTINCT( s.customer_id )) AS 'average rent'
FROM   city AS ci
       JOIN customers AS c
         ON ci.city_id = c.city_id
       JOIN sales AS s
         ON s.customer_id = c.customer_id
GROUP  BY city_name,
          ci.estimated_rent 


-- 9. **Monthly Sales Growth**  
--    Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

-- 10. **Market Potential Analysis**  
--     Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer

SELECT city_name,
       Sum(total) / Count(DISTINCT( s.customer_id ))        AS average_sales,
       ci.estimated_rent / Count(DISTINCT( s.customer_id )) AS average_rent,
       COUNT(DISTINCT (s.customer_id)) AS total_customers,
       ci.population*0.25 as estimated_coffee_consumers from city as ci join customers as c on c.city_id=ci.city_id join sales as s on s.customer_id=c.customer_id group by city_name,  ci.estimated_rent,ci.population order by average_sales desc,average_rent desc,total_customers desc,estimated_coffee_consumers desc
        













