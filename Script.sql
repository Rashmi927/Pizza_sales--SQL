create database pizza_DB;
use pizza_DB;


create table orders(
order_id int not null, order_date date not null,  order_time time not null, primary key(order_id) 
);

load data infile 'D:/Pizza_sql/orders.csv'
into table orders
fields terminated by ','
ENCLOSED BY '"'
lines terminated by '\r\n'
ignore 1 rows;

drop table order_details;

create table order_details(
order_details_id int not null, order_id int not null, pizza_id varchar(55) not null,  quantity int, primary key(order_details_id) 
);
load data infile 'D:/Pizza_sql/order_details.csv'
into table order_details
fields terminated by ','
ENCLOSED BY '"'
lines terminated by '\r\n'
ignore 1 rows;

select * from orders;
select * from order_details;
select * from pizzas;
select * from pizza_types;

-- Retrieve the total number of orders placed.
select * from orders;
select count(*) Total_orders from orders;
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Revenue
FROM
    order_details o
        JOIN
    pizzas p ON p.pizza_id = o.pizza_id;
    
    
-- Identify the highest-priced pizza.
select * from pizzas;
select * from pizza_types;
select distinct pizza_id, price from pizzas;

SELECT DISTINCT
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered
use pizza_db; 
SELECT 
    p.size, COUNT(od.quantity) AS common_ord_size
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY common_ord_size DESC;
-- ---------------------------------------------------
-- List the top 5 most ordered pizza types along with their quantities;

SELECT 
    pt.name, COUNT(od.quantity) AS qty_by_pizza
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    Pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY qty_by_pizza DESC
LIMIT 5
;
-- ---------------------------------------------
-- Intermediate
-- Join the necessary tables to find the total quantity of each pizza category ordered
SELECT DISTINCT
    pt.category, COUNT(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY quantity DESC
;

-- -------------------------------------------

-- Determine the distribution of orders by hour of the day

select hour(order_time) hr ,count(order_id) orders from orders group by hr order by  orders desc;
-- -----------------------------

-- Join relevant tables to find the category-wise distribution of pizzas
select distinct category, count(name) from pizza_types group by category;

-- -------------------------
-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        COUNT(o.order_id),
            SUM(od.quantity) AS quantity,
            o.order_date
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date) qty;

-- ------------------------------
-- Determine the top 3 most ordered pizza types based on revenue
SELECT DISTINCT
    pt.name,
    p.pizza_type_id,
    SUM(od.quantity * p.price) AS revenu
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenu DESC
LIMIT 3
;
-- ----------------------------------------------
-- Advanced
-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(o.quantity * p.price), 2) rvn
                FROM
                    order_details o
                        JOIN
                    pizzas p ON p.pizza_id = o.pizza_id)) * 100,
            2) AS revenue
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC
;

-- ----------------------------------------------
-- Analyze the cumulative revenue generated over time

select order_date, sum(revenue) over(order by order_date) as cum_revenue from 
(SELECT 
    o.order_date,
    ROUND(SUM(p.price * od.quantity), 2) AS revenue
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY o.order_date)as sales;
 -- --------------------------------------
select * from orders;
select * from order_details;
select * from pizzas;
select * from pizza_types;
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

select name, revenue from 
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pt.category, pt.name,
SUM(od.quantity*p.price) as revenue
 from pizza_types pt
 JOIN pizzas p
 ON pt.pizza_type_id=p.pizza_type_id
 JOIN order_details od
 ON od.pizza_id=p.pizza_id
 group by pt.category,pt.name) as a ) as b
 where rn <=3
 ;
-- ----------------------------------------




