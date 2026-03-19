USE order_db;

-- Insert new orders
INSERT INTO orders (customer_id, total, status) VALUES (101, 149.99, 'PENDING');
INSERT INTO orders (customer_id, total, status) VALUES (102, 89.50, 'CONFIRMED');

-- Update an order status
UPDATE orders SET status = 'SHIPPED' WHERE order_id = 1;

-- Delete a cancelled order
DELETE FROM orders WHERE order_id = 2;
