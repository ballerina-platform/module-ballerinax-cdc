import ballerinax/cdc;

service cdc:Service on new cdc:MySqlListener(database = {
    username: "root",
    password: "root"
}) {
}
