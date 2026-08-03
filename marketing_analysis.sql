USE marketing_analysis;

# Get the time range between which the orders were placed
SELECT MIN(order_purchase_timestamp) AS start_time, MAX(order_purchase_timestamp) AS end_time
FROM orders;

# Count the Cities & States of customers who ordered between January and June 2017
SELECT COUNT(DISTINCT c.customer_city) AS no_of_cities, COUNT(DISTINCT c.customer_state) AS no_of_states
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
WHERE order_purchase_timestamp BETWEEN "2017-01-01" AND "2017-07-01"; #july 1st(exclusive)

# Is there a growing trend in the no. of orders placed over the past years? 
SELECT YEAR(order_purchase_timestamp) AS year, COUNT(order_id) AS no_of_orders
FROM orders
GROUP BY year 
ORDER BY no_of_orders DESC;

# Can we see some kind of monthly seasonality in terms of the no. of orders being placed? 
SELECT MONTH(order_purchase_timestamp) AS month, COUNT(order_id) AS no_of_orders
FROM orders
GROUP BY month 
ORDER BY no_of_orders DESC;

# During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night) 
SELECT time_of_day, COUNT(order_id)
FROM orders
GROUP BY time_of_day
ORDER BY COUNT(order_id) DESC;

# Get the month on month no. of orders placed in each state
SELECT c.customer_state AS state, YEAR(o.order_purchase_timestamp) AS year, MONTH(o.order_purchase_timestamp) AS month, COUNT(o.order_id) AS no_of_orders
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY state, year, month
ORDER BY state, year, month;

# How are the customers distributed across all the states?
SELECT customer_state AS state, COUNT(customer_unique_id) AS no_of_customers
FROM customers
GROUP BY state
ORDER BY no_of_customers DESC;

#  Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only)
WITH yearly_costs AS (
	SELECT YEAR(order_purchase_timestamp) AS year,
    SUM(payment_value) AS cost
    FROM orders o
    JOIN payments p
    ON o.order_id = p.order_id
    WHERE YEAR(order_purchase_timestamp) IN (2017,2018) AND
    MONTH(order_purchase_timestamp) BETWEEN 1 AND 8
    GROUP BY year
),
cost2 AS(
	SELECT year, cost,
    LEAD(cost) OVER(ORDER BY year) AS next_year_cost
    FROM yearly_costs
)
SELECT ROUND(((next_year_cost-cost)/cost)*100,2) AS percent_increase
FROM cost2
WHERE next_year_cost IS NOT NULL;

# Calculate the Total & Average value of order price for each state
SELECT customer_state AS state, ROUND(SUM(price),2) AS total_value, ROUND(AVG(price),2) AS avg_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items ot
ON o.order_id = ot.order_id
GROUP BY state
ORDER BY total_value DESC;

# Calculate the Total & Average value of order freight for each state. 
SELECT customer_state AS state, ROUND(SUM(freight_value),2) AS total_value, ROUND(AVG(freight_value),2) AS avg_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items ot
ON o.order_id = ot.order_id
GROUP BY state
ORDER BY total_value DESC;

/* Find the no. of days taken to deliver each order from the order’s purchase date as delivery time. 
Also, calculate the difference (in days) between the estimated & actual delivery date of an order. */
SELECT order_id, delivery_time_days, delivery_delay_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

# Find out the top 5 states with the highest & lowest average freight value
WITH loc AS (
	SELECT customer_state AS state, ROUND(AVG(freight_value),2) AS avg_freight
	FROM order_items AS ot
	JOIN orders AS o
	ON ot.order_id = o.order_id
	JOIN customers c
	ON o.customer_id = c.customer_id
	GROUP BY state
)
(
	SELECT "Highest" AS category, state, avg_freight
	FROM loc
	ORDER BY avg_freight DESC
	LIMIT 5
)
UNION
(
	SELECT "Lowest" AS category, state, avg_freight
	FROM loc
	ORDER BY avg_freight ASC
	LIMIT 5
);

# Find out the top 5 states with the highest & lowest average delivery time
WITH loc AS (
	SELECT customer_state AS state, ROUND(AVG(delivery_time_days),2) AS avg_delivery
    FROM orders AS o
    JOIN customers AS c
    ON o.customer_id = c.customer_id
    GROUP BY state
)
(
	SELECT "Highest" AS category, state, avg_delivery
    FROM loc
    ORDER BY avg_delivery DESC
    LIMIT 5
)
UNION
(
	SELECT "Lowest" AS category, state, avg_delivery
    FROM loc
    ORDER BY avg_delivery ASC
    LIMIT 5
);

# Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery
SELECT customer_state AS state, ROUND(AVG(delivery_delay_days),2) AS no_of_days
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
GROUP BY state
ORDER BY no_of_days ASC
LIMIT 5;

# Find the month on month no. of orders placed using different payment types
SELECT payment_type, YEAR(order_purchase_timestamp) AS year, MONTH(order_purchase_timestamp) AS month, COUNT(o.order_id) AS no_of_orders
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY year, month, payment_type
ORDER BY year, month;

# Find the no. of orders placed on the basis of the payment installments that have been paid
SELECT payment_installments, COUNT(DISTINCT order_id) AS no_of_orders
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments ASC;

# Which product categories contribute the most to the company's total sales revenue?
SELECT product_category, ROUND(SUM(total_item_cost),2) AS revenue
FROM products AS p
JOIN order_items AS ot
ON p.product_id = ot.product_id
GROUP BY product_category
ORDER BY revenue DESC
LIMIT 10;

# Which sellers generate the highest revenue, and how are they distributed across different states?
SELECT s.seller_id AS seller, seller_state AS state, ROUND(SUM(price),2) AS revenue
FROM sellers s
JOIN order_items ot
ON s.seller_id = ot.seller_id
GROUP BY s.seller_id, s.seller_state
ORDER BY revenue DESC
LIMIT 10;

# How has the company's monthly revenue changed over time?
SELECT YEAR(order_purchase_timestamp) AS year, MONTH(order_purchase_timestamp) AS month, ROUND(SUM(payment_value),2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY year, month
ORDER BY year, month;

# What percentage of delivered orders arrived later than the estimated delivery date?
SELECT (SUM(CASE WHEN delivery_delay_days>0 THEN 1 ELSE 0 END)/COUNT(delivery_delay_days))*100 AS late_delivery_percent
FROM orders
WHERE delivery_delay_days IS NOT NULL;

# Which states have the highest and lowest levels of customer satisfaction based on review ratings?
WITH avg_review AS (
	SELECT customer_state AS state, ROUND(AVG(review_score),1) AS avg_rating
    FROM order_reviews orr
    JOIN orders o
    ON orr.order_id = o.order_id
    JOIN customers c
    ON o.customer_id = c.customer_id
    GROUP BY state
)
(
	SELECT "Highest" AS category, state, avg_rating
    FROM avg_review
    ORDER BY avg_rating DESC
    LIMIT 5
)
UNION
(
	SELECT "Lowest" AS category, state, avg_rating
    FROM avg_review
    ORDER BY avg_rating ASC
    LIMIT 5
);

# Does the choice of payment method influence customer satisfaction?
SELECT payment_type, AVG(review_score) AS avg_review
FROM payments p
JOIN order_reviews orr
ON p.order_id = orr.order_id
GROUP BY payment_type
ORDER BY avg_review DESC;

# What proportion of orders fall under each order status, such as delivered, canceled, unavailable, or shipped?
SELECT order_status, COUNT(order_id) AS total_orders, ROUND((COUNT(order_id) / (SELECT COUNT(*) FROM orders))*100, 2) AS percentage
FROM orders
GROUP BY order_status;

# What is the average monetary value of an order across all customer purchases?
SELECT ROUND(AVG(order_total),2)
FROM
(
	SELECT order_id,
	SUM(payment_value) AS order_total
	FROM payments
	GROUP BY order_id
) t;

# Who are the company's most valuable customers based on their total spending?
SELECT customer_unique_id, SUM(payment_value) AS total_spending
FROM orders o
JOIN payments p
ON p.order_id = o.order_id
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY customer_unique_id
ORDER BY total_spending DESC
LIMIT 10;

# Which product categories require the longest and shortest delivery times after purchase?
WITH prod_cat AS (
	SELECT product_category, ROUND(AVG(delivery_time_days),2) AS del_time
	FROM products p
	JOIN order_items oi
	ON p.product_id = oi.product_id
	JOIN orders o
	ON o.order_id = oi.order_id
    WHERE o.delivery_time_days IS NOT NULL
	GROUP BY product_category
)
(
	SELECT "Highest" AS category, product_category, del_time
    FROM prod_cat
    ORDER BY del_time DESC
    LIMIT 5
)
UNION ALL
(
	SELECT "Lowest" AS category, product_category, del_time
    FROM prod_cat
    ORDER BY del_time ASC
    LIMIT 5
);

# Which product categories incur the highest average shipping costs?
SELECT product_category, ROUND(AVG(freight_value),2) AS avg_shipping_cost
FROM products AS p
JOIN order_items AS ot
ON p.product_id = ot.product_id
GROUP BY product_category
ORDER BY avg_shipping_cost DESC
LIMIT 10;