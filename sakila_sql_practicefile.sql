USE sakila;
-- Show customer first name, last name, and rental date 
SELECT 
	c.customer_id,
    c.first_name,
    c.last_name,
	r.rental_date
FROM customer c
INNER JOIN rental r 
ON  c.customer_id = r.customer_id
ORDER BY r.rental_date ASC;

-- Left join
-- Show ALL customers and their rental_id (Even customers who never rented)
SELECT 
	c.first_name,
    c.last_name,
    r.rental_id
FROM 
	customer c 
LEFT JOIN
	rental r
ON c.customer_id = r.customer_id;

-- how to confirm its correct
SELECT COUNT(*) FROM customer;
SELECT COUNT(DISTINCT customer_id) FROM rental;

-- “The LEFT JOIN is correct, but the dataset has no customers without rentals, so no NULLs appear.”
SELECT 
	c.first_name,
    c.last_name,
    r.rental_id
FROM 
	customer c 
LEFT JOIN
	rental r
ON c.customer_id = r.customer_id;

-- Find customers who have rented LESS THAN 20 times/ becoming inactive
    SELECT 
	c.first_name,
    c.last_name,
    c.customer_id,
    COUNT(r.rental_id) AS rental_numbers
FROM 
	customer c 
LEFT JOIN
	rental r
ON c.customer_id = r.customer_id
GROUP BY 
	first_name,
    last_name,
	c.customer_id
HAVING COUNT(r.rental_id) < 20
ORDER BY rental_numbers ASC;

-- if we add or delete customers left join wont break/ its future proof 
INSERT INTO customer (
    customer_id, store_id, first_name, last_name,
    address_id, active, create_date
)
VALUES (9999, 1, 'Demo', 'Customer', 1, 1, CURRENT_DATE);

DELETE FROM customer WHERE customer_id = 9999;

-- Which movies are most popular
SELECT 
	title,
    COUNT(r.rental_id) AS total_rentals
FROM 
	film f
JOIN 
	inventory i 
ON 
	f.film_id = i.film_id
JOIN  
	rental r
ON
	i.inventory_id = r.inventory_id
GROUP BY 
	f.title
ORDER BY total_rentals DESC;
    
 -- How much revenue did highest rented film generate?   
    SELECT 
	title,
    SUM(p.amount) as bb_sum
FROM 
	film f
JOIN 
	inventory i 
ON 
	f.film_id = i.film_id
JOIN  
	rental r
ON
	i.inventory_id = r.inventory_id
JOIN 
	payment p 
ON 
	p.rental_id = r.rental_id
WHERE 
	f.title = 'BUCKET BROTHERHOOD'
GROUP BY 
	f.title;

-- “Bucket Brotherhood is the most rented film and also generates the highest total revenue, 
-- confirming both high demand and strong monetization.”

USE sakila;

-- Show the top 5 customers by total revenue
SELECT 
	c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_amt
FROM 
	customer c
JOIN 
	payment p
ON
	c.customer_id = p.customer_id
GROUP BY customer_id
ORDER BY total_amt DESC
LIMIT 5;

-- Rank all films based on rental_rate. If two films have the same rate, they should get the same rank.
SELECT 
	title,
    rating,
    rental_rate,
RANK() OVER(
PARTITION BY rating
ORDER BY rental_rate DESC
) AS rnk_pr
FROM 
	film ;

SELECT *
FROM (
SELECT 
	title,
    rating,
    rental_rate,
RANK() OVER(
PARTITION BY rating
ORDER BY rental_rate DESC
) AS rnk_pr
FROM 
	film
    ) r
WHERE rnk_pr <=3;

-- Show each payment along with a row number per customer (latest payment = 1)
SELECT 
	payment_id,
	customer_id,
    amount,
    payment_date,
ROW_NUMBER() OVER(
PARTITION BY customer_id 
ORDER BY payment_date  DESC
) AS last_payment
FROM payment;

-- Rank customers based on their total payment amount.
SELECT 
	customer_id,
    total_amount,
RANK() OVER( ORDER BY  total_amount DESC) AS customer_rank
FROM (
SELECT 
	customer_id,
    SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id
) t ;
