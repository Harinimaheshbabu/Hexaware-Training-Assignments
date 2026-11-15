-- =====================================================================
-- Day 7 - Joins and Subqueries (MySQL 8.4 LTS)
-- Set 1 - Logistics Shipment Analysis
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. DATABASE CREATION
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS logistics_db;
CREATE DATABASE logistics_db;
USE logistics_db;

-- ---------------------------------------------------------------------
-- 2. TABLE CREATION
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    customer_id    INT PRIMARY KEY,
    customer_name  VARCHAR(60) NOT NULL,
    city           VARCHAR(30) NOT NULL
);

CREATE TABLE hubs (
    hub_id    INT PRIMARY KEY,
    hub_name  VARCHAR(40) NOT NULL,
    city      VARCHAR(30) NOT NULL
);

CREATE TABLE carriers (
    carrier_id    INT PRIMARY KEY,
    carrier_name  VARCHAR(60) NOT NULL,
    vehicle_type  VARCHAR(30)
);

CREATE TABLE employees (
    employee_id    INT PRIMARY KEY,
    employee_name  VARCHAR(50) NOT NULL,
    designation    VARCHAR(40),
    salary         DECIMAL(10,2),
    hub_id         INT,
    supervisor_id  INT,
    FOREIGN KEY (hub_id) REFERENCES hubs(hub_id),
    FOREIGN KEY (supervisor_id) REFERENCES employees(employee_id)
);

CREATE TABLE shipments (
    shipment_id         INT PRIMARY KEY,
    customer_id         INT NOT NULL,
    carrier_id          INT NOT NULL,
    origin_hub_id       INT NOT NULL,
    destination_hub_id  INT NOT NULL,
    shipment_date       DATE,
    shipping_cost       DECIMAL(10,2),
    status              VARCHAR(20),
    delay_days          INT,   -- 0 = on time, NULL = still in transit
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (carrier_id) REFERENCES carriers(carrier_id),
    FOREIGN KEY (origin_hub_id) REFERENCES hubs(hub_id),
    FOREIGN KEY (destination_hub_id) REFERENCES hubs(hub_id)
);

