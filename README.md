# Using Temporal (temporal.io) on Astra

* Create an Astra DB at [https://astra.datastax.com/](https://astra.datastax.com/)
* Add two keyspaces in the Astra DB UI via "Add Keyspace": `temporal` and `temporal_visibility`
* Create a new Astra token and get your DB's identifier
  * Update `.env` with your Astra token and DB identifier
* Update the Temporal schema by running `./schema.sh` or:
```sh
docker-compose -f docker-compose-cqlproxy-schema.yml run temporal-admin-tools \
  -ep cql-proxy -k temporal setup-schema -v 0.0
docker-compose -f docker-compose-cqlproxy-schema.yml run temporal-admin-tools \
  -ep cql-proxy -k temporal update-schema -d schema/cassandra/temporal/versioned/

docker-compose -f docker-compose-cqlproxy-schema.yml run temporal-admin-tools \
  -ep cql-proxy -k temporal_visibility setup-schema -v 0.0
docker-compose -f docker-compose-cqlproxy-schema.yml run temporal-admin-tools \
  -ep cql-proxy -k temporal_visibility update-schema -d schema/cassandra/visibility/versioned/
```

* Start up Temporal!
```sh
docker-compose -f docker-compose-cqlproxy.yml up
```

