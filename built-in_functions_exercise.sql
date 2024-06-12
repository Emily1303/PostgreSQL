-- Built-in Functions - Exercise 

-- 01. River Info 
CREATE VIEW view_river_info
	AS
SELECT 
	CONCAT_WS(
		' ', 
		'The river', 
		river_name, 
		'flows into the', 
		outflow, 
		'and is', 
		"length", 
		'kilometers long.'
	) AS "River Information"
FROM rivers
ORDER BY river_name ASC;

-- 02. Concatenate Geography Data 
CREATE VIEW view_continents_countries_currencies_details
	AS
SELECT 
	CONCAT_WS(': ', con.continent_name, con.continent_code)
		AS continent_details, 
	CONCAT_WS(' - ', cou.country_name, cou.capital, cou.area_in_sq_km, 'km2') 
		AS country_information, 
	CONCAT(cur.description, ' (', cur.currency_code, ')') 
		AS currencies
FROM continents AS con, 
	countries AS cou, 
	currencies AS cur
WHERE con.continent_code = cou.continent_code
	AND
	cou.currency_code = cur.currency_code
ORDER BY 
	CONCAT_WS(' - ', cou.country_name, cou.capital, cou.area_in_sq_km, 'km2'), 
	CONCAT(cur.description, ' (', cur.currency_code, ')');

SELECT * FROM view_continents_countries_currencies_details;

-- 03. Capital Code 
ALTER TABLE countries
ADD COLUMN capital_code CHAR(2);

UPDATE countries
SET capital_code = SUBSTRING(capital, 1, 2)
RETURNING *;

-- 04. Description 
-- 1.
SELECT 
	RIGHT(description, -4)
FROM currencies;
-- 2.
SELECT 
	SUBSTRING(description, 5)
FROM currencies;

-- 05. Substring River Length 
--1. 
SELECT 
	SUBSTRING("River Information", '[0-9]{1,4}')
		AS river_length
FROM view_river_info;
-- 2. 
SELECT
	(REGEXP_MATCHES("River Information", '[0-9]{1,4}'))[1]
		AS river_length
FROM view_river_info;

-- 06. Replace A 
SELECT
	REPLACE(mountain_range, 'a', '@') AS replace_a, 
	REPLACE(mountain_range, 'A', '$') AS "replace_A"
FROM mountains;

-- 07. Translate 
SELECT 
	capital,
	TRANSLATE(capital, 'áãåçéíñóú', 'aaaceinou')
		AS translated_name
FROM countries;

-- 08. LEADING 
-- 1.
SELECT 
	continent_name, 
	TRIM(LEADING FROM continent_name)
		AS "trim"
FROM continents;
-- 2. 
SELECT 
	continent_name, 
	LTRIM(continent_name)
		AS "trim"
FROM continents;

-- 09. TRAILING 
-- 1.
SELECT 
	continent_name, 
	TRIM(TRAILING FROM continent_name) 
		AS "trim"
FROM continents;
-- 2.
SELECT 
	continent_name, 
	RTRIM(continent_name)
		AS "trim"
FROM continents;

-- 10. LTRIM & RTRIM 
SELECT 
	LTRIM(peak_name, 'M') AS left_trim, 
	RTRIM(peak_name, 'm') AS right_trim
FROM peaks;

-- 11. Character Length and Bits 
SELECT 
	CONCAT_WS(
		' ', 
		"m".mountain_range, 
		"p".peak_name
	) AS mountain_information, 
	CHAR_LENGTH(CONCAT_WS(' ', "m".mountain_range, "p".peak_name))
		AS characters_length, 
	BIT_LENGTH(CONCAT_WS(' ', "m".mountain_range, "p".peak_name))
		AS bits_of_a_tring
FROM mountains AS "m", 
	peaks AS "p"
WHERE "m".id = "p".mountain_id;

-- 12. Length of a Number 
SELECT 
	population, 
	LENGTH(CAST(population AS VARCHAR))
		AS "length"
