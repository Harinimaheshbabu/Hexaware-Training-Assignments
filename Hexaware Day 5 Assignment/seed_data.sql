-- ============================================================
-- seed_data.sql
-- Retail Inventory Management (MySQL 8.4 LTS)
-- Run schema.sql first.
-- ============================================================

USE retail_inventory;

-- ------------------------------------------------------------
-- PART 1: Sample data (parent tables first, then children)
-- ------------------------------------------------------------

INSERT INTO categories (category_name) VALUES
('Groceries'),
('Beverages'),
('Snacks'),
('Dairy'),
('Personal Care'),
('Household'),
('Stationery'),
('Electronics'),
('Toys'),
('Frozen Foods');

INSERT INTO suppliers (supplier_name, supplier_phone) VALUES
('Sri Murugan Traders',     '9876543201'),
('Kovai Fresh Foods',       '9876543202'),
('Annapoorna Distributors', '9876543203'),
('Lakshmi Agencies',        '9876543204'),
('Bharat Stationers',       '9876543205'),
('TechNova Supplies',       '9876543206'),
('Green Valley Dairy',      '9876543207'),
('CleanHome Products',      '9876543208'),
('Sunrise Beverages',       '9876543209'),
('Happy Kids Toys',         '9876543210');

-- first warehouse leaves out city, so the DEFAULT ('Coimbatore') is used
INSERT INTO warehouses (warehouse_name) VALUES ('Coimbatore Main WH');

INSERT INTO warehouses (warehouse_name, city) VALUES
('Chennai Central WH', 'Chennai'),
('Madurai South WH',   'Madurai'),
('Salem Hub',          'Salem'),
('Trichy Depot',       'Trichy'),
('Erode Store House',  'Erode'),
('Tirupur Godown',     'Tirupur'),
('Bangalore North WH', 'Bengaluru'),
('Kochi Port WH',      'Kochi'),
('Hyderabad WH',       'Hyderabad');

-- active products (status is left out, so it takes the DEFAULT 'ACTIVE')
INSERT INTO products (sku, product_name, category_id, supplier_id, reorder_level) VALUES
('SKU1001', 'Basmati Rice 5kg',      1,  3, 20),
('SKU1002', 'Orange Juice 1L',       2,  9, 30),
('SKU1003', 'Potato Chips 100g',     3,  2, 50),
('SKU1004', 'Full Cream Milk 500ml', 4,  7, 40),
('SKU1005', 'Bath Soap',             5,  4, 60),
('SKU1006', 'Dish Wash Liquid 500ml',6,  8, 30),
('SKU1007', 'Notebook 200 Pages',    7,  5, 100),
('SKU1008', 'USB Cable 1m',          8,  6, 15),
('SKU1009', 'Building Blocks Set',   9, 10, 10),
('SKU1010', 'Frozen Peas 500g',     10,  2, 25);

-- discontinued products (no stock rows for these on purpose)
INSERT INTO products (sku, product_name, category_id, supplier_id, reorder_level, status) VALUES
('SKU1011', 'Old Model Phone Charger', 8, 6, 10, 'DISCONTINUED'),
('SKU1012', 'Fidget Spinner',          9, 10, 10, 'DISCONTINUED');

-- stock: (product_id, warehouse_id, quantity)
INSERT INTO stock (product_id, warehouse_id, quantity) VALUES
(1,  1, 120),
(1,  2,  80),
(2,  1,  45),
(2,  3,  60),
(3,  1, 200),
(3,  4,  15),
(4,  2,  70),
(5,  5, 150),
(6,  6,  90),
(7,  7, 300),
(8,  8,  40),
(9,  9,  25),
(10, 10, 55),
(10, 1,   0);

-- check the data went in
SELECT 'categories' AS table_name, COUNT(*) AS total_rows FROM categories
UNION ALL SELECT 'suppliers',  COUNT(*) FROM suppliers
UNION ALL SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL SELECT 'products',   COUNT(*) FROM products
UNION ALL SELECT 'stock',      COUNT(*) FROM stock;


-- ------------------------------------------------------------
-- PART 2: Basic retrieval (SELECT)
-- ------------------------------------------------------------

-- all stock with product, supplier and warehouse names
SELECT p.sku, p.product_name, c.category_name, s.supplier_name,
       w.warehouse_name, st.quantity
FROM stock st
JOIN products   p ON st.product_id   = p.product_id
JOIN categories c ON p.category_id   = c.category_id
JOIN suppliers  s ON p.supplier_id   = s.supplier_id
JOIN warehouses w ON st.warehouse_id = w.warehouse_id
ORDER BY p.sku, w.warehouse_name;

