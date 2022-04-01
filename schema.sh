#!/usr/bin/env bash

docker-compose -f docker-compose-schema.yaml run temporal-admin-tools -ep cql-proxy -k temporal setup-schema -v 0.0
docker-compose -f docker-compose-schema.yaml run temporal-admin-tools -ep cql-proxy -k temporal update-schema -d schema/cassandra/temporal/versioned/

docker-compose -f docker-compose-schema.yaml run temporal-admin-tools -ep cql-proxy -k temporal_visibility setup-schema -v 0.0
docker-compose -f docker-compose-schema.yaml run temporal-admin-tools -ep cql-proxy -k temporal_visibility update-schema -d schema/cassandra/visibility/versioned/
