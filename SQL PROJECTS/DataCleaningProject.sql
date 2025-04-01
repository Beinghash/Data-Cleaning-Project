-- Data Cleaning

select *
from layoffs;

-- Steps to be followed for the Data cleaning process
-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Check for Null or Blank Values
-- 4. Remove any coloumns or rows

create table layoffs_staging                                                        -- We are making a copy of an original data set by creating a table
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging                                                              -- Inserting all the values in the new table 
select *
from layoffs;

-- Removing duplicates 

with duplicate_cte as (                                                  -- you may want to create a CTE to select the coloumns where row_num > 1
select *, 
row_number() over
(partition by company,location,industry,total_laid_off,percentage_laid_off, `date`,stage, country,funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;
;

-- Now as we observe the problem we can create a table with the coloumn and delete the rows which are greater than 1 essentially and then finally delete the coloumn


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


select *
from layoffs_staging2
where row_num > 1;

insert into layoffs_staging2                                     -- Inserting the values in the new table
select *, 
row_number() over
(partition by company,location,industry,total_laid_off,percentage_laid_off, `date`,stage, country,funds_raised_millions) as row_num
from layoffs_staging;

 
delete 
from layoffs_staging2                                     -- The duplicate rows are deleted 
where row_num > 1;

select *                                                  -- There are no duplicates now  
from layoffs_staging2
where row_num > 1;

-- Standardizing data 

select company, trim(company)                            -- Performing standardization in the 'company' column. 
from layoffs_staging2;                                  -- Triming any wide spaces from the coloumns 

update layoffs_staging2                                 -- updating the table instantly 
set company = trim(company);

select distinct industry                               -- Checking for any standardization in the 'industry' column. 
from layoffs_staging2
order by 1 ;

select * 
from layoffs_staging2
where industry like 'crypto%' ;

update layoffs_staging2
set industry = 'crypto'                                -- updating the industry name to 'crypto' to any industry name with 'crypto%' (watever comes after it)
where industry like 'crypto%'
;

select distinct industry                               -- Now the 'industry' column is standardized
from layoffs_staging2
;

select distinct location                              -- Checking for any standardization in the location column. 
from layoffs_staging2
where location = 'DÃ¼sseldorf'
;

update layoffs_staging2                               -- Here we can observe some spelling mistakes in the 'location' column, so we are trying to update the correct spellings 
set location = 'Düsseldorf'
where location = 'DÃ¼sseldorf'
;

update layoffs_staging2
set location = 'Florianópolis'
where location = 'FlorianÃ³polis'
;


select distinct country                           -- Checking for any standardization in the 'country' column. 
from layoffs_staging2
order by 1
;

select distinct country, trim(trailing '.' from country)                          
from layoffs_staging2
order by 1
;

update layoffs_staging2                                                              -- trimming the unusual 'period' after the country name (i.e United States.)
set country = trim(trailing '.' from country)
where country like 'United States%'
;

select `date`                                                                 -- Checking for any standardization in the 'date' column. 
from layoffs_staging2
;

select `date` ,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2                                                      -- Updating the new date format, we can use 'str to date' to update this field
set `date` = str_to_date(`date`, '%m/%d/%Y')
;

alter table layoffs_staging2                                              -- We can convert the data type properly by this query                    
modify column `date` date;


select *
from layoffs_staging2                         
where industry is null or industry = '' 
;

update layoffs_staging2                                               -- Updating the blank values into Null
set industry = null
where industry = '' ;

select *                                                     -- Here we can see airbnb is a travel, but not populated, could be same for the others, lets write a query to update the NULL values from the another row with the same company name
from layoffs_staging2
where company = 'Airbnb';

select t1.industry,t2.industry                                                 -- Performing self join on the basis of 'industry' coloumn to get rid of any blank or null values 
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null
;

update layoffs_staging2 t1                                                             -- Updating the data set with the above query
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null ;

select *                                                                         -- Let's check if ceratin coloumns are Null
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

delete                                                                          -- Deleting the coloumns with null values
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

alter table layoffs_staging2                                              -- Now finally lets get rid of the row_num coloumn we created it for reference in the beginning 
drop column row_num; 

select *                                                                 
from layoffs_staging2
