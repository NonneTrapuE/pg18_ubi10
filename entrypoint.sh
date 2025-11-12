#!/bin/sh
set -e

PG_VERSION=18
PGDATA=${PGDATA:-/var/lib/postgresql/data}

# Initialisation à la première exécution
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initialisation de PostgreSQL..."
    /usr/pgsql-${PG_VERSION}/bin/initdb -D "$PGDATA"
fi

echo "host    all        all             0.0.0.0/0         trust" >> ${PGDATA}/pg_hba.conf
echo "listen_addresses = '*' " >> postgresql.conf

exec /usr/pgsql-${PG_VERSION}/bin/postgres -D $PGDATA