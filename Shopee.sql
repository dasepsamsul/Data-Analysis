


CREATE TABLE `all_months_clean` (
  `ï»¿order_id` text,
  `total_qty` int DEFAULT NULL,
  `total_weight_gr` int DEFAULT NULL,
  `total_returned_qty` int DEFAULT NULL,
  `Total Diskon` int DEFAULT NULL,
  `product_categories` text,
  `num_product_categories` int DEFAULT NULL,
  `Status Pesanan` text,
  `Alasan Pembatalan` text,
  `Opsi Pengiriman` text,
  `Metode Pembayaran` text,
  `Kota/Kabupaten` text,
  `Provinsi` text,
  `Ongkos Kirim Dibayar oleh Pembeli` int DEFAULT NULL,
  `Estimasi Potongan Biaya Pengiriman` int DEFAULT NULL,
  `Total Pembayaran` text,
  `Perkiraan Ongkos Kirim` int DEFAULT NULL,
  `Waktu Pesanan Dibuat` text,
  `source_file` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/all_months_clean.csv'
into table `all_months_clean`
fields terminated by ';'
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

SELECT * FROM all_months_clean;
SELECT DISTINCT product_categories FROM all_months_clean;

ALTER TABLE all_months_clean
RENAME COLUMN ï»¿order_id TO order_id;

with cte_duplicates as(
select *,
row_number() 
over(partition by order_id) as row_num
from all_months_clean
)
select *
from cte_duplicates
where row_num > 1;

with cte as(
select 
`order_id`,
`total_qty`,
`total_weight_gr`,
`total_returned_qty`,
`Total Diskon`,
`product_categories`,
`num_product_categories`,
`Status Pesanan`,
`Alasan Pembatalan`,
`Opsi Pengiriman`,
`Metode Pembayaran`,
`Kota/Kabupaten`,
`Provinsi`,
`Ongkos Kirim Dibayar oleh Pembeli`,
`estimasi Potongan Biaya Pengiriman`,
`Total Pembayaran`,
`Perkiraan Ongkos Kirim`,
`Waktu Pesanan Dibuat`
from 
all_months_clean)
select *
from cte;

with CTE_Cancel_Rate as(
select 
(select 
count(`Status Pesanan`) 
from all_months_clean
where `Status Pesanan`='Batal')/ 
count(`Status Pesanan`)*100 as Cancel_Rate
from all_months_clean)
select round(Cancel_Rate,2) from CTE_Cancel_Rate;
