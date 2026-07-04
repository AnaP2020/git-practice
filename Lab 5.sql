-- Determining the Number of Copies of the Film "Hunchback Impossible"
USE sakila;

SELECT 
    COUNT(*) AS number_of_copies
FROM 
    inventory
WHERE 
    film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');
    
-- Listing All Films Longer Than Average Length
SELECT 
    title, 
    length
FROM 
    film
WHERE 
    length > (SELECT AVG(length) FROM film);
    
-- Displaying All Actors in "Alone Trip"
SELECT 
    a.first_name, 
    a.last_name
FROM 
    actor a
JOIN 
    film_actor fa ON a.actor_id = fa.actor_id
WHERE 
    fa.film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip');
    
-- Identifying All Movies Categorized as Family Films
SELECT 
    f.title
FROM 
    film f
JOIN 
    film_category fc ON f.film_id = fc.film_id
JOIN 
    category c ON fc.category_id = c.category_id
WHERE 
    c.name = 'Family';
    
-- Retrieving Name and Email of Customers from Canada 
SELECT 
    first_name, 
    last_name, 
    email
FROM 
    customer
WHERE 
    address_id IN (
        SELECT address_id
        FROM address
        WHERE city_id IN (
            SELECT city_id 
            FROM city 
            WHERE country_id = (
                SELECT country_id 
                FROM country 
                WHERE country = 'Canada'
            )
        )
    );
    
-- Determining Films Starred by Most Prolific Actor
-- most prolific actor

SELECT 
    actor_id 
FROM 
    film_actor 
GROUP BY 
    actor_id 
ORDER BY 
    COUNT(film_id) DESC 
LIMIT 1;
-- retrieving films starred by this actor
SELECT 
    f.title
FROM 
    film f
JOIN 
    film_actor fa ON f.film_id = fa.film_id
WHERE 
    fa.actor_id = (
        SELECT 
            actor_id 
        FROM 
            film_actor 
        GROUP BY 
            actor_id 
        ORDER BY 
            COUNT(film_id) DESC 
        LIMIT 1
    );

-- Retrieving Films Rented by Most Profitable Customer
-- most profitable customer
SELECT 
    customer_id
FROM 
    payment
GROUP BY 
    customer_id
ORDER BY 
    SUM(amount) DESC 
LIMIT 1;
-- films rented by this customer
SELECT 
    f.title
FROM 
    rental r
JOIN 
    inventory i ON r.inventory_id = i.inventory_id
JOIN 
    film f ON i.film_id = f.film_id
WHERE 
    r.customer_id = (
        SELECT 
            customer_id 
        FROM 
            payment 
        GROUP BY 
            customer_id 
        ORDER BY 
            SUM(amount) DESC 
        LIMIT 1
    );
    
-- Retrieving Clients Who Spend More Than Average Total Amount
-- Calculating the total and comparing it against the average
SELECT 
    customer_id, 
    total_amount_spent
FROM (
    SELECT 
        customer_id, 
        SUM(amount) AS total_amount_spent
    FROM 
        payment
    GROUP BY 
        customer_id
    ) AS customer_totals
WHERE 
    total_amount_spent > (
        SELECT 
            AVG(customer_total) 
        FROM (
            SELECT 
                SUM(amount) AS customer_total
            FROM 
                payment
            GROUP BY 
                customer_id
            ) AS totals
    );