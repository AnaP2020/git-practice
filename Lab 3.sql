USE sakila;

-- Shortest and Longest Movie Durations
SELECT 
    MIN(length) AS min_duration, 
    MAX(length) AS max_duration
FROM film;

-- Average Movie Duration in Hours and Minutes
SELECT 
    FLOOR(AVG(length) / 60) AS average_hours, 
    FLOOR(AVG(length) % 60) AS average_minutes
FROM film;

-- Number of Days the Company Has Been Operating
SELECT 
    DATEDIFF(MAX(rental_date), MIN(rental_date)) AS days_operating
FROM rental;

-- Rental Information with Month and Weekday

SELECT 
    rental_id,
    rental_date,
    MONTH(rental_date) AS rental_month,
    DAYNAME(rental_date) AS rental_weekday
FROM rental
LIMIT 20;

-- Adding a DAY_TYPE Column Indicating 'weekend' or 'workday'

SELECT 
    rental_id,
    rental_date,
    CASE
        WHEN DAYOFWEEK(rental_date) IN (1, 7) THEN 'weekend' -- 1 is Sunday, 7 is Saturday
        ELSE 'workday'
    END AS day_type
FROM rental
LIMIT 20;

-- film titles and their rental duration
SELECT 
    title,
    IFNULL(rental_duration, 'Not Available') AS rental_duration
FROM 
    film
ORDER BY 
    title ASC;
    
    -- personalized email campaign for customers
    SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    LEFT(email, 3) AS email_prefix
FROM 
    customer
ORDER BY 
    last_name ASC;
    
-- Total Number of Films Released
SELECT COUNT(*) AS total_films
FROM film;

-- Number of Films for Each Rating
SELECT 
    rating, 
    COUNT(*) AS number_of_films
FROM 
    film
GROUP BY 
    rating;
    
-- Number of Films for Each Rating, Sorted by Number of Films
SELECT 
    rating, 
    COUNT(*) AS number_of_films
FROM 
    film
GROUP BY 
    rating
ORDER BY 
    number_of_films DESC;
    
-- Mean Film Duration for Each Rating, Descending Order
SELECT 
    rating, 
    ROUND(AVG(length), 2) AS mean_duration
FROM 
    film
GROUP BY 
    rating
ORDER BY 
    mean_duration DESC;
    
-- Ratings with a Mean Duration Over Two Hours
SELECT 
    rating, 
    ROUND(AVG(length), 2) AS mean_duration
FROM 
    film
GROUP BY 
    rating
HAVING 
    mean_duration > 120;
    
-- Unique Last Names in the Actor Table
SELECT 
    last_name
FROM 
    actor
GROUP BY 
    last_name
HAVING 
    COUNT(*) = 1;