import ballerinax/cdc;

service cdc:Service on new cdc:PostgreSqlListener(database = {
    username: "root",
    password: "root",
    databaseName: "test"
}) {
	remote function onRead(record {|anydata...;|} after, string tableName) returns cdc:Error? {

	}

	remote function onCreate(record {|anydata...;|} after, string tableName) returns cdc:Error? {

	}

	remote function onUpdate(record {|anydata...;|} before, record {|anydata...;|} after, string tableName) returns cdc:Error? {

	}

	remote function onDelete(record {|anydata...;|} before, string tableName) returns cdc:Error? {

	}

	remote function onTruncate(string tableName) returns cdc:Error? {

	}
}