CREATE TABLE delivery_events (
    event_id     INT PRIMARY KEY,
    shipment_id  INT NOT NULL,
    hub_id       INT NOT NULL,
    employee_id  INT NOT NULL,
    event_type   VARCHAR(30),
    event_time   DATETIME,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    FOREIGN KEY (hub_id) REFERENCES hubs(hub_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- ---------------------------------------------------------------------
-- 3. SAMPLE DATA
-- ---------------------------------------------------------------------
INSERT INTO hubs VALUES
(1, 'Madurai Hub',    'Madurai'),
(2, 'Dindigul Hub',   'Dindigul'),
(3, 'Coimbatore Hub', 'Coimbatore'),
(4, 'Trichy Hub',     'Trichy'),
(5, 'Salem Hub',      'Salem'),
(6, 'Chennai Hub',    'Chennai');

INSERT INTO carriers VALUES
(1, 'SwiftRoute Logistics',    'Truck'),
(2, 'Kaveri Cargo Movers',     'Mini Truck'),
(3, 'Vaigai Express Carriers', 'Truck'),
(4, 'Sri Murugan Transports',  'Container'),
(5, 'Thendral Freight Lines',  'Mini Truck');

INSERT INTO customers VALUES
(1, 'Arulmozhi Textiles',           'Madurai'),
(2, 'Kavitha Agro Traders',         'Dindigul'),
(3, 'Selvam Electronics',           'Coimbatore'),
(4, 'Meenakshi Handlooms',          'Madurai'),
(5, 'Pranav Auto Parts',            'Chennai'),
(6, 'Thenmozhi Pharma Distributors','Trichy'),
(7, 'Ganesan Steel Works',          'Salem'),
(8, 'Nandhini Spices',              'Dindigul'),
(9, 'Rajeshwari Stationers',        'Trichy');

INSERT INTO employees VALUES
(1,  'Karthikeyan R',   'Regional Manager',    85000, 6, NULL),
(2,  'Sangeetha M',     'Hub Manager',         62000, 1, 1),
(3,  'Vignesh P',       'Hub Manager',         60000, 3, 1),
(4,  'Lakshmi Priya S', 'Hub Manager',         58000, 4, 1),
(5,  'Mohamed Rafiq',   'Dispatch Supervisor', 38000, 1, 2),
(6,  'Dhanalakshmi K',  'Dispatch Executive',  26000, 1, 5),
(7,  'Arun Kumar T',    'Dispatch Executive',  27000, 3, 3),
(8,  'Harini V',        'Dispatch Executive',  24500, 4, 4),
(9,  'Bala Murugan S',  'Sorting Specialist',  39500, 2, 5),
(10, 'Nithya Devi A',   'Dispatch Executive',  25500, 5, 3);

INSERT INTO shipments VALUES
(1001, 3, 1, 3, 1, '2026-09-02', 1800, 'Delivered',  0),
(1002, 3, 2, 3, 2, '2026-09-05', 1200, 'Delayed',    3),
(1003, 3, 1, 6, 3, '2026-09-08', 2600, 'Delayed',    1),
(1004, 3, 3, 3, 4, '2026-09-12', 1500, 'Delivered',  0),
(1005, 3, 4, 3, 5, '2026-09-15', 2200, 'Delayed',    4),
(1006, 3, 2, 3, 6, '2026-11-08', 3200, 'In Transit', NULL),
(1007, 1, 1, 1, 6, '2026-09-03', 2400, 'Delivered',  0),
(1008, 1, 3, 1, 3, '2026-09-18', 1900, 'Delayed',    2),
(1009, 2, 5, 2, 1, '2026-09-10', 1500, 'Delivered',  0),
(1010, 8, 5, 2, 4, '2026-09-20', 1500, 'Delayed',    5),
(1011, 4, 4, 1, 6, '2026-09-22', 2400, 'Delayed',    3),
(1012, 5, 3, 6, 4, '2026-09-14', 2100, 'Delivered',  0),
(1013, 5, 4, 6, 1, '2026-11-10', 2900, 'In Transit', NULL),
(1014, 6, 5, 4, 6, '2026-11-12', 1700, 'In Transit', NULL),
(1015, 7, 1, 4, 5, '2026-09-28', 1350, 'Delivered',  0);

INSERT INTO delivery_events VALUES
(1,  1001, 3, 7,  'Picked Up',   '2026-09-02 09:00:00'),
(2,  1001, 3, 7,  'Dispatched',  '2026-09-02 15:30:00'),
(3,  1001, 1, 6,  'Delivered',   '2026-09-04 11:15:00'),
(4,  1002, 3, 7,  'Picked Up',   '2026-09-05 10:00:00'),
(5,  1002, 3, 3,  'Dispatched',  '2026-09-05 18:00:00'),
(6,  1002, 2, 9,  'Reached Hub', '2026-09-09 08:45:00'),
(7,  1002, 2, 9,  'Delivered',   '2026-09-11 14:20:00'),
(8,  1003, 6, 1,  'Picked Up',   '2026-09-08 09:30:00'),
(9,  1003, 3, 7,  'Delivered',   '2026-09-11 16:00:00'),
(10, 1005, 3, 7,  'Picked Up',   '2026-09-15 08:30:00'),


-- =====================================================================
-- TASK 1 - TEN JOIN QUERIES
-- =====================================================================

-- Q1 (INNER JOIN): Shipments delayed by more than two days with carrier names
SELECT s.shipment_id,
       c.carrier_name,
       s.delay_days
FROM shipments s
INNER JOIN carriers c ON s.carrier_id = c.carrier_id
WHERE s.delay_days > 2
ORDER BY s.delay_days DESC, s.shipment_id;

-- Q2 (LEFT JOIN): Hubs with no outbound shipments
SELECT h.hub_id,
       h.hub_name,
       h.city
FROM hubs h
LEFT JOIN shipments s ON h.hub_id = s.origin_hub_id
WHERE s.shipment_id IS NULL;

-- Q3 (SELF JOIN with LEFT JOIN): Employees with their supervisors
SELECT e.employee_name AS employee,
       e.designation,
       sup.employee_name AS supervisor
FROM employees e
LEFT JOIN employees sup ON e.supervisor_id = sup.employee_id
ORDER BY e.employee_id;

-- Q4 (INNER JOIN, 4 tables): In-transit shipments with customer, carrier, origin hub
SELECT s.shipment_id,
       cu.customer_name,
       ca.carrier_name,
       h.hub_name AS origin_hub
FROM shipments s
INNER JOIN customers cu ON s.customer_id = cu.customer_id
INNER JOIN carriers ca  ON s.carrier_id = ca.carrier_id
INNER JOIN hubs h       ON s.origin_hub_id = h.hub_id
WHERE s.status = 'In Transit'
ORDER BY s.shipment_id;

-- Q5 (LEFT JOIN): Shipment count of every customer, including those with none
SELECT cu.customer_name,
       COUNT(s.shipment_id) AS total_shipments
FROM customers cu
LEFT JOIN shipments s ON cu.customer_id = s.customer_id
GROUP BY cu.customer_id, cu.customer_name
ORDER BY total_shipments DESC, cu.customer_name;

-- Q6 (RIGHT JOIN): Delivery event count for each delayed shipment
SELECT s.shipment_id,
       s.status,
       COUNT(de.event_id) AS event_count
FROM delivery_events de
RIGHT JOIN shipments s ON de.shipment_id = s.shipment_id
WHERE s.status = 'Delayed'
GROUP BY s.shipment_id, s.status
ORDER BY s.shipment_id;

-- Q7 (INNER JOIN): Number of shipments and total cost per carrier
SELECT ca.carrier_name,
       COUNT(*) AS total_shipments,
       SUM(s.shipping_cost) AS total_cost
FROM carriers ca
INNER JOIN shipments s ON ca.carrier_id = s.carrier_id
GROUP BY ca.carrier_id, ca.carrier_name
ORDER BY total_cost DESC;

-- Q8 (RIGHT JOIN): Outbound shipments and cost per hub (0 if none)
SELECT h.hub_name,
       COUNT(s.shipment_id) AS outbound_shipments,
       COALESCE(SUM(s.shipping_cost), 0) AS total_cost
FROM shipments s
RIGHT JOIN hubs h ON s.origin_hub_id = h.hub_id
GROUP BY h.hub_id, h.hub_name
ORDER BY h.hub_id;

-- Q9 (INNER JOIN, 3 tables): Delivery events of shipment 1002 with hub and employee
SELECT de.event_type,
       h.hub_name,
       e.employee_name,
       de.event_time
FROM delivery_events de
INNER JOIN hubs h      ON de.hub_id = h.hub_id
INNER JOIN employees e ON de.employee_id = e.employee_id
WHERE de.shipment_id = 1002
ORDER BY de.event_time;

-- Q10 (SELF JOIN with INNER JOIN): Employees who earn more than their supervisor
SELECT e.employee_name,
       e.salary AS employee_salary,
       sup.employee_name AS supervisor,
       sup.salary AS supervisor_salary
FROM employees e
INNER JOIN employees sup ON e.supervisor_id = sup.employee_id
WHERE e.salary > sup.salary;


-- =====================================================================
-- TASK 2 - SUBQUERIES: IN, EXISTS, ANY, ALL
-- =====================================================================

-- Reference: average delay of each carrier (NULL delays are ignored by AVG)
SELECT c.carrier_name,
       ROUND(AVG(s.delay_days), 2) AS avg_delay
FROM carriers c
INNER JOIN shipments s ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_id, c.carrier_name
ORDER BY c.carrier_id;

-- 2.1 IN: Customers who have shipped to every hub
SELECT customer_id,
       customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM shipments
    GROUP BY customer_id
    HAVING COUNT(DISTINCT destination_hub_id) = (SELECT COUNT(*) FROM hubs)
);

-- 2.2 EXISTS: Customers with at least one shipment
SELECT c.customer_id,
       c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM shipments s
    WHERE s.customer_id = c.customer_id
);

