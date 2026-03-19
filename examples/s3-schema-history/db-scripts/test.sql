USE audit_db;

-- Insert audit log entries
INSERT INTO audit_log (entity_type, entity_id, action, changed_by) VALUES ('User', 42, 'UPDATE', 'admin');
INSERT INTO audit_log (entity_type, entity_id, action, changed_by) VALUES ('Order', 100, 'DELETE', 'system');

-- Update an audit entry
UPDATE audit_log SET action = 'REVIEWED' WHERE entry_id = 1;

-- Delete an audit entry
DELETE FROM audit_log WHERE entry_id = 2;
