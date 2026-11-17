create database if not exists insurance_db;
use insurance_db;

drop table if exists claims, premiums, policies, customers;

create table customers (
  cust_id int primary key,
  name varchar(50) not null,
  dob date
);

create table policies (
  policy_no varchar(20) primary key,
  cust_id int,
  product varchar(30),
  agent varchar(30),
  start_date date,
  end_date date,
  status varchar(10),
  foreign key (cust_id) references customers(cust_id)
);

create table premiums (
  prem_id int primary key,
  policy_no varchar(20),
  amount decimal(10,2),
  paid_on date,
  foreign key (policy_no) references policies(policy_no)
);

create table claims (
  claim_id int primary key,
  policy_no varchar(20),
  claim_amt decimal(10,2),
  foreign key (policy_no) references policies(policy_no)
);

insert into customers values
(1,'arun','1998-04-10'),(2,'priya','1985-07-22'),(3,'kiran','1970-01-15'),(4,'meena','2001-09-30');

insert into policies values
('POL1001',1,'health','suresh','2025-12-10','2026-12-10','active'),
('POL1002',1,'motor','suresh','2026-01-05','2027-01-05','active'),
('POL1003',2,'health','lakshmi','2025-12-01','2026-12-01','active'),
('POL1004',3,'life','ramesh','2026-02-01','2036-02-01','active'),
('POL1005',4,'motor','lakshmi','2025-11-20','2026-11-20','active'),
('POL1006',2,'life','ramesh','2024-01-01','2025-01-01','expired');

insert into premiums values
(1,'POL1001',10000,'2025-12-10'),(2,'POL1002',8000,'2026-01-05'),
(3,'POL1003',12000,'2025-12-01'),(4,'POL1004',25000,'2026-02-01'),
(5,'POL1005',6000,'2025-11-20'),(6,'POL1006',20000,'2024-01-01');

insert into claims values
(1,'POL1001',9000),(2,'POL1003',6000),(3,'POL1005',5000),(4,'POL1004',3000);

set @today = '2026-11-17';

select policy_no, end_date, datediff(end_date, @today) as days_left
from policies
where end_date between @today and date_add(@today, interval 30 day);

select p.product, sum(pr.amount) as total_premium
from policies p
inner join premiums pr on p.policy_no = pr.policy_no
group by p.product;

select c.name, count(*) as active_policies
from customers c
inner join policies p on c.cust_id = p.cust_id
where p.status = 'active'
group by c.name
having count(*) > 1;

select p.product, sum(pr.amount) as premium, ifnull(sum(cl.claim_amt), 0) as claimed,
round(ifnull(sum(cl.claim_amt), 0) * 100 / sum(pr.amount), 2) as claim_ratio
from policies p
inner join premiums pr on p.policy_no = pr.policy_no
left join claims cl on p.policy_no = cl.policy_no
group by p.product;

select p.policy_no, p.product
from policies p
left join claims cl on p.policy_no = cl.policy_no
where cl.claim_id is null;

select case
  when timestampdiff(year, c.dob, @today) < 30 then 'below 30'
  when timestampdiff(year, c.dob, @today) < 50 then '30-49'
  else '50 and above'
end as age_band,
round(avg(pr.amount), 2) as avg_premium
from customers c
inner join policies p on c.cust_id = p.cust_id
inner join premiums pr on p.policy_no = pr.policy_no
group by age_band;

select date_format(start_date, '%Y-%m') as month, count(*) as new_policies
from policies
group by month
order by month;

select p.agent, sum(pr.amount) as total_premium
from policies p
inner join premiums pr on p.policy_no = pr.policy_no
group by p.agent
order by total_premium desc
limit 5;

select c.name,
concat(substring(p.policy_no, 1, 3), 'XX', substring(p.policy_no, 6)) as masked_policy,
date_add(p.end_date, interval 30 day) as grace_end
from customers c
inner join policies p on c.cust_id = p.cust_id;

select p.product,
round(ifnull(sum(cl.claim_amt), 0) * 100 / sum(pr.amount), 2) as claim_ratio
from policies p
inner join premiums pr on p.policy_no = pr.policy_no
left join claims cl on p.policy_no = cl.policy_no
group by p.product
having claim_ratio > 60;

select p.product, s.status
from (select distinct product from policies) p
cross join (select distinct status from policies) s
order by p.product;
