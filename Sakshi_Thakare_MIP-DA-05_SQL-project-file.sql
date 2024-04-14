create database db;
show tables;
select * from products;
select * from customers;
alter table products
change column MyUnknownColumn srno int;

-- 1. How many customers do not have DOB information available?
select COUNT(*) as dob from customers where dob='';

-- 2 HOW MANY CUSTOMER ARE THERE IN EACH PINCODE AND GENDER COMBINATION?
SELECT COUNT(*) as no_of_cust, primary_pincode,gender FROM customers
group by primary_pincode,gender;

-- 3 PRINT PRODUCT NAME AND MRP FOR PRODUCT WHICH HAVE MORE THAN 50000 MRP?
SELECT PRODUCT_NAME,MRP FROM products
WHERE mrp>50000;
-- Analysis - The most costliers products in the product list are laptops from HP241H and DellAX420 as there cost is greater than Rs 50,000.

-- 4 HOW MANY DELIVERY PERSON ARE THERE IN EACH PINCODE?
SELECT COUNT(*) AS DELI_PERSON,pincode
FROM delivery_person
GROUP BY pincode;
-- Analysis - Out of total 6 pincode, pincode- 400001 has maximum number of delivery person 
-- i.e. 4 and pincode- 700001 has second maximum number of delivery person i.e. 2. All other pincodes have only 1 delivery person.

-- 5 For each Pin code, print the count of orders, sum of total amount paid, average amount paid, maximum amount paid, Minimum amount paid for the transactions which were paid by 'cash'. Take only 'buy' order types 
SELECT
    delivery_pincode,
    COUNT(*) AS Order_Count,
    SUM(total_amount_paid) AS total_amount_paid ,
    AVG(total_amount_paid) AS Average_Amount_Paid,
    MAX(total_amount_paid) AS Max_Amount_Paid,
    MIN(total_amount_paid) AS Min_Amount_Paid
FROM orders WHERE
    order_type = 'buy' AND payment_type = 'cash'
GROUP BY
    delivery_pincode;
-- delivery pincode 400001 and count of order 105 and total amount is 11546300 where as pincode 600001 and count of order is 19 
-- and total amount is paid 1456296 which very low and need to work at that particular area pincode 

-- 6. For each delivery_person_id, print the count of orders and total amount paid for product_id = 12350 or 12348 and total units > 8. Sort the output by total amount paid in descending order. Take only 'buy' order types
SELECT
    delivery_person_id,
    COUNT(*) AS Order_Count,
    SUM(total_amount_paid) AS Total_Amount_Paid
FROM
   orders
WHERE
    order_type = 'buy'
    AND (product_id = 12350 OR product_id = 12348)
    AND tot_units > 8
GROUP BY
    delivery_person_id
ORDER BY
    Total_Amount_Paid DESC;
-- Analysis - Delivery person Simon williamswith delivery id - 1000002 has delivered the highest number of order
-- i.e. 10 and the total amount for all the ordered delievered by him is 76801

-- 7.Print the Full names (first name plus last name) for customers that have email on "gmail.com"?
SELECT CONCAT(first_name,' ', last_name) AS Full_Name
FROM customers
WHERE email LIKE '%@gmail.com';
-- Analysis - There are 8 customers whose email on a gmail account.

-- 8.Which pincode has average amount paid more than 150,000? Take only 'buy' order types 
SELECT delivery_pincode
FROM orders
WHERE order_type = 'buy'
GROUP BY delivery_pincode
HAVING AVG(total_amount_paid) > 150000;
-- Analysis - Only one pincode i.e. 110001 (New Delhi) has average paid amount greater than Rs.1,50,000.

-- 9.	Create following columns from order_dim data -  order_date Order day Order month Order year  
SELECT
    order_date,
    DAY(order_date) AS Order_Day,
    MONTH(order_date) AS Order_Month,
    YEAR(order_date) AS Order_Year
FROM
    orders;
    
-- 10.	How many total orders were there in each month and how many of them were returned? Add a column for return rate too. return rate = (100.0 * total return orders) / total buy orders Hint: You will need to combine SUM() with CASE WHEN 
SELECT
    MONTH (order_date) AS Order_Month,
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN order_type = 'Return' THEN 1 ELSE 0 END) AS Total_Returned_Orders,
    (100.0 * SUM(CASE WHEN order_type = 'Returned' THEN 1 ELSE 0 END)) / COUNT(*) AS Return_Rate
FROM
    orders
GROUP BY
    MONTH (order_date)
ORDER BY
    Order_Month;
-- Analysis - we have maximum number of orders which is 1050 and total returned order in this month is 50. 
-- We can say the return rate of orders in each month is very low, as no.of orders returned is very less compared to the order purchased. 

-- 11.	How many units have been sold by each brand? Also get total returned units for each brand. 
SELECT
    Brand,
    SUM(CASE WHEN Order_Type = 'buy' THEN 1 ELSE 0 END) AS Total_Units_Sold,
    SUM(CASE WHEN Order_Type = 'return' THEN 1 ELSE 0 END) AS Total_Units_Returned
FROM orders as O
left join 
   products as P on O.product_id=P.srno
GROUP BY Brand;
-- Analysis - There are 2 brands HP and Dell. 
-- Dell has sold a total of 502 units out of which 21 units were returned. 
-- HP has sold a total of 498 units out of which 29 units were returned.

-- 12.	How many distinct customers and delivery boys are there in each state? 
SELECT
    p.State,
    COUNT(DISTINCT C.Cust_ID) AS Distinct_Customers,
    COUNT(DISTINCT DB.delivery_person_id) AS Distinct_DeliveryBoys
FROM
    customers AS C
