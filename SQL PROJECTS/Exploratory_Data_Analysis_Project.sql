-- EXPLORATORY DATA ANALYSIS 

select *
from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off)                                   -- Initially lets check the maximum total and percentage laid offs
from layoffs_staging2;

select *                                                                             -- here percent laid off = 1 means the company got laid off aprox 100% of the employees
from layoffs_staging2
where percentage_laid_off = 1;

select company, sum(total_laid_off)                                                   -- Lets check the sum of total laid off in descending order of different companys
from layoffs_staging2
group by company
order by 2 desc
;

select min(`date`), max(`date`)                                     -- We are checking the initial and the last date of layoffs by different companys        
from layoffs_staging2
;

select industry, sum(total_laid_off)                                     -- Lets check the sum of total laid off in descending order of different industries
from layoffs_staging2
group by industry
order by 2 desc
;

select stage, sum(total_laid_off)                                -- Lets check the sum of total laid off in descending order of different stages (i.e stage coloumn)
from layoffs_staging2
group by stage
order by 2 desc
;

select country, sum(total_laid_off)                                     -- Lets check the sum of total laid off in descending order of different countries
from layoffs_staging2
group by country
order by 2 desc
;

select year(`date`), sum(total_laid_off)                               -- Here we can observe the diff total laid offs in the span of 3 years (i.e 2020-2023) 
from layoffs_staging2
group by year(`date`)
order by 1 desc
;

select stage, sum(total_laid_off)                               -- Here we can observe the diff total laid offs in the span of 3 years (i.e 2020-2023) 
from layoffs_staging2
group by stage
order by 2 desc
;

select substring(`date`,1,7), sum(total_laid_off)               -- Here we can observe the diff total laid offs in 'yyyy-mm' format (i.e 2020-03) 
from layoffs_staging2
where substring(`date`,1,7) is not null
group by substring(`date`,1,7)
order by 1
;


-- Now lets create a Rolling total of all the total_laid_offs starting from the initial date of laid_offs to the last date of laid_offs with the 
-- above information by using a CTE  

with Rolling_total as
(
select substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7)is not null
group by substring(`date`,1,7)
order by 1
)
select `MONTH`, total_off,  sum(total_off) over(order by `MONTH`) as rolling_total
from Rolling_total
group by `MONTH`  
;

select company, year(`date`), sum(total_laid_off)                                     -- We are checking the sum of total_laid_offs of a company for a specific year
from layoffs_staging2
group by company, year(`date`)
order by 3 desc
;

with Company_year (company, years, total_laid_off)  as 
(
select company, year(`date`), sum(total_laid_off)                                     -- We have created a CTE for the above information
from layoffs_staging2
group by company, year(`date`)
),
Company_year_rank as                                                                               -- By creating a CTE within a CTE to determine ranking of individual companies 
(
select *, dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
order by ranking 
)
select *
from Company_year_rank
where Ranking <=5
;



with Company_year (company, industry, years, total_laid_off)  as 
(
select company, industry, year(`date`), sum(total_laid_off)                                     -- We have created a CTE for the above information
from layoffs_staging2
group by company, industry, year(`date`)
),
Company_year_rank as                                                                               -- By creating a CTE within a CTE to determine ranking of individual companies 
(
select *, dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
order by ranking 
)
select *
from Company_year_rank
where Ranking <=5
;




