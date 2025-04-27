// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerina/os;
import ballerinax/cdc;
import ballerinax/cdc.mysql.driver as _;
import ballerinax/redis;

configurable string username = os:getEnv("DB_USERNAME");
configurable string password = os:getEnv("DB_PASSWORD");

listener cdc:MySqlListener mysqlListener = new (
    database = {
        username,
        password,
        includedDatabases: "store_db",
        includedTables: ["store_db.products", "store_db.vendors", "store_db.product_reviews"]
    },
    snapshotMode = cdc:NO_DATA
);

final redis:Client redis = check new (
    connection = {
        host: "localhost",
        port: 6379
    }
);

type Entity record {
    int id;
};

type ProductReviews record {
    int product_id;
    int rating;
};

@cdc:ServiceConfig {
    tables: ["store_db.products", "store_db.vendors"]
}
service cdc:Service on mysqlListener {

    remote function onRead(Entity after, string tableName) returns error? {
        _ = check redis->set(string `${tableName}:${after.id}`, after.toJsonString());
        log:printInfo(`'${tableName}' cache entry created for Id: ${after.id}`);
    }

    remote function onCreate(Entity after, string tableName) returns error? {
        _ = check redis->set(string `product:${after.id}`, after.toJsonString());
        log:printInfo(`'${tableName}' cache entry created for Id: ${after.id}`);
    }

    remote function onUpdate(Entity before, Entity after, string tableName) returns error? {
        _ = check redis->set(string `product:${after.id}`, after.toJsonString());
        log:printInfo(`'${tableName}' cache entry updated for Id: ${after.id}.`);
    }

    remote function onDelete(Entity before, string tableName) returns error? {
        int delVal = check redis->del([
            string `${tableName}:${before.id}`
        ]);
        if tableName == "products" {
            _ = check redis->del([
                string `product_tot_rating:${before.id}`,
                string `product_reviews:${before.id}`
            ]);
            log:printInfo(`'products' cache entry deleted for Id: ${before.id}. Redis delete count: ${delVal}`);
        } else {
            log:printInfo(`'vendors' cache entry deleted for Id: ${before.id}. Redis delete count: ${delVal}`);
        }
    }

    remote function onError(cdc:Error 'error) returns error? {
        log:printInfo(`Error occurred while processing events. Error: ${'error.message()}`);
        if 'error is cdc:PayloadBindingError {
            log:printInfo(`Error occurred while processing events. Error: ${'error.detail().payload.toBalString()}`);
        }
    }
}

@cdc:ServiceConfig {
    tables: ["store_db.product_reviews"]
}
service cdc:Service on mysqlListener {

    remote function onRead(ProductReviews after, string tableName) returns error? {
        int totalRating = check redis->incrBy(string `product_tot_rating:${after.product_id}`, after.rating);
        log:printInfo(`'product_tot_rating' cache added for Product Id: ${after.product_id}. Current total rating: ${totalRating}`);

        int reviews = check redis->incr(string `product_reviews:${after.product_id}`);
        log:printInfo(`'product_reviews' cache entry added for Product Id: ${after.product_id}. Current total reviews: ${reviews}`);
    }

    remote function onCreate(ProductReviews after, string tableName) returns error? {
        int totalRating = check redis->incrBy(string `product_tot_rating:${after.product_id}`, after.rating);
        log:printInfo(`'product_tot_rating' cache added for Product Id: ${after.product_id}. Current total rating: ${totalRating}`);

        int reviews = check redis->incr(string `product_reviews:${after.product_id}`);
        log:printInfo(`'product_reviews' cache entry added for Product Id: ${after.product_id}. Current total reviews: ${reviews}`);
    }

    remote function onUpdate(ProductReviews before, ProductReviews after, string tableName) returns error? {
        int ratingDiff = after.rating - before.rating;

        if ratingDiff > 0 {
            int updatedRating = check redis->incrBy(string `product_tot_rating:${after.product_id}`, ratingDiff);
            log:printInfo(`'product_tot_rating' cache updated for Product Id: ${after.product_id}. Current total rating: ${updatedRating}`);
            return;
        }

        if ratingDiff < 0 {
            int updatedRating = check redis->decrBy(string `product_tot_rating:${after.product_id}`, ratingDiff);
            log:printInfo(`'product_tot_rating' cache updated for Product Id: ${after.product_id}. Current total rating: ${updatedRating}`);
            return;
        }
        log:printInfo(`No change in rating for Product ID: ${after.product_id} from table '${tableName}'`);

    }

    remote function onDelete(ProductReviews before, string tableName) returns error? {
        int deletedRating = check redis->decrBy(string `product_tot_rating:${before.product_id}`, before.rating);
        log:printInfo(`'product_tot_rating' cache deleted for Product Id: ${before.product_id}. Current total rating: ${deletedRating}`);
        int reviews = check redis->decr(string `product_reviews:${before.product_id}`);
        log:printInfo(`'product_reviews' cache entry deleted for Product Id: ${before.product_id}. Current total reviews: ${reviews}`);
    }

    remote function onError(cdc:Error 'error) returns error? {
        log:printInfo(`Error occurred while processing events. Error: ${'error.message()}`);
    }
}
