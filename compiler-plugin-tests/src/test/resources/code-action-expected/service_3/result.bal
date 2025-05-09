import ballerinax/cdc;

service cdc:Service on new cdc:MySqlListener(database = {
    username: "root",
    password: "root"
}) {
    int x = 5;
    string y = "xx";
	remote function onRead(record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onCreate(record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onUpdate(record {|anydata...;|} before, record {|anydata...;|} after) returns cdc:Error? {

	}

	remote function onDelete(record {|anydata...;|} before) returns cdc:Error? {

	}
}
