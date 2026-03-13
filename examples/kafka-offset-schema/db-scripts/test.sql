USE inventory_db;

-- Insert new products
INSERT INTO products (name, quantity, price, category) VALUES ('Wireless Headphones', 50, 79.99, 'Electronics');
INSERT INTO products (name, quantity, price, category) VALUES ('Running Shoes', 120, 59.99, 'Footwear');

-- Update product stock
UPDATE products SET quantity = 45 WHERE product_id = 1;

-- Delete a discontinued product
DELETE FROM products WHERE product_id = 2;