FROM countries;

-- 13. Positive and Negative LEFT 
SELECT 
	peak_name, 
	LEFT(peak_name, 4) 
		AS positive_left, 
	LEFT(peak_name, -4) 
		AS negative_left
FROM peaks;

-- 14. Positive and Negative RIGHT 
SELECT 
	peak_name, 
	RIGHT(peak_name, 4) 
		AS positive_right, 
	RIGHT(peak_name, -4) 
		AS negative_right
FROM peaks;

-- 15. Update iso_code 
UPDATE countries
SET iso_code = UPPER(LEFT(country_name, 3))     -- SUBSTRING(country_name, 1, 3)
WHERE iso_code IS NULL
RETURNING *;

-- 16. REVERSE country_code 
UPDATE countries
SET country_code = LOWER(REVERSE(country_code))
RETURNING *;

-- 17. Elevation --->> Peak Name 
SELECT
	CONCAT_WS(
		' ', 
		elevation, 
		CONCAT(REPEAT('-', 3), REPEAT('>', 2)), 
		peak_name
	) AS "Elevation --->> Peak Name"
FROM peaks
WHERE elevation >= 4884;

-- 18. Arithmetical Operators 
CREATE TABLE bookings_calculation
	AS
SELECT
	booked_for
FROM bookings
WHERE apartment_id = 93;

ALTER TABLE bookings_calculation
ADD COLUMN multiplication NUMERIC, 
ADD COLUMN modulo NUMERIC;

UPDATE bookings_calculation
SET multiplication = CAST(booked_for AS NUMERIC) * 50, 
	modulo = CAST(booked_for AS NUMERIC) % 50;

SELECT * FROM bookings_calculation;

-- 19. ROUND vs TRUNC 
SELECT
	latitude, 
	ROUND(latitude, 2) AS "round", 
	TRUNC(latitude, 2) AS "trunc"
FROM apartments;

-- 20. Absolute Value 
SELECT
	longitude, 
	ABS(longitude) AS "abs"
FROM apartments;

-- 21. Billing Day 
ALTER TABLE bookings
ADD COLUMN billing_day TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

SELECT
	TO_CHAR(billing_day, 'DD "Day" MM "Month" YYYY "Year" HH24:MI:SS')
		AS "Billing Day"
FROM bookings;

-- 22. EXTRACT Booked At 
SELECT 
	EXTRACT('year' FROM booked_at) AS "YEAR",                  -- DATE_PART() is the same
	EXTRACT('month' FROM booked_at) AS "MONTH", 
	EXTRACT('day' FROM booked_at) AS "DAY", 
	EXTRACT('hour' FROM booked_at AT TIME ZONE 'UTC')
		AS "HOUR", 
	EXTRACT('minute' FROM booked_at) AS "MINUTE", 
	CEILING(EXTRACT('second' FROM booked_at)) AS "SECOND"
FROM bookings;

-- 23. Early Birds 
SELECT
	user_id, 
	AGE(starts_at, booked_at)
		AS early_birds
FROM bookings
WHERE AGE(starts_at, booked_at) >= '10 mons';

-- 24. Match or Not 
SELECT 
	companion_full_name, 
	email
FROM users
WHERE companion_full_name ILIKE '%aNd%' 
	AND
email NOT LIKE '%@gmail';

-- 25. COUNT by Initial 
ALTER TABLE users
ADD COLUMN initials CHAR(2);

UPDATE users
SET initials = LEFT(first_name, 2);

SELECT
	initials, 
	COUNT(*) AS user_count
FROM users
GROUP BY initials
ORDER BY user_count DESC, 
	initials ASC;

-- 26. SUM 
SELECT
	SUM(booked_for) AS total_value
FROM bookings
WHERE apartment_id = 90;

-- 27. Average Value 
SELECT
	AVG(multiplication) AS average_value
FROM bookings_calculation;

