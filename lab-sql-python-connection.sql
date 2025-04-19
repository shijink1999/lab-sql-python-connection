use sakila;
-- Step 1: Create temporary tables for May and June rentals
CREATE TEMPORARY TABLE may_rentals AS
SELECT 
    customer_id,
    COUNT(*) AS rentals_may_2005
FROM 
    rental
WHERE 
    MONTH(rental_date) = 5 AND YEAR(rental_date) = 2005
GROUP BY 
    customer_id;

CREATE TEMPORARY TABLE june_rentals AS
SELECT 
    customer_id,
    COUNT(*) AS rentals_june_2005
FROM 
    rental
WHERE 
    MONTH(rental_date) = 6 AND YEAR(rental_date) = 2005
GROUP BY 
    customer_id;

-- Step 2: Identify customers active in both months and compare activity
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    may_counts.rentals_may_2005,
    june_counts.rentals_june_2005,
    june_counts.rentals_june_2005 - may_counts.rentals_may_2005 AS rental_difference
FROM customer c
JOIN (
    SELECT customer_id, COUNT(*) AS rentals_may_2005
    FROM rental
    WHERE MONTH(rental_date) = 5 AND YEAR(rental_date) = 2005
    GROUP BY customer_id
) may_counts ON c.customer_id = may_counts.customer_id
JOIN (
    SELECT customer_id, COUNT(*) AS rentals_june_2005
    FROM rental
    WHERE MONTH(rental_date) = 6 AND YEAR(rental_date) = 2005
    GROUP BY customer_id
) june_counts ON c.customer_id = june_counts.customer_id
ORDER BY ABS(june_counts.rentals_june_2005 - may_counts.rentals_may_2005) DESC,
         c.last_name, c.first_name;

-- Alternative solution without temporary tables (single query approach)
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COALESCE(m.may_count, 0) AS rentals_may_2005,
    COALESCE(j.june_count, 0) AS rentals_june_2005,
    COALESCE(j.june_count, 0) - COALESCE(m.may_count, 0) AS rental_difference
FROM 
    customer c
LEFT JOIN (
    SELECT 
        customer_id, 
        COUNT(*) AS may_count
    FROM 
        rental
    WHERE 
        MONTH(rental_date) = 5 AND YEAR(rental_date) = 2005
    GROUP BY 
        customer_id
) m ON c.customer_id = m.customer_id
LEFT JOIN (
    SELECT 
        customer_id, 
        COUNT(*) AS june_count
    FROM 
        rental
    WHERE 
        MONTH(rental_date) = 6 AND YEAR(rental_date) = 2005
    GROUP BY 
        customer_id
) j ON c.customer_id = j.customer_id
WHERE 
    (m.customer_id IS NOT NULL AND j.customer_id IS NOT NULL)
ORDER BY 
    ABS(COALESCE(j.june_count, 0) - COALESCE(m.may_count, 0)) DESC,
    c.last_name, c.first_name;

-- Clean up (optional)
DROP TEMPORARY TABLE IF EXISTS may_rentals;
DROP TEMPORARY TABLE IF EXISTS june_rentals;