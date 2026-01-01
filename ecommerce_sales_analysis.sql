SELECT * FROM ecommerce_sales.ecommerce_sales_analysis;

with cte as(SELECT *,
sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + sales_month_5 + sales_month_6 +
sales_month_7 + sales_month_8 + sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12 as total_sales
FROM ecommerce_sales.ecommerce_sales_analysis)
select *, 
round(total_sales * price, 2) as total_revenue
from cte;
