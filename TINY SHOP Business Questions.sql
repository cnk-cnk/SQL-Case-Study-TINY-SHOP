-- Q1 Which product has the highest price? Only return a single row?

/*
SELECT product_id, product_name, price FROM products
WHERE Price IN (SELECT MAX(price) FROM products)
*/

-- Q2 Which customer has made the most orders?

/*
WITH cte_a AS 
(
SELECT a.first_name, a.last_name, a.customer_id cust_id_a, COUNT(b.order_id) nb_orders FROM customers a
JOIN orders b ON  a.customer_id= b.customer_id
GROUP BY a.customer_id,  b.customer_id, a.first_name, a.last_name
)

SELECT cust_id_a,first_name, last_name FROM cte_a
WHERE nb_orders IN (SELECT MAX(nb_orders) FROM cte_a)
*/

-- Q3 What’s the total revenue per product?
/*
WITH cte_a AS
(
SELECT a.product_name, a.price, c.order_id, c.product_id, c.quantity, a.price*c.quantity revenue, SUM( a.price*c.quantity) OVER (PARTITION BY c.product_id) total_revenue
FROM products a
JOIN order_items c ON a.product_id = c.product_id
)

SELECT DISTINCT product_id, product_name, total_revenue FROM cte_a

*/

-- Q4 Find the day with the highest revenue
/*
WITH cte_a AS 
(
SELECT a.product_name, a.price, c.order_id, c.product_id, c.quantity, b.order_date, a.price*c.quantity revenue_per_order_id_per_product, SUM( a.price*c.quantity) OVER (PARTITION BY b.order_date) total_revenue_day
FROM products a
JOIN order_items c ON a.product_id = c.product_id
JOIN orders b ON c.order_id = b.order_id
)

SELECT DISTINCT order_date, total_revenue_day FROM cte_a
WHERE total_revenue_day IN (SELECT MAX(total_revenue_day) FROM cte_a)

*/
-- Q5 Find the first order (by date) for each customer
/*
SELECT DISTINCT b.customer_id, MIN (b.order_date) OVER (PARTITION BY b.customer_id) min_order_date_per_customer FROM customers a
JOIN orders  b ON a.customer_id = b.customer_id
ORDER BY b.customer_id
*/

-- Q6 Find the top 3 customers who have ordered the most distinct products
/*
WITH cte_a AS
(
SELECT a.customer_id, b.order_id,c.product_id, d.quantity FROM customers a
JOIN orders b ON a.customer_id=b.customer_id
JOIN order_items d ON b.order_id=d.order_id
JOIN products c ON d.product_id=c.product_id
)


SELECT * INTO cte_c 
FROM (
SELECT customer_id, COUNT (DISTINCT(product_id)) total_distinct_product, SUM(quantity) total_quantity_ordered_per_customer
FROM cte_a 
GROUP BY customer_id
 ) as cte_b


WITH cte_d AS
(
SELECT customer_id, total_distinct_product, total_quantity_ordered_per_customer,
DENSE_RANK () OVER (ORDER BY total_distinct_product DESC ,total_quantity_ordered_per_customer desc) Rank_customer
FROM cte_c
)

SELECT a.first_name, a.last_name, a.customer_id, cte_d.total_distinct_product,cte_d.total_quantity_ordered_per_customer, Rank_customer FROM customers a 
JOIN cte_d  ON cte_d.customer_id = a.customer_id
WHERE Rank_customer  <= 3

*/

-- Second way

/*
WITH cte_a AS
(
SELECT a.customer_id, a.first_name, a.last_name,b.order_id,c.product_id, d.quantity FROM customers a
JOIN orders b ON a.customer_id=b.customer_id
JOIN order_items d ON b.order_id=d.order_id
JOIN products c ON d.product_id=c.product_id
)


SELECT TOP 3 customer_id, first_name, last_name, COUNT (DISTINCT(product_id)) total_distinct_product
FROM cte_a 
GROUP BY customer_id,first_name, last_name
ORDER BY COUNT (DISTINCT(product_id)) desc

*/

--- Q7 Which product has been bought the least in terms of quantity?
/*
WITH cte_a AS
(
SELECT a.order_id, b.product_id, b.product_name, c.quantity,
SUM (c.quantity) OVER (PARTITION BY b.product_id) quantity_per_product
FROM orders a
JOIN order_items c ON c.order_id = a.order_id
JOIN products b ON b.product_id = c.product_id
)

SELECT DISTINCT product_id, product_name, quantity_per_product
FROM cte_a
WHERE quantity_per_product IN (SELECT MIN (quantity_per_product) FROM cte_a)
ORDER BY product_id

*/
--- Q8 What is the median order total?
/*
WITH cte_a AS
(
SELECT DISTINCT a.order_id,
SUM(b.price * c.quantity) OVER (PARTITION BY a.order_id) total_price_per_order
FROM orders a
JOIN order_items c ON c.order_id = a.order_id
JOIN products b ON b.product_id = c.product_id
)

SELECT DISTINCT PERCENTILE_CONT (0.5) WITHIN GROUP  (ORDER BY total_price_per_order) OVER () FROM  cte_a
*/

-- Q9 For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’
/*
SELECT DISTINCT a.order_id,
SUM(b.price * c.quantity) OVER (PARTITION BY a.order_id) total_price_per_order,
CASE 
WHEN SUM(b.price * c.quantity) OVER (PARTITION BY a.order_id) > 300 THEN 'Expensive'
WHEN SUM(b.price * c.quantity) OVER (PARTITION BY a.order_id) > 100 and  SUM(b.price * c.quantity) OVER (PARTITION BY a.order_id) <=300 THEN 'Affordable'
ELSE 'Cheap'
END as Type_of_order
FROM orders a
JOIN order_items c ON c.order_id = a.order_id
JOIN products b ON b.product_id = c.product_id
*/

-- Q10 Find customers who have ordered the product with the highest price.*
/*
WITH cte_a AS
(
SELECT a.customer_id, a.first_name, a.last_name,b.order_id,c.product_id,c.product_name, d.quantity, c.price
FROM customers a
JOIN orders b ON a.customer_id=b.customer_id
JOIN order_items d ON b.order_id=d.order_id
JOIN products c ON d.product_id=c.product_id
)

SELECT customer_id, first_name, last_name, product_name, price FROM cte_a
WHERE price IN ( SELECT MAX (Price) FROM cte_a)
*/