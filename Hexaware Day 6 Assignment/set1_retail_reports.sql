create database if not exists retail_db;
use retail_db;

drop table if exists order_items, payments, orders, products, customers;

create table customers (
  cust_id int primary key,
  name varchar(50) not null,
  city varchar(30)
);

create table products (
  prod_id int primary key,
  pname varchar(50) not null,
  category varchar(30),
  price decimal(10,2) check (price > 0)
);

create table orders (
  order_id int primary key,
  cust_id int,
  order_date date,
  foreign key (cust_id) references customers(cust_id)
);

create table order_items (
  order_id int,
  prod_id int,
  qty int,
  foreign key (order_id) references orders(order_id),
  foreign key (prod_id) references products(prod_id)
);

create table payments (
  pay_id int primary key,
  order_id int,
  amount decimal(10,2),
  foreign key (order_id) references orders(order_id)
);

insert into customers values
(1,'arun','chennai'),(2,'priya','bangalore'),(3,'kiran','chennai'),
(4,'meena','mumbai'),(5,'ravi',null);

insert into products values
(101,'laptop','electronics',50000),(102,'mouse','electronics',500),
(103,'shirt','clothing',1200),(104,'shoes','clothing',2500),
(105,'rice bag','grocery',900),(106,'oil','grocery',200);

insert into orders values
(1,1,'2026-01-05'),(2,1,'2026-01-20'),(3,1,'2026-02-02'),(4,1,'2026-02-15'),
(5,2,'2026-01-20'),(6,3,'2026-02-15'),(7,4,'2026-02-15');

insert into order_items values
(1,101,1),(1,102,2),(2,103,2),(3,105,3),(4,106,5),
(5,104,1),(5,102,1),(6,103,1),(7,101,1);

insert into payments values
(1,1,51000),(2,2,2400),(3,3,null),(5,5,3000),(6,6,1200);

select p.pname, sum(oi.qty * p.price) as revenue
from order_items oi
join products p on oi.prod_id = p.prod_id
group by p.pname
order by revenue desc
limit 5;

select date_format(o.order_date, '%b-%Y') as month, sum(oi.qty * p.price) as total_sales
from orders o
join order_items oi on o.order_id = oi.order_id
join products p on oi.prod_id = p.prod_id
group by month
order by min(o.order_date);

select c.name, count(o.order_id) as total_orders
from customers c
join orders o on c.cust_id = o.cust_id
group by c.name
having count(o.order_id) > 3;

select c.city, round(avg(t.basket), 2) as avg_basket
from customers c
join (
  select o.order_id, o.cust_id, sum(oi.qty * p.price) as basket
  from orders o
  join order_items oi on o.order_id = oi.order_id
  join products p on oi.prod_id = p.prod_id
  group by o.order_id, o.cust_id
) t on c.cust_id = t.cust_id
group by c.city;

select o.order_id, o.order_date
from orders o
left join payments pm on o.order_id = pm.order_id
where pm.pay_id is null;

select c.cust_id, c.name
from customers c
left join orders o on c.cust_id = o.cust_id
where o.order_id is null;

select p.category, sum(oi.qty * p.price) as revenue,
round(sum(oi.qty * p.price) * 100 / (select sum(oi2.qty * p2.price)
  from order_items oi2 join products p2 on oi2.prod_id = p2.prod_id), 2) as share_pct
from order_items oi
join products p on oi.prod_id = p.prod_id
group by p.category
order by revenue desc;

select o.order_date, sum(oi.qty * p.price) as day_sales
from orders o
join order_items oi on o.order_id = oi.order_id
join products p on oi.prod_id = p.prod_id
group by o.order_date
order by day_sales desc
limit 1;

select upper(c.name) as customer,
concat(upper(c.name), ' from ', ifnull(c.city, 'unknown')) as details,
date_format(o.order_date, '%d %M %Y') as ordered_on,
datediff('2026-03-01', o.order_date) as days_ago
from customers c
join orders o on c.cust_id = o.cust_id;

select p.pname, concat('Rs. ', round(p.price * 1.18, 2)) as price_with_gst
from products p;

select count(*) as all_rows, count(amount) as paid_rows,
sum(amount) as total_paid, round(avg(amount), 2) as avg_paid
from payments;

select c.city, count(o.order_id) as orders
from customers c
join orders o on c.cust_id = o.cust_id
where o.order_date >= '2026-02-01'
group by c.city
having count(o.order_id) > 1;
