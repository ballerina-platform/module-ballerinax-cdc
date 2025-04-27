import ballerinax/cdc;

service cdc:Service on new cdc:PostgreSqlListener(database = {
    username: "root",
    password: "root",
    databaseName: "test"
}) {
	remote function onRead(record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onCreate(record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onUpdate(record {|anydata...;|} before, record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onDelete(record {|anydata...;|} before) returns cdc:Error? {

	}

	remote function onTruncate() returns cdc:Error? {

	}
}
