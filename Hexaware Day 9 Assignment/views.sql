CREATE DATABASE IF NOT EXISTS telecom_db;
USE telecom_db;

CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY,
    subscriber_name VARCHAR(50),
    phone_number VARCHAR(15),
    connection_type VARCHAR(20),
    balance DECIMAL(10,2),
    validity_date DATE,
    aadhaar_number VARCHAR(20)
);

CREATE TABLE recharges (
    recharge_id INT PRIMARY KEY AUTO_INCREMENT,
    subscriber_id INT,
    recharge_amount DECIMAL(10,2),
    recharge_date DATE,
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
);

INSERT INTO subscribers VALUES
(1, 'Harini', '9876543210', 'PREPAID', 35.00, '2026-12-20', '123456789012'),
(2, 'Abi', '9876543211', 'PREPAID', 120.00, '2026-12-25', '123456789013'),
(3, 'Anis', '9876543212', 'POSTPAID', 500.00, '2026-12-28', '123456789014'),
(4, 'Adi', '9876543213', 'PREPAID', 45.00, '2026-12-18', '123456789015'),
(5, 'Thenu', '9876543214', 'POSTPAID', 300.00, '2026-12-30', '123456789016'),
(6, 'Man', '9876543215', 'PREPAID', 80.00, '2026-12-22', '123456789017');

INSERT INTO recharges (subscriber_id, recharge_amount, recharge_date) VALUES
(1, 100.00, '2026-11-01'),
(1, 50.00, '2026-11-10'),
(2, 200.00, '2026-11-05'),
(3, 300.00, '2026-11-08'),
(4, 150.00, '2026-11-12'),
(6, 100.00, '2026-11-15');

CREATE OR REPLACE VIEW vw_prepaid_subscribers AS
SELECT
    subscriber_id,
    subscriber_name,
    connection_type,
    balance,
    validity_date
FROM subscribers
WHERE connection_type = 'PREPAID';

CREATE OR REPLACE VIEW vw_recharge_summary AS
SELECT
    s.subscriber_id,
    s.subscriber_name,
    COUNT(r.recharge_id) AS total_recharges,
    COALESCE(SUM(r.recharge_amount), 0) AS total_recharge_amount,
    MAX(r.recharge_date) AS last_recharge_date
FROM subscribers s
LEFT JOIN recharges r
    ON s.subscriber_id = r.subscriber_id
WHERE s.connection_type = 'PREPAID'
GROUP BY s.subscriber_id, s.subscriber_name;

SELECT * FROM vw_prepaid_subscribers;
SELECT * FROM vw_recharge_summary;
