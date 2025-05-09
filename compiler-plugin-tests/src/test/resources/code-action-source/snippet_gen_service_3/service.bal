import ballerinax/cdc;

service cdc:Service on new cdc:PostgreSqlListener(database = {
    username: "root",
    password: "root",
    databaseName: "test"
}) {
}
