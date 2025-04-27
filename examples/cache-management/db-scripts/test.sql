USE store_db;

UPDATE products
SET price = price * 0.9
WHERE id = 1002;

UPDATE product_reviews
SET rating = rating - 1
WHERE product_id = 1002;

INSERT products VALUES (1003, "Samsung Galaxy S20", 499.99, "Old Smartphone", 2);

DELETE FROM products
WHERE id = 1003;