create database if not exists telecom_db;
use telecom_db;

drop table if exists invoices, call_records, subscribers, plans;

create table plans (
  plan_id int primary key,
  plan_name varchar(30) not null,
  data_limit_gb int,
  price decimal(8,2)
);

create table subscribers (
  sub_id int primary key,
  name varchar(50) not null,
  circle varchar(30),
  plan_id int,
  foreign key (plan_id) references plans(plan_id)
);

create table call_records (
  rec_id int primary key,
  sub_id int,
  call_date date,
  minutes int,
  data_gb decimal(6,2),
  foreign key (sub_id) references subscribers(sub_id)
);

create table invoices (
  inv_id int primary key,
  sub_id int,
  inv_date date,
  due_date date,
  amount decimal(8,2),
  paid_on date,
  foreign key (sub_id) references subscribers(sub_id)
);

insert into plans values
(1,'basic',10,199),(2,'smart',30,399),(3,'unlimited',100,699);

insert into subscribers values
(1,'arun','tamil nadu',1),(2,'priya','karnataka',2),(3,'kiran','tamil nadu',2),
(4,'meena','mumbai',3),(5,'ravi','karnataka',1);

insert into call_records values
(1,1,'2026-10-02',120,6),(2,1,'2026-10-20',80,7),(3,2,'2026-10-05',200,12),
(4,3,'2026-10-11',50,35),(5,4,'2026-11-01',300,40),(6,2,'2026-11-03',90,10);

insert into invoices values
(1,1,'2026-10-01','2026-10-15',199,'2026-10-10'),
(2,2,'2026-10-01','2026-10-15',399,null),
(3,3,'2026-10-01','2026-10-15',399,'2026-10-14'),
(4,4,'2026-11-01','2026-11-15',699,null),
(5,5,'2026-11-01','2026-11-15',199,null),
(6,1,'2026-11-01','2026-11-15',199,'2026-11-05');

set @today = '2026-11-17';

select p.plan_name, sum(cr.minutes) as total_minutes
from plans p
join subscribers s on p.plan_id = s.plan_id
join call_records cr on s.sub_id = cr.sub_id
group by p.plan_name;

select s.name, p.data_limit_gb, sum(cr.data_gb) as used_gb
from subscribers s
join plans p on s.plan_id = p.plan_id
join call_records cr on s.sub_id = cr.sub_id
group by s.name, p.data_limit_gb
having sum(cr.data_gb) > p.data_limit_gb;

select date_format(inv_date, '%b-%Y') as month, sum(amount) as revenue
from invoices
group by month
order by min(inv_date);

select inv_id, sub_id, due_date, datediff(@today, due_date) as days_overdue
from invoices
where paid_on is null and datediff(@today, due_date) > 15;

select s.sub_id, s.name
from subscribers s
left join call_records cr on s.sub_id = cr.sub_id
where cr.rec_id is null;

select s.circle, round(sum(i.amount) / count(distinct s.sub_id), 2) as arpu
from subscribers s
join invoices i on s.sub_id = i.sub_id
group by s.circle;

select p.plan_name, count(s.sub_id) as subscribers
from plans p
left join subscribers s on p.plan_id = s.plan_id
group by p.plan_name
order by subscribers desc;

select s.name, sum(cr.data_gb) as total_data
from subscribers s
join call_records cr on s.sub_id = cr.sub_id
group by s.name
order by total_data desc
limit 10;

select concat('INV-', date_format(inv_date, '%Y%m'), '-', lpad(inv_id, 4, '0')) as invoice_no,
upper(s.name) as customer,
case
  when i.paid_on is not null then 'paid'
  when @today > i.due_date then concat('overdue by ', datediff(@today, i.due_date), ' days')
  else 'due soon'
end as due_status
from invoices i
join subscribers s on i.sub_id = s.sub_id;

select s.name, sum(cr.minutes) as total_min, avg(cr.minutes) as avg_min
from subscribers s
left join call_records cr on s.sub_id = cr.sub_id
group by s.name;

select s.name, ifnull(sum(cr.minutes), 0) as total_min,
coalesce(avg(cr.minutes), 0) as avg_min
from subscribers s
left join call_records cr on s.sub_id = cr.sub_id
group by s.name;

select p.plan_name, s.circle, sum(i.amount) as revenue
from plans p
join subscribers s on p.plan_id = s.plan_id
join invoices i on s.sub_id = i.sub_id
group by p.plan_name, s.circle
order by p.plan_name, revenue desc;
