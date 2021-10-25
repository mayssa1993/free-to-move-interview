drop table if exists Customer ;
create table if not exists Customer 
(
customer_id VARCHAR(32),
customer_unique_id  VARCHAR(32),
customer_zip_code_prefix VARCHAR(5),
customer_city VARCHAR(255),
customer_state VARCHAR(2)
);

--Data quality for injestion : 

--check the unicity of column customer_id and customer_unique_id
select count(*) from Customer ;
--99443
select count(distinct customer_id) from Customer ; 
--99441
select count(distinct customer_unique_id) from Customer ; 
--96096
-- Customer id and customer_unique_id are not unique 
--Check for the duplicated value in both columns 

select * from Customer
where customer_id in
     (select t1.customer_id from 
        (select customer_id,count(*)
        from Customer
        group by customer_id
        having count(*) >1 ) as t1 ); 
-- 2 customer_id having the same rows with nulls value
-- select only customer with full records 

delete from Customer 
where 
(
customer_id in 
        (select t1.customer_id from 
        (select customer_id,count(*)
        from Customer
        group by customer_id
        having count(*) >1 ) as t1 )
and customer_city is null );

    
--Customer_unique_id : 
select count(*) from 
(select customer_unique_id, count(distinct Customer_id) as nb from 
Customer 
group by customer_unique_id
having nb > 1);
--2997 customer_unique_id having more than one customer id 
--customer_unique_id is aggregating customer_id 
--96354 unique records 
-- Customer_I identifiant du customer vis a vis au achat 
--customer_unique_id est l'identifiant direct du customer



