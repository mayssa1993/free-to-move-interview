--Question 1 : 
--This question is answered with an ETL loader 


--Question 2 : 
-- Customer Vision 
-- Top customers are cutomers making several orders >1
-- In order to get the Top ones we sort data by order desc 
-- We can than filter by the nature of order, we consider top ones those having purshaced and been delivered 
drop table if exists top_customer ;
create table if not exists top_customer  as 
    select * from (
        select customer_unique_id,order_status, count(order_id) a
        from Orders 
        inner join customer c
        on c.customer_id = Orders.customer_id
        where order_status = "delivered"
    group by customer_unique_id
    having a > 1
    order by  a desc ); 

---- Export result into CSV file: 
---------------------------------------------------------

---------------------------------------------------------
--Question 3 :  
-- Repeaters customers are customers who had at least purshaced twice in the website 
select count(*) from 
    (select customer_unique_id,order_status, count(order_id) a
        from Orders 
        inner join customer c
        on c.customer_id = Orders.customer_id
        where order_status not in ("canceled","unavailable")
    group by customer_unique_id
    having a > 1 ) ; --2889 

--Customers who have purshaed one or more in the website 
select count(*) from 
    (select customer_unique_id,order_status, count(order_id) a
        from Orders 
        inner join customer c
        on c.customer_id = Orders.customer_id
    --where order_status not in ("canceled","unavailable")
    group by customer_unique_id
    having a >= 1 ) ; --94991
--Customer retention rate : 
-- repeaters customers/ Paying customers 
--- 3% of customers are repeaters 

--- Sales Part : 
--Question1 : 

drop table if exists customer_life_value;
create table if not exists  customer_life_value as 
select *
 from 
Customer 
inner join 
(   select * 
    from
    (
    SELECT * from 
    (select * from Orders 
    inner join 
    Items 
    on Orders.order_id=Items.order_id) as t1
    inner join 
    Product 
    on t1.product_id = Product.product_id)) as t2
    on Customer.customer_id = t2.customer_id ; 


--- Question 1 : 
--- Mean Basket by product category : 
--First reflexion : 
--Totalsales/total orders by product category 
drop table if exists Mean_basket_by_product;
create table if not exists Mean_basket_by_product as 
select * from (
    select product_category_name ,nb_basket,somme_price ,round (somme_price/nb_basket)  as mean_price_basket
    from 
    (select product_category_name , count(distinct order_id) nb_basket , sum(price) somme_price
    from customer_life_value
    where order_status not in ("canceled","unavailable")
    group by product_category_name )
    order by mean_price_basket desc ); 

--Other reflexion : 
--Total orders/all_orders over table by product category 
select product_category_name, count(distinct order_id) nb_basket,
    count(distinct order_id)*100/(select count(distinct order_id) from customer_life_value) as nb_total_basket 
    from customer_life_value
    where order_status not in ("canceled","unavailable")
    group by product_category_name
    order by nb_basket desc;

--Question 2
---Best selling product are the most popular : 
--  Most popular product : 
-- Périod of study : All hitory data from 2016 to 2020
drop table if exists top_product ;
create table if not exists top_product
as 
select* from 
    (select product_id, count(*) Total_sales,round(sum(price)) Total_revenue, 
    count(distinct customer_unique_id) nb_customer_purshasing 
    from
    customer_life_value
    where   order_status not in ("canceled","unavailable")
    group by product_id
    order by  nb_customer_purshasing   desc );

--- Yearly most popular  products 

--- cheking if there in anomalies in the order_purchase_timestamp

select distinct strftime('%Y',date(order_purchase_timestamp)) as Year
from customer_life_value ; 
--Existing of two date_value with 0000 and 2077 
-- Really funny we are just in 2021
--okey some of data preprocessing before :D 
select distinct strftime('%Y',date(shipping_limit_date)) as Year
from customer_life_value ; 
--No anomalies in shipping_limite_date 
--Solution : Imputing Year of order_purchase_timestamp with Year of shipping_limite_date (The only column with reasnobale values :D)
Update customer_life_value
set  
    order_purchase_timestamp=(case when strftime('%Y',date(order_purchase_timestamp)) in ("0000","2077")
    then REPLACE(order_purchase_timestamp,strftime('%Y',date(order_purchase_timestamp)),strftime('%Y',date(shipping_limit_date)) )
    else order_purchase_timestamp END);

--Check
select distinct strftime('%Y',date(order_purchase_timestamp)) as Year
from customer_life_value ; 

---------------------------------------
--Yearly Top products : 
drop table if exists top_Yearly_product ;
create table if not exists top_Yearly_product
as
select * from 
    (select product_id, strftime('%Y',date(order_purchase_timestamp)) as Year,
    count(*) Total_sales,round(sum(price)) Total_revenue, 
    count(distinct customer_unique_id) nb_customer_purshasing 
    from
    customer_life_value
    where  order_status not in ("canceled","unavailable")
    group by product_id,Year
    order by nb_customer_purshasing desc); 

---Quartly most popular products 

--To do cast shipping_limit_date to approval_delivery_date
drop table if exists Top_Quartly_product ; 
create table if not exists Top_Quartly_product
as
select * from 
    (select product_id, strftime('%Y',date(order_purchase_timestamp)) as Year,
    floor( (strftime('%m',customer_life_value.shipping_limit_date) + 2) / 3 ) as quarter,count(*) Total_sales,
    round(sum(price)) Total_revenue, count(distinct customer_unique_id) nb_customer_purshasing 
    from
    customer_life_value
    where  order_status not in ("canceled","unavailable")
    group by product_id,Year,quarter
    order by nb_customer_purshasing desc); 

--Question 4 : 
-- Popular product bought by repeated customers 
drop table if exists Popular_product_repeaters ;
create  table if not exists Popular_product_repeaters as 
with 
repeated_customers 
    as 
    (select customer_unique_id, count(order_id) occ
    from Orders 
    inner join customer c
    on c.customer_id = Orders.customer_id
    where order_status not in ("canceled","unavailable")
    group by customer_unique_id
    having occ > 1),
Popular_products_repeaters
    as 
    (select t.customer_unique_id,t.product_id,product_category_name,count(*) nb_achat
    from 
    (select * from customer_life_value
    inner join repeated_customers 
    on repeated_customers.customer_unique_id=customer_life_value.customer_unique_id) as t
    group by t.customer_unique_id,t.product_id)
    select customer_unique_id,product_id,product_category_name,max(nb_achat)
     from Popular_products_repeaters
     group by customer_unique_id
     order by nb_achat desc;




-----Customer segmentation 
drop table if exists customer_segmentation ; 
create table if not exists customer_segmentation as
select * from 
(
    select customer_unique_id,customer_zip_code_prefix,customer_city,customer_state,order_purchase_timestamp,order_id,order_status,
    count(*)quantity_Item,sum(price) basket_price,sum(freight_value) basket_freight_value
    from customer_life_value
    group by customer_unique_id,order_purchase_timestamp
    order by count(*) desc);