-- items that are below their reorder level (expected: SKU1003 at Salem Hub, SKU1010 at Coimbatore Main WH)
SELECT p.sku, p.product_name, w.warehouse_name, st.quantity, p.reorder_level
FROM stock st
JOIN products   p ON st.product_id   = p.product_id
JOIN warehouses w ON st.warehouse_id = w.warehouse_id
WHERE st.quantity < p.reorder_level;

-- total quantity of each product across all warehouses
SELECT p.sku, p.product_name, SUM(st.quantity) AS total_quantity
FROM products p
JOIN stock st ON p.product_id = st.product_id
GROUP BY p.sku, p.product_name
ORDER BY p.sku;


-- ------------------------------------------------------------
-- PART 3: Four failing INSERTs
-- These are commented out so the script does not stop in the middle.
-- Run them ONE BY ONE and take a screenshot of each error.
-- ------------------------------------------------------------

-- 1) Duplicate key (SKU1001 already exists)
-- INSERT INTO products (sku, product_name, category_id, supplier_id, reorder_level)
-- VALUES ('SKU1001', 'Brown Rice 1kg', 1, 3, 15);
-- Expected: ERROR 1062 (23000): Duplicate entry 'SKU1001' for key 'products.uq_products_sku'

-- 2) Missing parent (category_id 99 does not exist)
-- INSERT INTO products (sku, product_name, category_id, supplier_id)
-- VALUES ('SKU1013', 'Green Tea Box', 99, 1);
-- Expected: ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
--   (`retail_inventory`.`products`, CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`)
--   REFERENCES `categories` (`category_id`) ON UPDATE CASCADE)

-- 3) Negative quantity (CHECK quantity >= 0 fails)
-- INSERT INTO stock (product_id, warehouse_id, quantity)
-- VALUES (3, 5, -10);
-- Expected: ERROR 3819 (HY000): Check constraint 'chk_stock_quantity' is violated.

-- 4) NULL in a mandatory (NOT NULL) column
-- INSERT INTO products (sku, product_name, category_id, supplier_id)
-- VALUES ('SKU1014', NULL, 1, 1);
-- Expected: ERROR 1048 (23000): Column 'product_name' cannot be null

-- Bonus) ON DELETE RESTRICT: Groceries still has products, so it cannot be deleted
-- DELETE FROM categories WHERE category_id = 1;
-- Expected: ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (...)


-- ------------------------------------------------------------
-- PART 4: UPDATE and DELETE with SELECT before and after
-- ------------------------------------------------------------

-- 4a) Correct a supplier phone number

-- before
SELECT supplier_id, supplier_name, supplier_phone
FROM suppliers
WHERE supplier_id = 2;

UPDATE suppliers
SET supplier_phone = '9876543299'
WHERE supplier_id = 2;

-- after
SELECT supplier_id, supplier_name, supplier_phone
FROM suppliers
WHERE supplier_id = 2;

-- 4b) Remove discontinued SKUs

-- before (expected: SKU1011 and SKU1012)
SELECT product_id, sku, product_name, status
FROM products
WHERE status = 'DISCONTINUED';

DELETE FROM products
WHERE status = 'DISCONTINUED';

-- after (expected: empty set)
SELECT product_id, sku, product_name, status
FROM products
WHERE status = 'DISCONTINUED';

-- total products went from 12 to 10
SELECT COUNT(*) AS total_products FROM products;


-- ------------------------------------------------------------
-- PART 5: Exploring system databases and information_schema
-- ------------------------------------------------------------

-- you will see information_schema, mysql, performance_schema and sys here
SHOW DATABASES;

-- tables of my schema with engine and row count
-- NOTE: table_rows is only an estimate for InnoDB, so refresh the stats first
SET SESSION information_schema_stats_expiry = 0;
ANALYZE TABLE categories, suppliers, warehouses, products, stock;

SELECT table_name AS table_name,
       engine     AS engine,
       table_rows AS approx_rows
FROM information_schema.tables
WHERE table_schema = 'retail_inventory'
ORDER BY table_name;

-- exact row counts using COUNT(*) as a cross-check
-- expected: categories 10, suppliers 10, warehouses 10, products 10, stock 14
SELECT 'categories' AS table_name, COUNT(*) AS exact_rows FROM categories
UNION ALL SELECT 'suppliers',  COUNT(*) FROM suppliers
UNION ALL SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL SELECT 'products',   COUNT(*) FROM products
UNION ALL SELECT 'stock',      COUNT(*) FROM stock;