-- 2.3 ANY: Carriers whose average delay is greater than at least one carrier's average
SELECT c.carrier_name,
       ROUND(AVG(s.delay_days), 2) AS avg_delay
FROM carriers c
INNER JOIN shipments s ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_id, c.carrier_name
HAVING AVG(s.delay_days) > ANY (
    SELECT AVG(delay_days)
    FROM shipments
    GROUP BY carrier_id
);

-- 2.4 ALL: Carrier whose average delay is greater than every other carrier's average
SELECT c.carrier_name,
       ROUND(AVG(s.delay_days), 2) AS avg_delay
FROM carriers c
INNER JOIN shipments s ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_id, c.carrier_name
HAVING AVG(s.delay_days) > ALL (
    SELECT AVG(s2.delay_days)
    FROM shipments s2
    WHERE s2.carrier_id <> c.carrier_id
    GROUP BY s2.carrier_id
);

-- 2.5 Overall average delay
SELECT ROUND(AVG(delay_days), 2) AS overall_avg_delay
FROM shipments;

-- 2.5 Carriers whose average delay is above the overall average
SELECT c.carrier_name,
       ROUND(AVG(s.delay_days), 2) AS avg_delay
FROM carriers c
INNER JOIN shipments s ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_id, c.carrier_name
HAVING AVG(s.delay_days) > (SELECT AVG(delay_days) FROM shipments)
ORDER BY c.carrier_id;


