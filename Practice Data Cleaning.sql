select count(*)
from car_listings;

select *
from car_listings;

-- copying the tabel into different table



create table car_listings_staging
like car_listings;

insert  car_listings_staging
select *
from car_listings;

select *
from car_listings_staging;

select count(*)
from car_listings_staging;


select *,
row_number() over (partition by brand, model, city, fuel_type,transmission, year,mileage_km,price_usd, `listing_date`, country, seller_type) as row_num
FROM car_listings_staging;



with duplicate_cte As 
(
select *,
row_number() over (partition by brand, model, city, fuel_type,transmission, year,mileage_km,price_usd, `listing_date`, country, seller_type) as row_num
FROM car_listings_staging
)
select *
from duplicate_cte
where row_num >1;



with duplicate_cte As 
(
select *,
row_number() over (partition by brand, model, city, fuel_type,transmission, year,mileage_km,price_usd, `listing_date`, country, seller_type) as row_num
FROM car_listings_staging
)
select count(row_num)
from duplicate_cte
where row_num >1;


select *
from car_listings_staging
where brand = 'Ford';



CREATE TABLE `car_listings_staging2` (
  `brand` text,
  `model` text,
  `city` text,
  `fuel_type` text,
  `transmission` text,
  `year` int DEFAULT NULL,
  `mileage_km` text,
  `price_usd` int DEFAULT NULL,
  `listing_date` text,
  `country` text,
  `seller_type` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from car_listings_staging2;

insert car_listings_staging2
select *,
row_number() over (partition by brand, model, city, fuel_type,transmission, year,mileage_km,price_usd, `listing_date`, country, seller_type) as row_num
FROM car_listings_staging;

SELECT *
FROM car_listings_staging2
where row_num >1;


delete 
FROM car_listings_staging2
where row_num >1;

select count(row_num)
from car_listings_staging2
;


-- 2 standerdization

select *
from car_listings_staging2;


select distinct brand 
from car_listings_staging2
order by 1;


select brand, trim(brand) 
from car_listings_staging2;

update car_listings_staging2
set brand =  trim(brand);

select *
from car_listings_staging2
where brand like 'To%';


update car_listings_staging2
set brand ='Toyota'
where brand = 'TOYOTA';

select *
from car_listings_staging2
where brand like 'Hyundai%';

update car_listings_staging2
set brand = 'Hyundai'
where brand like 'Hyundai%';

select distinct brand 
from car_listings_staging2
order by 1;




select distinct model 
from car_listings_staging2
order by 1;

select distinct city 
from car_listings_staging2
order by 1;

-- Fuel type has empty row need to check but lets veryify distinct for all
select distinct fuel_type 
from car_listings_staging2
order by 1;


select *
from car_listings_staging2;



-- 1. Find rows where fuel_type is missing (NULL or empty text)
select *
from car_listings_staging2
where fuel_type is null or fuel_type = '';

-- 2. Look at one model that has the problem (pick a model from the result above)
select *
from car_listings_staging2
where model = 'Corolla';

-- 3. Turn empty texts '' into real NULLs
UPDATE car_listings_staging2
SET fuel_type = NULL
WHERE fuel_type = '';


-- 4. Preview: t1 = missing fuel_type, t2 = same brand and model with a fuel_type

select t1.fuel_type, t2.fuel_type
from car_listings_staging2 t1
join car_listings_staging2 t2
	on t1.brand =t2.brand
    and t1.model =t2.model
    where t1.fuel_type is null
    and t2.fuel_type is not null;


-- 5. The real fix: copy t2's fuel_type into t1
update car_listings_staging2 t1
join car_listings_staging2 t2
	on t1.brand = t2.brand
	and t1.model = t2.model
set t1.fuel_type = t2.fuel_type
WHERE t1.fuel_type IS NULL 
AND t2.fuel_type IS NOT NULL;

-- 6. Check what is still missing
select *
from car_listings_staging2
where fuel_type is null or fuel_type = '';




select distinct transmission 
from car_listings_staging2
order by 1;


select distinct country 
from car_listings_staging2
order by 1;

select distinct country , trim(trailing '.' from country)
from car_listings_staging2
order by 1;

-- Then save the fix into the table:

update car_listings_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';


select distinct seller_type 
from car_listings_staging2
order by 1;

-- Let's also fix the date columns:

SELECT *
FROM car_listings_staging2;

select `listing_date`
from car_listings_staging2;


-- (String to Date) function takes text that looks like a date and converts it into an actual date 
-- format that a computer can understand and work with.

select `listing_date`, str_to_date(`listing_date`, '%m/%d/%Y') 
from car_listings_staging2;


-- we can use str to date to update this field
UPDATE car_listings_staging2
SET `listing_date` = STR_TO_DATE(`listing_date`, '%m/%d/%Y');


select `listing_date`
from car_listings_staging2;


-- now we can convert the data type properly
ALTER TABLE car_listings_staging2
MODIFY COLUMN `listing_date` DATE;




SELECT *
FROM car_listings_staging2;

select mileage_km, price_usd
from car_listings_staging2
where mileage_km is Null
and price_usd is  null;


DELETE FROM car_listings_staging2
WHERE mileage_km IS NULL
AND price_usd IS NULL;

ALTER TABLE car_listings_staging2
DROP COLUMN row_num;

SELECT *
FROM car_listings_staging2;











