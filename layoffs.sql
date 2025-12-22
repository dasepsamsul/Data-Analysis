-- Data Cleaning

select * from layoffs;

-- create staging table
create table layoffs_staging
like layoffs;

insert layoffs_staging
select *
from layoffs;

-- checking duplicates
with cte_duplicates as(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from cte_duplicates
where row_num > 1;

-- membuat table staging (bukan tabel utama)
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2
where row_num > 1;

-- mengimport data ke tabel staging
insert layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- menghapus data (row) duplikat
delete 
from layoffs_staging2
where row_num > 1;

-- standardizing data
select distinct trim(company)
from layoffs_staging2;

select trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select * from layoffs_staging2;

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

select distinct industry
from layoffs_staging2;

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select *
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where company = 'airbnb';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.companypizza_sales
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

-- remove rows 
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- remove column row_num
select * from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;