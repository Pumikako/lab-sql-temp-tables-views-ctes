USE sakila;

-- Step 1: Create a rental summary view
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Step 2: Create a customer payment temporary table
DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
    rs.customer_id,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM customer_rental_summary AS rs
LEFT JOIN payment AS p
    ON rs.customer_id = p.customer_id
GROUP BY rs.customer_id;

-- Step 3: Create a CTE and generate the final report
WITH customer_summary AS (
    SELECT
        rs.customer_name,
        rs.email,
        rs.rental_count,
        ps.total_paid
    FROM customer_rental_summary AS rs
    JOIN customer_payment_summary AS ps
        ON rs.customer_id = ps.customer_id
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / NULLIF(rental_count, 0), 2)
        AS average_payment_per_rental
FROM customer_summary
ORDER BY customer_name;