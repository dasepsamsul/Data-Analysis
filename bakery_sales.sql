CREATE TABLE bakery_sales (
  `MyUnknownColumn` int DEFAULT NULL,
  `date` date,
  `time` time DEFAULT NULL,
  `ticket_number` text DEFAULT NULL,
  `article` text,
  `Quantity` double DEFAULT NULL,
  `unit_price` varchar(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bakery_sales.csv'
INTO TABLE bakery_sales.bakery_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


SELECT 
    *
FROM
    bakery_sales;

ALTER TABLE bakery_sales
RENAME COLUMN MyUnknownColumn TO `no`;


WITH cte_duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                `no`,
                `date`,
                `time`,
                ticket_number,
                article,
                quantity,
                unit_price
        ) AS row_num
    FROM bakery_sales
)
SELECT *
FROM cte_duplicates
WHERE row_num > 1;


CREATE TABLE bakery_sales_staging LIKE bakery_sales;

INSERT INTO bakery_sales_staging
SELECT *
FROM bakery_sales;


SELECT DISTINCT
    no
FROM
    bakery_sales_staging
ORDER BY 1;

SELECT
    unit_price,
    REPLACE(TRIM(REPLACE(unit_price, '€', '')), ',', '.') AS cleaned_price
FROM bakery_sales_staging;

UPDATE bakery_sales_staging
SET unit_price = CAST(
    REPLACE(TRIM(REPLACE(unit_price, '€', '')), ',', '.') AS DECIMAL(10,2)
);

SELECT 
    date,
    round(SUM(Quantity * unit_price), 2) AS total_revenue
FROM bakery_sales_staging
GROUP BY date
ORDER BY date;

SELECT 
    article,
    SUM(Quantity) AS total_qty,
    round(SUM(Quantity * unit_price), 2) AS revenue
FROM bakery_sales_staging
GROUP BY article
ORDER BY revenue DESC;


SELECT
    article,
    SUM(quantity) AS sales_per_product
FROM bakery_sales_staging
GROUP BY article
ORDER BY sales_per_product DESC;

SELECT
    article,
    ROUND(SUM(quantity * unit_price), 2) AS revenue_per_product
FROM bakery_sales_staging
GROUP BY article
ORDER BY revenue_per_product DESC;

SELECT DISTINCT
    article, unit_price
FROM
    bakery_sales_staging
ORDER BY 2 DESC;

-- query yang salah
/*with product_bracket as (
select distinct article, sum(Quantity)over(partition by article) as sales_per_product 
from bakery_sales_staging
order by 2 desc,
select distinct article, round(sum(Quantity * unit_price)over(partition by article),2) as revenue_per_product 
from bakery_sales_staging
order by 2 desc,
Select distinct article, unit_price from bakery_sales_staging
order by 2 desc
)
select sales_per_product spp join revenue_per_product rpp
on spp.article = rpp.article
from product_bracket;*/

SELECT DISTINCT
	article,
	SUM(quantity) OVER (PARTITION BY article) AS sales_per_product,
	ROUND(SUM(quantity * unit_price) OVER (PARTITION BY article), 2) AS revenue_per_product,
	unit_price
FROM bakery_sales_staging
ORDER BY 2 DESC;
    
WITH product_bracket AS (
    SELECT DISTINCT
        article,
        SUM(quantity) OVER (PARTITION BY article) AS sales_per_product,
        ROUND(SUM(quantity * unit_price) OVER (PARTITION BY article), 2) AS revenue_per_product,
        unit_price
    FROM bakery_sales_staging
)
SELECT *
FROM product_bracket
ORDER BY sales_per_product DESC;

SELECT 
    ROUND(SUM(Quantity * unit_price), 2) AS total_revenue
FROM
    bakery_sales_staging;

SELECT 
    COUNT(ticket_number) AS total_order
FROM
    bakery_sales_staging;

SELECT 
    SUM(Quantity * unit_price) / COUNT(DISTINCT ticket_number) AS average_order_value
FROM
    bakery_sales_staging;

SELECT 
    DATE_FORMAT(date, '%Y-%m') AS month,
    ROUND(SUM(Quantity * unit_price), 2) AS total_revenue,
    COUNT(DISTINCT ticket_number) AS total_order,
    ROUND(SUM(Quantity * unit_price) / COUNT(DISTINCT ticket_number),
            2) AS aov
FROM
    bakery_sales_staging
GROUP BY month
ORDER BY month;

SELECT
    month,
    total_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY month))
        / LAG(total_revenue) OVER (ORDER BY month) * 100,
        2
    ) AS growth_mom_pct
FROM (
    SELECT 
        DATE_FORMAT(date, '%Y-%m') AS month,
        ROUND(SUM(Quantity * unit_price),2) AS total_revenue
    FROM bakery_sales_staging
    GROUP BY month
) revenue_per_month
ORDER BY month;

SELECT
    month,
    total_order,
    ROUND(
        (total_order - LAG(total_order) OVER (ORDER BY month))
        / LAG(total_order) OVER (ORDER BY month) * 100,
        2
    ) AS growth_mom_pct
FROM (
    SELECT 
        DATE_FORMAT(date, '%Y-%m') AS month,
        count(distinct ticket_number) as total_order
    FROM bakery_sales_staging
    GROUP BY month
) order_per_month
ORDER BY month;

SELECT
    HOUR(time) AS hour,
    SUM(quantity) AS total_qty
FROM bakery_sales_staging
GROUP BY hour
ORDER BY hour ASC;

SELECT
    HOUR(time) AS hour,
    COUNT(ticket_number) AS total_order
FROM bakery_sales_staging
GROUP BY hour
ORDER BY hour ASC;

SELECT * FROM bakery_sales_staging;
