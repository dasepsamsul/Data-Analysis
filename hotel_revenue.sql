SELECT * FROM hotel_revenue.hotel_revenue;
SELECT DISTINCT * FROM hotel_revenue.hotel_revenue;
SELECT DISTINCT hotel FROM hotel_revenue.hotel_revenue;

-- create table
CREATE TABLE `hotel_revenue` (
  `hotel` text,
  `is_canceled` int DEFAULT NULL,
  `lead_time` int DEFAULT NULL,
  `arrival_date_year` int DEFAULT NULL,
  `arrival_date_month` text,
  `arrival_date_week_number` int DEFAULT NULL,
  `arrival_date_day_of_month` int DEFAULT NULL,
  `stays_in_weekend_nights` int DEFAULT NULL,
  `stays_in_week_nights` int DEFAULT NULL,
  `adults` int DEFAULT NULL,
  `children` int DEFAULT NULL,
  `babies` int DEFAULT NULL,
  `meal` text,
  `country` text,
  `market_segment` text,
  `distribution_channel` text,
  `is_repeated_guest` int DEFAULT NULL,
  `previous_cancellations` int DEFAULT NULL,
  `previous_bookings_not_canceled` int DEFAULT NULL,
  `reserved_room_type` text,
  `assigned_room_type` text,
  `booking_changes` int DEFAULT NULL,
  `deposit_type` text,
  `agent` text,
  `company` text,
  `days_in_waiting_list` int DEFAULT NULL,
  `customer_type` text,
  `adr` double DEFAULT NULL,
  `required_car_parking_spaces` int DEFAULT NULL,
  `total_of_special_requests` int DEFAULT NULL,
  `reservation_status` text,
  `reservation_status_date` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- import using data infile
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hotel_revenue_historical_2018.csv'
INTO TABLE hotel_revenue.hotel_revenue
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Error Code: 1366. Incorrect integer value: 'NA' for column 'children' at row 2321
-- Cleaned on Excel by replace

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hotel_revenue_historical_2019.csv'
INTO TABLE hotel_revenue.hotel_revenue
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hotel_revenue_historical_2020.csv'
INTO TABLE hotel_revenue.hotel_revenue
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- join table meal_cost and market_segment
SELECT * FROM hotel_revenue hr
LEFT JOIN meal_cost mc
	ON hr.meal = mc.meal
LEFT JOIN market_segment ms
	ON hr.market_segment = ms.market_segment
LIMIT 100;

-- standardize the date
SELECT reservation_status_date,
str_to_date(reservation_status_date, '%m/%d/%Y') AS reservation_status_date_std
FROM hotel_revenue;

-- checking duplicates, but the data can not be validated since it has no order_id
with cte_duplicates as(
select *,
row_number() 
over(partition by hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month, arrival_date_week_number, arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights, adults, children, babies, meal, country, market_segment, distribution_channel, is_repeated_guest, previous_cancellations, previous_bookings_not_canceled, reserved_room_type, assigned_room_type, booking_changes, deposit_type, agent, company, days_in_waiting_list, customer_type, adr, required_car_parking_spaces, total_of_special_requests, reservation_status, reservation_status_date) as row_num
from hotel_revenue
)
select *
from cte_duplicates
where row_num = 1;



WITH cte_hotel_revenue AS (
    SELECT 
        hr.*,
        mc.cost AS meal_cost,
        ms.Discount AS discount_market_segment,
        STR_TO_DATE(hr.reservation_status_date, '%m/%d/%Y') 
            AS reservation_status_date_std
    FROM hotel_revenue hr
    LEFT JOIN meal_cost mc
        ON hr.meal = mc.meal
    LEFT JOIN market_segment ms
        ON hr.market_segment = ms.market_segment
),
cte_duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   hotel, is_canceled, lead_time,
                   arrival_date_year, arrival_date_month,
                   arrival_date_week_number, arrival_date_day_of_month,
                   stays_in_weekend_nights, stays_in_week_nights,
                   adults, children, babies, meal, country,
                   market_segment, distribution_channel,
                   is_repeated_guest, previous_cancellations,
                   previous_bookings_not_canceled,
                   reserved_room_type, assigned_room_type,
                   booking_changes, deposit_type, agent,
                   company, days_in_waiting_list,
                   customer_type, adr,
                   required_car_parking_spaces,
                   total_of_special_requests,
                   reservation_status,
                   reservation_status_date_std
           ) AS row_num
    FROM cte_hotel_revenue
)
SELECT *
FROM cte_duplicates
WHERE row_num = 1 AND reservation_status_date_std >= '2018-01-01'
ORDER BY reservation_status_date_std;

	

