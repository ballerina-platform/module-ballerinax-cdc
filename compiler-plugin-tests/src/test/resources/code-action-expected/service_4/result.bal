import ballerinax/cdc;

service cdc:Service on new MockListener(database = {
    username: "root",
    password: "root"
}) {
    int x = 5;
    string y = "xx";
    remote function onRead(record {|anydata...;|} after, string tableName) returns cdc:Error? {
    }

    remote function onCreate(record {|anydata...;|} after, string tableName) returns cdc:Error? {
    }

    remote function onUpdate(record {|anydata...;|} before, record {|anydata...;|} after, string tableName) returns cdc:Error? {
    }

    remote function onDelete(record {|anydata...;|} before, string tableName) returns cdc:Error? {
    }
}
