-- Day 10: Triggers
-- Set 1: Retail Price Change Audit

CREATE DATABASE IF NOT EXISTS retail_price_db;
USE retail_price_db;

-- Remove old tables if they already exist
DROP TABLE IF EXISTS price_audit;
DROP TABLE IF EXISTS product_price;

-- Create product price table
CREATE TABLE product_price (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(60) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL
);

-- Create audit table to store price changes
CREATE TABLE price_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_by VARCHAR(100),
    changed_at DATETIME
);

-- Insert sample product records
INSERT INTO product_price VALUES
(101, 'Trail Backpack', 800.00, 1199.00),
(102, 'Coffee Mug', 120.00, 199.00),
(103, 'Study Lamp', 450.00, 699.00),
(104, 'Yoga Mat', 300.00, 499.00),
(105, 'Water Bottle', 220.00, 349.00);

DELIMITER $$

-- 1. BEFORE UPDATE trigger
-- Prevents selling price from going below cost price

CREATE TRIGGER trg_check_price
BEFORE UPDATE ON product_price
FOR EACH ROW
BEGIN
    IF NEW.selling_price < NEW.cost_price THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Selling price cannot be below cost price';

    END IF;
END$$


-- 2. AFTER UPDATE trigger
-- Records old and new prices in the audit table

CREATE TRIGGER trg_price_audit
AFTER UPDATE ON product_price
FOR EACH ROW
BEGIN
    IF OLD.selling_price <> NEW.selling_price THEN

        INSERT INTO price_audit
        (product_id, old_price, new_price,
         changed_by, changed_at)

        VALUES
        (OLD.product_id,
         OLD.selling_price,
         NEW.selling_price,
         CURRENT_USER(),
         NOW());

    END IF;
END$$

DELIMITER ;


-- Display the triggers created in this database

SELECT
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    ACTION_TIMING,
    EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'retail_price_db';
