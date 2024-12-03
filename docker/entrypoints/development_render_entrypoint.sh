#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install Rosemary
pip install -e ./


# Initialize migrations only if the migrations directory doesn't exist
if [ ! -d "migrations/versions" ]; then
    # Initialize the migration repository
    flask db init
    flask db migrate
fi

# Check if the database is empty
if [ $(mariadb -u $MARIADB_USER -p$MARIADB_PASSWORD -h $MARIADB_HOSTNAME -P $MARIADB_PORT -D $MARIADB_DATABASE -sse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MARIADB_DATABASE';") -eq 0 ]; then
 
    echo "Empty database, migrating..."

    # Get the latest migration revision
    LATEST_REVISION=$(ls -1 migrations/versions/*.py | grep -v "__pycache__" | sort -r | head -n 1 | sed 's/.*\/\(.*\)\.py/\1/')

    echo "Latest revision: $LATEST_REVISION"

    # Run the migration process to apply all database schema changes
    flask db upgrade

    # Seed the database with initial data
    rosemary db:seed -y

else

    echo "Database already initialized, updating migrations..."

    # Get the current revision to avoid duplicate stamp
    CURRENT_REVISION=$(mariadb -u $MARIADB_USER -p$MARIADB_PASSWORD -h $MARIADB_HOSTNAME -P $MARIADB_PORT -D $MARIADB_DATABASE -sse "SELECT version_num FROM alembic_version LIMIT 1;")
    
    if [ -z "$CURRENT_REVISION" ]; then
        # If no current revision, stamp with the latest revision
        flask db stamp head
    fi

    # Run the migration process to apply all database schema changes
    flask db upgrade

    # Delete all data from the database
    rosemary db:reset -y

    # si no hay datos que haya un echo que me diga, se ha borrado todo correctamente, si no hay datos que haya un echo que me diga, no se ha borrado correctamente

    if [ $(mariadb -u $MARIADB_USER -p$MARIADB_PASSWORD -h $MARIADB_HOSTNAME -P $MARIADB_PORT -D $MARIADB_DATABASE -sse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MARIADB_DATABASE';") -eq 0 ]; then
        echo "All data has been deleted successfully."
    else
        echo "Data deletion was not successful."
    fi

    # Seed the database with initial data
    rosemary db:seed -y

    if [ $(mariadb -u $MARIADB_USER -p$MARIADB_PASSWORD -h $MARIADB_HOSTNAME -P $MARIADB_PORT -D $MARIADB_DATABASE -sse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MARIADB_DATABASE';") -gt 0 ]; then
        echo "Database has been populated successfully."
    else
        echo "Database population was not successful."
    fi


fi

# Start the application using Gunicorn, binding it to port 80
# Set the logging level to info and the timeout to 3600 seconds
exec gunicorn --bind 0.0.0.0:80 app:app --log-level info --timeout 3600
