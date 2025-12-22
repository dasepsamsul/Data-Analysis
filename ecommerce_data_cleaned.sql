create table ecommerce_data (
No int not null,
InvoiceNo text,
StockCode text,
Description text,
Quantity int not null,
UnitPrice float not null,
CustomerID int not null,
Country text,
Date date,
Hour int);

-- menyesuaikan path folder mengatasi error --secure-file-priv option
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce_Data-1.csv'
into table ecommerce_data.ecommerce_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

-- mencari path folder yang sesuai dengan kriteria
show variables like 'secure_file_priv';

select * from ecommerce_data;

with ecommerce as(
select *,
round(Quantity * UnitPrice,2) as Sum
from ecommerce_data
order by No)
select *
from ecommerce;

-- check any duplicates
with cte_duplicates as(
select *,
row_number() over(
partition by No, InvoiceNo, StockCode, CustomerID) as row_num
from ecommerce_data
)
select *
from cte_duplicates
where row_num > 1;

with cte_ReturnRate as(
select 
(select 
count(InvoiceNo) 
from ecommerce_data
where InvoiceNo like 'C%')/ 
count(InvoiceNo)*100 as ReturnRate
from ecommerce_data)
select * from cte_ReturnRate;

select * from ecommerce_data;
