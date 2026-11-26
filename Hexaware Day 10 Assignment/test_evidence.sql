-- Day 10: Trigger Testing
-- Set 1: Retail Price Change Audit

USE retail_price_db;

-- Test 1: Display original product details

SELECT * FROM product_price;


-- Test 2: Single-row update
-- Changing Trail Backpack price from 1199 to 1249

UPDATE product_price
SET selling_price = 1249.00
WHERE product_id = 101;

-- Check audit record

SELECT * FROM price_audit;


-- Test 3: Multi-row update
-- Increasing the price of three products by 25

UPDATE product_price
SET selling_price = selling_price + 25
WHERE product_id IN (102, 103, 105);

-- Check all audit records

SELECT * FROM price_audit;


-- Check updated product prices

SELECT * FROM product_price;


-- Test 4: Invalid price update
-- Yoga Mat cost price is 300
-- Trying to set selling price to 250

UPDATE product_price
SET selling_price = 250.00
WHERE product_id = 104;

-- Expected:
-- ERROR 1644 (45000)
-- Selling price cannot be below cost price

-- Check whether the price remains unchanged

SELECT *
FROM product_price
WHERE product_id = 104;

-- Check audit records for Yoga Mat

SELECT *
FROM price_audit
WHERE product_id = 104;


-- Test 5: Display all triggers in the schema

SELECT
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    ACTION_TIMING,
    EVENT_OBJECT_TABLE,
    ACTION_STATEMENT
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE();
