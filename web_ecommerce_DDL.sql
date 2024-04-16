CREATE DATABASE web_ecommerce_DDL;

-- USERS TABLE
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    birth_date DATE,
    gender VARCHAR(2),
    username VARCHAR,
    password VARCHAR,
    phone_number VARCHAR,
    address VARCHAR(150),
    created_at DATE,
    status_id INT,
    is_admin BOOLEAN,
    role_id INT 
);

-- PRODUCTS TABLE
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_subcategory_id INT,
    name VARCHAR,
    description VARCHAR,
    color VARCHAR(50),
    size CHAR,
    cost DOUBLE,
    price DOUBLE,
    image VARCHAR
    created_at date,
    status_id int
);

-- PRODUCT SUBCATEGORIES TABLE 
CREATE TABLE product_subcategories (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    product_category_id INT 
);

-- PRODUCT CATEGORIES TABLE
CREATE TABLE product_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR
);

-- ORDERS TABLE
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INT, 
    user_id INT,
    quantity INT,
    created_at DATE,
    cart_id INT
);

-- CARTS TABLE
CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    items JSON,
    address VARCHAR,
    phone_number VARCHAR,
    created_at DATE,
    status_id INT,
    total_quantity INT,
    total_price NUMERIC
);

-- SESSION TABLE
CREATE TABLE session (
    sid VARCHAR PRIMARY KEY,
    sess JSON,
    expire TIMESTAMP
);

-- STATUS TABLE
CREATE TABLE status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

-- ROLES TABLE
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

-- SET FOREGIN KEY USER TABLE 
ALTER TABLE users
ADD CONSTRAINT fk_status_id
  FOREIGN KEY (status_id)
  REFERENCES status(id),
ADD CONSTRAINT fk_role_id
  FOREIGN KEY (role_id)
  REFERENCES roles(id);

--SET FOREGIN KEY 
---- USERS TABLE 
ALTER TABLE users
ADD CONSTRAINT fk_status_id
  FOREIGN KEY (status_id)
  REFERENCES status(id),
ADD CONSTRAINT fk_role_id
  FOREIGN KEY (role_id)
  REFERENCES roles(id);
 
---- PRODUCTS TABLE 
ALTER TABLE PRODUCTS
ADD CONSTRAINT fk_status_id
  FOREIGN KEY (status_id)
  REFERENCES status(id);

---- USERS TABLE
ALTER TABLE ORDERS
ADD CONSTRAINT fk_user_id
  FOREIGN KEY (user_id)
  REFERENCES users(id),
ADD CONSTRAINT fk_cart_id
  FOREIGN KEY (cart_id)
  REFERENCES carts(id);

---- PRODUCTS TABLE 
ALTER TABLE CARTS
ADD CONSTRAINT fk_status_id
  FOREIGN KEY (status_id)
  REFERENCES status(id);
