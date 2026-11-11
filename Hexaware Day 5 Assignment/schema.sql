-- ============================================================
-- schema.sql
-- Retail Inventory Management (MySQL 8.4 LTS)
-- Run this file first, then run seed_data.sql
-- ============================================================

DROP DATABASE IF EXISTS retail_inventory;
CREATE DATABASE retail_inventory
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE retail_inventory;

-- ------------------------------------------------------------
-- Parent tables first (no foreign keys in these)
-- ------------------------------------------------------------

CREATE TABLE categories (
  category_id   INT         NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (category_id),
  CONSTRAINT uq_category_name UNIQUE (category_name)
) ENGINE=InnoDB;

CREATE TABLE suppliers (
  supplier_id    INT          NOT NULL AUTO_INCREMENT,
  supplier_name  VARCHAR(100) NOT NULL,
  supplier_phone VARCHAR(15)  NOT NULL,
  PRIMARY KEY (supplier_id),
  CONSTRAINT uq_supplier_name UNIQUE (supplier_name)
) ENGINE=InnoDB;

CREATE TABLE warehouses (
  warehouse_id   INT         NOT NULL AUTO_INCREMENT,
  warehouse_name VARCHAR(50) NOT NULL,
  city           VARCHAR(50) NOT NULL DEFAULT 'Coimbatore',
  PRIMARY KEY (warehouse_id),
  CONSTRAINT uq_warehouse_name UNIQUE (warehouse_name)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Child tables
-- ------------------------------------------------------------

CREATE TABLE products (
  product_id    INT          NOT NULL AUTO_INCREMENT,
  sku           VARCHAR(20)  NOT NULL,
  product_name  VARCHAR(100) NOT NULL,
  category_id   INT          NOT NULL,
  supplier_id   INT          NOT NULL,
  reorder_level INT          NOT NULL DEFAULT 10,
  status        VARCHAR(15)  NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (product_id),
  CONSTRAINT uq_products_sku UNIQUE (sku),
  CONSTRAINT chk_products_reorder CHECK (reorder_level >= 0),
  CONSTRAINT chk_products_status CHECK (status IN ('ACTIVE', 'DISCONTINUED')),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id)
    REFERENCES categories (category_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id)
    REFERENCES suppliers (supplier_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- stock = how much of a product is kept in a warehouse
CREATE TABLE stock (
  stock_id     INT NOT NULL AUTO_INCREMENT,
  product_id   INT NOT NULL,
  warehouse_id INT NOT NULL,
  quantity     INT NOT NULL DEFAULT 0,
  PRIMARY KEY (stock_id),
  CONSTRAINT uq_stock_product_warehouse UNIQUE (product_id, warehouse_id),
  CONSTRAINT chk_stock_quantity CHECK (quantity >= 0),
  CONSTRAINT fk_stock_product FOREIGN KEY (product_id)
    REFERENCES products (product_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_stock_warehouse FOREIGN KEY (warehouse_id)
    REFERENCES warehouses (warehouse_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- quick check that everything got created
SHOW TABLES;
