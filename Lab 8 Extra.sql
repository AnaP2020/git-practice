USE sakila

-- Challenge 1
-- Ranking films by their length
SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0;
  
-- Ranking films by length within each rating category
SELECT
    title,
    length,
    rating,
    RANK() OVER (
        PARTITION BY rating
        ORDER BY length DESC
    ) AS film_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0;
  
-- For each film, show the actor/actress with the greatest number of film appearances
WITH actor_film_count AS (
    SELECT
        actor_id,
        COUNT(*) AS total_films
    FROM film_actor
    GROUP BY actor_id
),
film_actor_rank AS (
    SELECT
        f.film_id,
        f.title,
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        afc.total_films,
        RANK() OVER (
            PARTITION BY f.film_id
            ORDER BY afc.total_films DESC
        ) AS actor_rank
    FROM film AS f
    JOIN film_actor AS fa
        ON f.film_id = fa.film_id
    JOIN actor AS a
        ON fa.actor_id = a.actor_id
    JOIN actor_film_count AS afc
        ON a.actor_id = afc.actor_id
)
SELECT
    title,
    actor_name,
    total_films
FROM film_actor_rank
WHERE actor_rank = 1
ORDER BY title;

-- Challenge 2
-- Monthly active customers
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT *
FROM monthly_active
ORDER BY month;

-- Active customers in the previous month
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month) AS previous_month_active
FROM monthly_active
ORDER BY month;

-- Percentage change in active customers
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month) AS previous_month_active,
    ROUND(
        (
            active_customers -
            LAG(active_customers) OVER (ORDER BY month)
        ) * 100.0 /
        LAG(active_customers) OVER (ORDER BY month),
        2
    ) AS percentage_change
FROM monthly_active
ORDER BY month;

-- Retained customers
WITH customer_month AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS month
    FROM rental
)
SELECT
    c1.month,
    COUNT(DISTINCT c1.customer_id) AS retained_customers
FROM customer_month c1
JOIN customer_month c2
    ON c1.customer_id = c2.customer_id
   AND PERIOD_DIFF(
        REPLACE(c1.month, '-', ''),
        REPLACE(c2.month, '-', '')
   ) = 1
GROUP BY c1.month
ORDER BY c1.month;

-- Combined query
WITH customer_month AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS month
    FROM rental
),
monthly_active AS (
    SELECT
        month,
        COUNT(customer_id) AS active_customers
    FROM customer_month
    GROUP BY month
),
retained AS (
    SELECT
        c1.month,
        COUNT(DISTINCT c1.customer_id) AS retained_customers
    FROM customer_month c1
    JOIN customer_month c2
      ON c1.customer_id = c2.customer_id
     AND PERIOD_DIFF(
            REPLACE(c1.month, '-', ''),
            REPLACE(c2.month, '-', '')
        ) = 1
    GROUP BY c1.month
)
SELECT
    m.month,
    m.active_customers,
    LAG(m.active_customers) OVER (ORDER BY m.month) AS previous_month_active,
    ROUND(
        (
            m.active_customers -
            LAG(m.active_customers) OVER (ORDER BY m.month)
        ) * 100.0 /
        LAG(m.active_customers) OVER (ORDER BY m.month),
        2
    ) AS percentage_change,
    COALESCE(r.retained_customers, 0) AS retained_customers
FROM monthly_active m
LEFT JOIN retained r
    ON m.month = r.month
ORDER BY m.month;