join pincode as p on c.primary_pincode=p.pincode
join delivery_person as db on p.pincode=db.pincode   
GROUP BY p.State;

-- 13.	For every customer, print how many total units were ordered, how many units were ordered from their primary_pincode and 
-- how many were ordered not from the primary_pincode. Also calulate the percentage of total units which were ordered from 
-- primary_pincode(remember to multiply the numerator by 100.0). Sort by the percentage column in descending order. 
SELECT
    c.cust_id,
    SUM(o.tot_units) AS Total_Units_Ordered,
    SUM(CASE WHEN c.primary_pincode = o.delivery_pincode THEN o.tot_units ELSE 0 END) AS Units_From_Primary,
    SUM(CASE WHEN c.primary_pincode <> o.delivery_pincode THEN o.tot_units ELSE 0 END) AS Units_Not_From_Primary,
    (100.0 * SUM(CASE WHEN c.primary_pincode = o.delivery_pincode THEN o.tot_units ELSE 0 END)) / SUM(o.tot_units) AS Percentage
FROM customers AS c
JOIN orders AS o
ON c.cust_id = o.cust_id
GROUP BY c.cust_id
ORDER BY Percentage DESC;

-- 14.	For each product name, print the sum of number of units, total amount paid, 
-- total displayed selling price, total mrp of these units, and finally the net discount from selling price.  
-- (i.e. 100.0 - 100.0 * total amount paid / total displayed selling price) &  the net discount from mrp (i.e. 100.0 - 100.0 * total amount paid / total mrp) 
SELECT
    p.product_name,
    SUM(o.tot_units) AS Total_Units,
    SUM(o.total_amount_paid) AS Total_Amount_Paid,
    SUM(o.displayed_selling_price_per_unit) AS Total_Displayed_Selling_Price,
    SUM(p.mrp) AS Total_MRP,
    100.0 - (100.0 * SUM(o.total_amount_paid) / SUM(o.displayed_selling_price_per_unit)) AS Net_Discount_From_Selling_Price,
    100.0 - (100.0 * SUM(o.total_amount_paid) / SUM(p.mrp)) AS Net_Discount_From_MRP
FROM products AS p
JOIN orders AS o
ON p.srno = o.product_id
GROUP BY
    p.product_name;
select*from orders;

-- 15.	For every order_id (exclude returns), get the product name and calculate the discount percentage from selling price. Sort by 
-- highest discount and print only those rows where discount percentage was above 10.10%. 

SELECT
    o.order_id,
    p.product_name,
    ((p.mrp - o.displayed_selling_price_per_unit) *100/ p.mrp) AS Discount_Percentage
FROM
    orders AS o
INNER JOIN
    products AS p ON  p.srno= o.product_id
WHERE
    o.order_type != 'return' and 
	((p.mrp - o.displayed_selling_price_per_unit) *100/ p.mrp) > 10.10
ORDER BY
    Discount_Percentage DESC;

-- 16.	Using the per unit procurement cost in product_dim, find which product category has made 
-- the most profit in both absolute amount and percentage Absolute Profit = Total Amt Sold - Total Procurement Cost 
-- Percentage Profit = 100.0 * Total Amt Sold / Total Procurement Cost - 100.0 
SELECT
    p.category,
    SUM(s.total_amount_paid - p.procurement_cost_per_unit * s.tot_units) AS Absolute_Profit,
    (100.0 * SUM(s.total_amount_paid)) / (SUM(p.procurement_cost_per_unit * s.tot_units)) - 100.0 AS Percentage_Profit
FROM products AS p
JOIN orders AS s
ON p.srno= s.product_id
GROUP BY p.category
ORDER BY Absolute_Profit DESC, Percentage_Profit DESC;
-- Analysis - Percentage wise pendrive has made the highest profit as the profit percent is highest for it.
-- In case of absolute profit, it is laptop that has made the highest profit.

-- 17. For every delivery person (use their name), print the total number of order ids (exclude returns) by month in separate columns  i.e., there should be one row for each delivery_person_id and 12 columns for every month in the year 
select delivery_person.name as delivery_person_name, 
monthname(str_to_date(o.order_date,'%d-%m-%y')) as order_month,
count(o.order_id) as total_orders from delivery_person
left join orders o on delivery_person.delivery_person_id = o.delivery_person_id 
where o.order_type = 'buy' group by delivery_person.name, order_month;

-- 18.	For each gender - male and female - find the absolute and percentage profit (like in Q15) by product name
SELECT
    p.product_name,
    SUM(s.total_amount_paid - p.procurement_cost_per_unit * s.tot_units) AS Absolute_Profit,
    (100.0 * SUM(s.total_amount_paid)) / (SUM(p.procurement_cost_per_unit * s.tot_units)) - 100.0 AS Percentage_Profit
FROM
    products AS p
JOIN
    orders AS s
ON
    p.srno = s.product_id
GROUP BY
    p.product_name;
 -- Analysis - For small products like - pendrive and mouse, profit is in boom i.e more than 100% and 
 -- Dell brand have more profit percentage than HP brand.

-- 19.	Generally the more numbers of units you buy, the more discount seller will give you. 
-- For 'Dell AX420' is there a relationship between number of units ordered and average discount from selling price? Take only 'buy' order types 
SELECT
    o.tot_units,
    AVG(100- (100.0 * total_amount_paid/(tot_units*displayed_selling_price_per_unit) )) AS Average_Discount_Percentage
FROM orders as o
JOIN products AS p
ON o.product_id = p.srno
WHERE product_name = 'Dell AX420' AND o.order_type = 'Buy'
GROUP BY tot_units
ORDER BY
    tot_units ;
 -- as per queStion discount percent is very frequent because no of orders by order id / person are
 -- and discount percent also increasing by one percent  
