USE finance_db;

-- Insert new transactions
INSERT INTO transactions (account_id, amount, type, status) VALUES (1001, 500.00, 'CREDIT', 'COMPLETED');
INSERT INTO transactions (account_id, amount, type, status) VALUES (1002, 200.00, 'DEBIT', 'PENDING');

-- Update a transaction status
UPDATE transactions SET status = 'COMPLETED' WHERE tx_id = 2;

-- Delete a transaction
DELETE FROM transactions WHERE tx_id = 1;
