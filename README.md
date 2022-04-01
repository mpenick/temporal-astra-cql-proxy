# Using Temporal (temporal.io) on Astra

* Create an Astra DB at [https://astra.datastax.com/](https://astra.datastax.com/)
* Add two keyspaces in the Astra DB UI via "Add Keyspace": `temporal` and `temporal_visibility`
  ![image](https://user-images.githubusercontent.com/3710715/161330020-ad4ca2ac-bbad-427c-9d76-b2845f8d740e.png)
* Create a new [Astra token] and get your DB's identifier
  * DB identifer is the last ID in the URL when your DB is selected (the "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" part)
    * `https://astra.datastax.com/org/.../database/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
  * Or the "Datacenter ID" without the `-1` at the end (you'll have to copy and remove that trailing `-1`)
    ![image](https://user-images.githubusercontent.com/3710715/161331138-906f4f7f-919e-4f47-a731-a855d54369c5.png)
    
* Clone this repo
```sh
git clone https://github.com/mpenick/temporal-astra-cql-proxy.git
cd temporal-astra-cql-proxy
```

* Update `.env` with your Astra token and DB identifier
```yaml
# Update these
ASTRA_TOKEN=updateme
ASTRA_DATABASE_ID=updateme
```

* Update the Temporal schema by running `./schema.sh` OR run these commands:
```sh
docker-compose -f docker-compose-schema.yaml run temporal-admin-tools \
  -ep cql-proxy -k temporal setup-schema -v 0.0
docker-compose -f docker-compose-schema.yaml run temporal-admin-tools \
  -ep cql-proxy -k temporal update-schema -d schema/cassandra/temporal/versioned/

docker-compose -f docker-compose-schema.yaml run temporal-admin-tools \
  -ep cql-proxy -k temporal_visibility setup-schema -v 0.0
docker-compose -f docker-compose-schema.yaml run temporal-admin-tools \
  -ep cql-proxy -k temporal_visibility update-schema -d schema/cassandra/visibility/versioned/
```

* Start up Temporal!
```sh
docker-compose up
```

*Note:* The current version of the Temporal schema has issues because the clustering order does
contain the full clustering key. The Temporal Cassandra schema has been copied to this repo and
modified to work with Astra. This change should be pushed upstream because the schema is technically
underspecified.

```diff
diff --git a/schema/cassandra/visibility/versioned/v1.0/schema.cql b/schema/cassandra/visibility/versioned/v1.0/schema.cql
index 5fcad40cc..de8b4fe2e 100644
--- a/schema/cassandra/visibility/versioned/v1.0/schema.cql
+++ b/schema/cassandra/visibility/versioned/v1.0/schema.cql
@@ -10,7 +10,7 @@ CREATE TABLE open_executions (
   encoding             text,
   task_queue            text,
   PRIMARY KEY  ((namespace_id, namespace_partition), start_time, run_id)
-) WITH CLUSTERING ORDER BY (start_time DESC)
+) WITH CLUSTERING ORDER BY (start_time DESC, run_id DESC)
   AND COMPACTION = {
     'class': 'org.apache.cassandra.db.compaction.LeveledCompactionStrategy',
     'tombstone_threshold': 0.4
@@ -37,7 +37,7 @@ CREATE TABLE closed_executions (
   encoding             text,
   task_queue            text,
   PRIMARY KEY  ((namespace_id, namespace_partition), close_time, run_id)
-) WITH CLUSTERING ORDER BY (close_time DESC)
+) WITH CLUSTERING ORDER BY (close_time DESC, run_id DESC)
   AND COMPACTION = {
     'class': 'org.apache.cassandra.db.compaction.LeveledCompactionStrategy'
   }
```

[Astra token]: https://docs.datastax.com/en/astra/docs/manage-application-tokens.html
