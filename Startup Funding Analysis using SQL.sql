USE startup_funding_db;
SHOW TABLES;
RENAME TABLE `startup_funding.csv` TO startup_funding;
SELECT * FROM startup_funding LIMIT 10;
DESC startup_funding;
ALTER TABLE startup_funding
CHANGE `Sr No` sr_no INT,
CHANGE `Date dd/mm/yyyy` funded_date TEXT,
CHANGE `Startup Name` startup_name TEXT,
CHANGE `Industry Vertical` industry_vertical TEXT,
CHANGE `SubVertical` sub_vertical TEXT,
CHANGE `City  Location` city_location TEXT,
CHANGE `Investors Name` investors_name TEXT,
CHANGE `InvestmentnType` investment_type TEXT,
CHANGE `Amount in USD` amount_usd TEXT,
CHANGE `Remarks` remarks TEXT;
SHOW COLUMNS FROM startup_funding;
SELECT 
  SUM(sr_no IS NULL) AS missing_sr_no,
  SUM(funded_date IS NULL OR funded_date = '') AS missing_funded_date,
  SUM(startup_name IS NULL OR startup_name = '') AS missing_startup_name,
  SUM(industry_vertical IS NULL OR industry_vertical = '') AS missing_industry,
  SUM(amount_usd IS NULL OR amount_usd = '') AS missing_amount
FROM startup_funding;
ALTER TABLE startup_funding ADD COLUMN amount_cleaned BIGINT;
ALTER TABLE startup_funding ADD COLUMN formatted_date DATE;
UPDATE startup_funding
SET amount_cleaned = CAST(
  REPLACE(
    REPLACE(amount_usd, ',', ''), -- remove commas
    'USD', ''
  ) AS UNSIGNED
)
WHERE amount_usd REGEXP '^[0-9,]+( USD)?$';
UPDATE startup_funding
SET formatted_date = STR_TO_DATE(funded_date, '%d/%m/%Y')
WHERE funded_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';
SELECT DISTINCT funded_date 
FROM startup_funding 
WHERE funded_date IS NOT NULL AND funded_date != ''
LIMIT 20;
UPDATE startup_funding
SET formatted_date = STR_TO_DATE(funded_date, '%d-%m-%Y')
WHERE funded_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';
SELECT DISTINCT funded_date 
FROM startup_funding 
WHERE funded_date IS NOT NULL AND funded_date != ''
LIMIT 10;
SELECT investors_name, COUNT(startup_name) AS total_funded
FROM startup_funding
GROUP BY investors_name
ORDER BY total_funded DESC
LIMIT 10;
SELECT city_location, startup_name, amount_cleaned
FROM startup_funding
ORDER BY amount_cleaned DESC
LIMIT 5;
SELECT SUM(amount_cleaned)
FROM startup_funding;
SELECT startup_name, amount_cleaned
FROM startup_funding
ORDER BY amount_cleaned DESC
LIMIT 1;
SELECT COUNT(investment_type)
FROM startup_funding;
SELECT investment_type, COUNT(*) AS total
FROM startup_funding
GROUP BY investment_type
ORDER BY total DESC;
SELECT city_location, SUM(amount_cleaned) AS total_funding
FROM startup_funding
GROUP BY city_location
ORDER BY total_funding DESC
LIMIT 5;
SELECT investors_name, COUNT(*) AS deals
FROM startup_funding
GROUP BY investors_name
ORDER BY deals
LIMIT 5;
SELECT YEAR(formatted_date) AS year, SUM(amount_cleaned) AS total_funding
FROM startup_funding
GROUP BY year
ORDER BY year;
SELECT 
  YEAR(formatted_date) AS funding_year,
  SUM(amount_cleaned) AS total_funding
FROM startup_funding
WHERE formatted_date IS NOT NULL
GROUP BY funding_year
ORDER BY funding_year;
SELECT 
  investors_name, 
  COUNT(*) AS total_investments
FROM startup_funding
WHERE investors_name IS NOT NULL AND investors_name != ''
GROUP BY investors_name
ORDER BY total_investments DESC
LIMIT 5;
SELECT 
  industry_vertical, 
  COUNT(*) AS total_funded
FROM startup_funding
WHERE industry_vertical IS NOT NULL AND industry_vertical != ''
GROUP BY industry_vertical
ORDER BY total_funded DESC
LIMIT 5;
SELECT 
  city_location, 
  SUM(amount_cleaned) AS total_funding
FROM startup_funding
WHERE city_location IS NOT NULL AND city_location != ''
GROUP BY city_location
ORDER BY total_funding DESC;
UPDATE startup_funding
SET city_location = 'Bangalore'
WHERE city_location IN ('Bengaluru', 'Bangalore / USA', 'Bangalore / SFO', 'Bangalore / San Mateo', '\\xc2\\xa0Bangalore');
UPDATE startup_funding
SET city_location = TRIM(REPLACE(city_location, '\\xc2\\xa0', ''))
WHERE city_location LIKE '%\\xc2\\xa0%';
SELECT 
  city_location, 
  SUM(amount_cleaned) AS total_funding
FROM startup_funding
WHERE city_location IS NOT NULL AND city_location != ''
GROUP BY city_location
ORDER BY total_funding DESC;
SELECT 
    CONCAT(YEAR(formatted_date), '-Q', QUARTER(formatted_date)) AS quarter,
    SUM(amount_cleaned) AS total_funding
FROM startup_funding
WHERE formatted_date IS NOT NULL
GROUP BY quarter
ORDER BY quarter;
SELECT 
    sf.startup_name,
    sf.amount_cleaned,
    ii.investor_type
FROM startup_funding sf
JOIN investors_info ii 
    ON sf.startup_name = ii.startup_name
ORDER BY sf.amount_cleaned DESC;
SELECT 
    a.startup_name AS startup_a,
    b.startup_name AS startup_b,
    a.amount_cleaned
FROM startup_funding a
JOIN startup_funding b 
    ON a.amount_cleaned = b.amount_cleaned
    AND a.startup_name < b.startup_name
ORDER BY a.amount_cleaned DESC
LIMIT 15;
SELECT startup_name, amount_cleaned
FROM startup_funding
WHERE amount_cleaned > (
    SELECT AVG(amount_cleaned)
    FROM startup_funding);
    WITH CityFunding AS (
    SELECT city_location, SUM(amount_cleaned) AS total_funding
    FROM startup_funding
    WHERE city_location IS NOT NULL AND city_location != ''
    GROUP BY city_location
)
SELECT city_location, total_funding
FROM CityFunding
ORDER BY total_funding DESC
LIMIT 5;
