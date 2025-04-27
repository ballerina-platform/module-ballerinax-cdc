import ballerinax/cdc;

service cdc:Service on new cdc:MySqlListener(database = {
    username: "root",
    password: "root"
}) {
	remote function onRead(record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onCreate(record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onUpdate(record {|anydata...;|} before, record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onDelete(record {|anydata...;|} before) returns cdc:Error? {

	}
}
