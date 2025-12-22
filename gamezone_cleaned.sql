SELECT * FROM gamezone.`gamezone-orders-data`;

-- create staging table
create table gamezone_orders_staging
like `gamezone-orders-data`;

insert gamezone_orders_staging
select *
from `gamezone-orders-data`;

with cte_duplicates as(
select *,
row_number() 
over(partition by USER_ID, ORDER_ID, PRODUCT_ID) as row_num
from gamezone_orders_staging
)
select *
from cte_duplicates
where row_num > 1;

with cte_duplicates as(
select *,
row_number() 
over(partition by USER_ID, ORDER_ID, PRODUCT_ID) as row_num
from gamezone_orders_staging
)
select
USER_ID,
ORDER_ID,
PURCHASE_TS,
SHIP_TS,
PRODUCT_NAME,
PRODUCT_ID,
USD_PRICE,
PURCHASE_PLATFORM,
MARKETING_CHANNEL,
ACCOUNT_CREATION_METHOD,
gr.COUNTRY_CODE,
gr.REGION
from cte_duplicates cte
left join `gamezone-region-data` gr
on cte.COUNTRY_CODE = gr.COUNTRY_CODE
where row_num = 1;

update gamezone_orders_staging
set PRODUCT_NAME = '27in 4K gaming monitor'
where PRODUCT_NAME = '27inches 4k gaming monitor';

update gamezone_orders_staging
set MARKETING_CHANNEL = 'unknown'
where MARKETING_CHANNEL = '';

update gamezone_orders_staging
set ACCOUNT_CREATION_METHOD = 'unknown'
where ACCOUNT_CREATION_METHOD = '';

select *
from gamezone_orders_staging
where PRODUCT_NAME = '27inches 4k gaming monitor';

select distinct REGION from `gamezone-region-data`;
select * from `gamezone-region-data`;

select *
from `gamezone-region-data`
where REGION = '' 
or REGION is null
or REGION = 'X.x';

update `gamezone-region-data`
set REGION = 'unknown'
where REGION = '' 
or REGION is null
or REGION = 'X.x';

select *
from `gamezone-region-data`
where COUNTRY_CODE = 'IE' 
or COUNTRY_CODE= 'LB';


SELECT * FROM gamezone.gamezone_orders_staging;
SELECT * 
FROM gamezone.gamezone_orders_staging
WHERE ACCOUNT_CREATION_METHOD = '';