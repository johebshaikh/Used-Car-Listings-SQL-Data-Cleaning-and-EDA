-- EDA

select *
from car_listings_staging2;


select max(price_usd), min(price_usd)
from car_listings_staging2;

-- I noticed mileage_km is in text format so converting into int



ALTER TABLE car_listings_staging2
MODIFY COLUMN mileage_km INT;


select max(mileage_km)
from car_listings_staging2
where mileage_km is not null;

-- Show the full rows for the 5 most expensive listings.
select *
from car_listings_staging2;

select *
from car_listings_staging2
order by price_usd desc
limit 5;


-- Show the full rows for the 5 cheapest listings.
select *
from car_listings_staging2
where price_usd is not null
order by price_usd 
limit 5;


-- For each brand, show the number of listings and the average price, sorted by listing count, highest first.

select brand ,count(brand), round(avg(price_usd), 0)
from car_listings_staging2
group by 1
order by 2 desc;

-- the higest listing count is Tesla of 162

-- Which brand has the highest average price and which has the lowest? Round to whole numbers.

select brand , count(brand),round(avg(price_usd), 0)
from car_listings_staging2
group by 1
order by 3 desc;

-- as rivan has only one count so leaving it then the highest becomes tesla with av 16300 and the lowest is maruti suzuki with avg 3808

-- highest is 'Rivian', '1', '64000'
-- and the lowest is 'Maruti Suzuki', '144', '3808'



-- Question 4: country

-- For each country, show the number of listings, the average price (rounded) and the average mileage (rounded), 
-- sorted by listing count, highest first.

select*
from car_listings_staging2
;

select country, count(brand) as Number_of_listings, round(avg(price_usd),0)as avg_price, round(avg(mileage_km),0) as avg_mileage
from car_listings_staging2
group by 1
order by 2 desc;
-- Tell me the top country and its listing count.- USA and its listing is 426

-- Which country has the highest average price?
select country, count(brand) as Number_of_listings, round(avg(price_usd),0)as avg_price, round(avg(mileage_km),0) as avg_mileage
from car_listings_staging2
group by 1
order by 3 desc;
-- Unites states has higest avg price of 10569 



-- Question 5: fuel type is next:

-- For each fuel_type, show the number of listings and the average price (rounded).
select *
from car_listings_staging2;

select fuel_type, count(brand), round(avg(price_usd),0)
from car_listings_staging2
where fuel_type is not null
group by 1
order by 2 desc;

-- 'Petrol','594','7523'
-- Diesel','330','10746'
-- 'Electric','162','16300'
-- 'Hybrid','72','8587'



-- Tell me how many rows have a NULL fuel_type, and which brand and model it is.
select model, brand,fuel_type, count(brand), round(avg(price_usd),0)
from car_listings_staging2
group by 1,2,3
order by 3 desc;

-- one row and RIT model rivan brand

-- Which fuel type has the highest average price?
select fuel_type, round(avg(price_usd),0)
from car_listings_staging2
where fuel_type is not null
group by 1
order by 2 desc;

-- If we ignore null then 'Electric', '16300'



-- Question 6: date range
-- 1. In Alex's video, he checks the earliest and latest dates before anything else with dates.
select *
from car_listings_staging2;

select min(`listing_date`), max(`listing_date`)
from car_listings_staging2;
-- As we can see the dates of car listings starts from 2nd jan 2023 to 28th dec 2025 almots 3 years of dtata



-- 2. Write a query that counts the number of listings per year, using year(), sorted by year. 
-- Tell me how many years there are and the count for each.
select *
from car_listings_staging2
;

select count(brand) as number_of_listings, year(`listing_date`)
from car_listings_staging2
group by 2
order by 2;

-- there are three years in 2023 the listing were 421 and 2024 it was 383 and 2025 it was 355.




-- Question 7: monthly counts
-- Alex uses substring(date, 1, 7) to get year and month:
select *
from car_listings_staging2
;
-- 1. Write a query that returns the number of listings per month, using substring(listing_date, 1, 7), sorted by month.

select substring(`listing_date`,1,7) as months, count(brand) as number_of_listings
from car_listings_staging2
group by 1
order by 1 ;

-- 2.How many rows does it return?
-- 36 rows

-- 3. Which month has the most listings, and how many?

select substring(`listing_date`,1,7) as months, count(brand) as number_of_listings
from car_listings_staging2
group by 1
order by 2 ;

-- 2024 june has most listings which is 45






-- Question 8: rolling total is still waiting for you:

-- Build the monthly count of listings inside a CTE.

with montly_listing as 
(
select substring(`listing_date`,1,7) as months, count(brand) as number_of_listings
from car_listings_staging2
group by 1
order by 1 
)
select *
from montly_listing;

-- In the final select, add a rolling total, so each month shows how many listings there have been so far.


with rolling_total as 
(
select substring(`listing_date`,1,7) as months, count(brand) as number_of_listings
from car_listings_staging2
group by 1
order by 1 
)
select months, number_of_listings,sum(number_of_listings) over (order by `months`)
from rolling_total;
-- Tell me the rolling total for the last month (December 2025). -1159





-- Question 9: top 3 brands per year
-- This matches Alex's "top 5 companies per year" query, using dense_rank and two CTEs.

-- Write a query that gives the number of listings for each brand in each year.

select *
from car_listings_staging2;

select brand, count(brand) as number_of_listings , year (`listing_date`) as Years 
from car_listings_staging2
group by brand, year (`listing_date`)
order by count(brand) desc;


-- Add a ranking with dense_rank(), so the ranking restarts for each year. Use the number of listings for the order.


  
with rankingz_1 as
(
select brand, count(brand) as number_of_listings, year (`listing_date`) as years
from car_listings_staging2
group by brand, years
order by number_of_listings desc
)
select brand,number_of_listings, years, dense_rank() over (partition by years order by number_of_listings) as rankings
from rankingz_1;


-- Keep only the top 3 brands per year, using a second CTE, since you can't filter on a column in the same query that creates it.

with rankingz_1 as
(
select brand, count(brand) as number_of_listings, year (`listing_date`) as years
from car_listings_staging2
group by brand, years
order by number_of_listings desc
),
rankingz_2 as
(
select brand,number_of_listings, years, dense_rank() over (partition by years order by number_of_listings desc) as rankings
from rankingz_1
)
select *
from rankingz_2
where rankings <= 3;

-- Tell me how many rows your final result has, and who is #1 in 2023, with the count.

-- 12 rows and hyundai 51 