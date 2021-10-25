drop table if exists Items ;
create table if not exists Items
(
order_id VARCHAR(32) not null, 	
order_item_id VARCHAR(32) not null, 
product_id VARCHAR(32) not null, 	
seller_id VARCHAR(32) not null, 	
shipping_limit_date TIMESTAMP ,	
price	Float,
freight_valueFloat);

select * from Customer ;
select * from Customer
where customer_id in
 (select t1.customer_id from 
    (select customer_id,count(*)
    from Customer
    group by customer_id
    having count(*) >1 ) as t1 ); 