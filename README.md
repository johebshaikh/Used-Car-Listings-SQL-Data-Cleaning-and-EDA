# Used Car Listings: SQL Data Cleaning and EDA

A practice project in MySQL: clean a messy used car listings table, then explore it with SQL.

## About the data

- **File:** `used_car_listings.csv` (1,227 rows, 11 columns)
- **Columns:** brand, model, city, fuel_type, transmission, year, mileage_km, price_usd, listing_date, country, seller_type
- **Important:** this is a **synthetic dataset** created for practice, with problems planted on purpose. The findings below describe this file only, not the real used car market.

## Tools

MySQL Workbench, SQL (CTEs, window functions, self joins).

## Approach

The method follows the data cleaning and EDA structure from Alex the Analyst's SQL portfolio project tutorial, applied here to a new dataset.

## Cleaning steps

Work was done on a copy (`car_listings_staging2`), and the raw table was left untouched.

| Step | What I did | Result |
|---|---|---|
| 1. Staging copy | Copied the raw table into a staging table | 1,227 rows |
| 2. Remove duplicates | `ROW_NUMBER()` partitioned by all columns in a CTE, copied into a second staging table with a `row_num` column, deleted rows where `row_num > 1` | 46 duplicates removed, 1,181 rows |
| 3. Standardize brand | `TRIM` for extra spaces, `LIKE 'Hyundai%'` to merge Hyundai variants, fixed upper and lower case Toyota values | 9 distinct brands |
| 4. Standardize country | `TRIM(TRAILING '.' FROM country)` to fix "United States." | 4 countries |
| 5. Fix date column | `STR_TO_DATE(listing_date, '%m/%d/%Y')`, then `ALTER TABLE` to the `DATE` type | Real dates |
| 6. Fix mileage type | Changed `mileage_km` from text to `INT` so numeric functions work | Correct max and averages |
| 7. Remove useless rows | Deleted rows where both `mileage_km` and `price_usd` were NULL | 22 removed, 1,159 rows |
| 8. Fill missing fuel type | Self join on brand and model to copy `fuel_type` from another row of the same car | All filled except Rivian R1T (one row, no source to copy from) |
| 9. Drop helper column | Removed `row_num` | 11 columns |

## EDA and findings

All numbers come from the cleaned table of 1,159 rows.

- **Price range:** from 1,500 to 64,000 USD. 99 listings are priced at exactly 1,500, which looks like a price floor in the data. In real data this would need investigating.
- **Brands:** Tesla has the most listings (162). Maruti Suzuki has the lowest average price (3,808). Tesla has the highest average among brands with more than one listing (16,300).
- **Countries:** the United States has the most listings (426) and the highest average price (10,569) when all brands are included. India's average (8,799) is pulled down by Maruti Suzuki, which is listed only in India. Without Maruti Suzuki, India's average rises to 11,563 and becomes the highest. So the country gap is a **brand mix effect**, not a conclusion about buyers or income.
- **Fuel type:** Petrol has the most listings (594). Electric has the highest average price (16,300).
- **Time:** listings run from 2 Jan 2023 to 28 Dec 2025. Counts per year are 421, 383 and 355. June 2024 is the busiest month (45 listings).
- **Rolling total:** the running total of listings by month ends at 1,159, matching the table size.
- **Top 3 brands per year** (by listings, using `DENSE_RANK`): Tesla leads in 2023 (62) and 2025 (54). In 2024, Honda and Volkswagen tie for first (59 each).

## Lessons learned

- Check the data type before trusting `MAX()`. Mileage stored as text gave 99,645 as the "maximum" instead of 179,976.
- Check the mix before explaining an average. The brand mix explained India's low average.
- `DENSE_RANK` needs `DESC` to give the top results. Without it you get the bottom ones.
- Small groups mislead. Rivian topped the average price list with a single row.

## How to reproduce

1. Create a schema in MySQL Workbench and import `used_car_listings.csv` with the Table Data Import Wizard as table `car_listings`.
2. Run the cleaning script, then the EDA script.
3. Check that the row counts match the table above.
