drop table if exists Product ;
create table if not exists Product
(
product_id  VARCHAR(32) Not null primary key,
product_category_name VARCHAR(255),
product_name_lenght Float,
product_description_lenght Float,
product_photos_qty Float,
product_weight_g,product_length_cm Float,
product_height_cm Float,
product_width_cm Float,
product_category_name_english VARCHAR(255) );

select * from Product ; 