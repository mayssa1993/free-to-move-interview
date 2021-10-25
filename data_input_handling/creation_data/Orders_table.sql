drop table if exists Orders ;
create table if not exists Orders
(
order_id VARCHAR(32) not null primary key , 	
customer_id	VARCHAR(32),
order_status VARCHAR (30), 	
order_purchase_timestamp	TIMESTAMP,
order_approved_at	TIMESTAMP,
order_delivered_carrier_date TIMESTAMP,	
order_delivered_customer_date TIMESTAMP,
order_estimated_delivery_date TIMESTAMP	
);


select count(*) from Orders ;
--99441
select count(distinct order_id) from Orders ; 
--99441 ==> Unicité vérifié de la clé primaire 