-- =====================================================================
-- TASK 3 - REWRITING SUBQUERIES AS JOINS
-- =====================================================================

-- 3.1 EXISTS rewritten as INNER JOIN (DISTINCT removes repeated customers)
SELECT DISTINCT c.customer_id,
       c.customer_name
FROM customers c
INNER JOIN shipments s ON c.customer_id = s.customer_id
ORDER BY c.customer_id;

-- 3.2 IN (every hub) rewritten as JOIN + GROUP BY + HAVING
SELECT c.customer_id,
       c.customer_name
FROM customers c
INNER JOIN shipments s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT s.destination_hub_id) = (SELECT COUNT(*) FROM hubs);

-- =====================================================================
-- TASK 4 - SECOND-HIGHEST SHIPPING COST PER HUB (origin hub)
-- =====================================================================
SELECT h.hub_name,
       (SELECT MAX(s.shipping_cost)
        FROM shipments s
        WHERE s.origin_hub_id = h.hub_id
          AND s.shipping_cost < (SELECT MAX(s2.shipping_cost)
                                 FROM shipments s2
                                 WHERE s2.origin_hub_id = h.hub_id)
       ) AS second_highest_cost
FROM hubs h
ORDER BY h.hub_id;
-- NULL means the hub has fewer than two distinct shipping costs.


-- =====================================================================
-- TASK 5 - JOIN-CHOICE JUSTIFICATION
-- =====================================================================
-- | Question No. | Join Type Used              | Reason for Choosing It                                                         |
-- |--------------|-----------------------------|--------------------------------------------------------------------------------|
-- | 1            | INNER JOIN                  | Only shipments with a matching carrier are needed to show the carrier name.    |
-- | 2            | LEFT JOIN                   | All hubs must be checked, including the one that has no shipments.             |
-- | 3            | SELF JOIN (using LEFT JOIN) | Employees and supervisors are in the same table; top manager must still show.  |
-- | 4            | INNER JOIN                  | Matching records from customers, carriers and hubs are required per shipment.  |
-- | 5            | LEFT JOIN                   | All customers must be listed, including the one with no shipments.             |
-- | 6            | RIGHT JOIN                  | All delayed shipments (right table) must appear, even without events.          |
-- | 7            | INNER JOIN                  | Only matching carrier and shipment records are needed for cost totals.         |
-- | 8            | RIGHT JOIN                  | All hubs (right table) must appear, including the one with no outbound shipments. |
-- | 9            | INNER JOIN                  | Each event must be matched with its hub and employee to show their names.      |
-- | 10           | SELF JOIN (using INNER JOIN)| Salaries of an employee and their supervisor in the same table are compared.   |
