#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e


# Install rosemary in runtime to ensure it is available
echo "Installing rosemary in runtime to double-check"
pip install -e ./ || { echo "Rosemary installation failed at runtime"; exit 1; }
echo "Rosemary installation confirmed at runtime"

# Wait for the database to be ready
echo "Waiting for the database..."
sh ./scripts/wait-for-db.sh || { echo "Database connection failed"; exit 1; }

# Initialize migrations if not present
if [ ! -d "migrations/versions" ]; then
    echo "Initializing migrations..."
    flask db init
    flask db migrate
fi

# Check if the database is empty
if [ $(mariadb -u $MARIADB_USER -p$MARIADB_PASSWORD -h $MARIADB_HOSTNAME -P $MARIADB_PORT -D $MARIADB_DATABASE -sse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MARIADB_DATABASE';") -eq 0 ]; then
    echo "Empty database detected. Applying migrations and seeding..."
    flask db upgrade
    rosemary db:seed -y || { echo "Database seeding failed"; exit 1; }
else
    echo "Database already initialized. Resetting and seeding..."
    rosemary db:reset -y || { echo "Database reset failed"; exit 1; }
    rosemary db:seed -y || { echo "Database seeding failed"; exit 1; }
fi

echo "Database setup completed successfully"

# Start the application
echo "Starting the application..."
exec gunicorn --bind 0.0.0.0:80 app:app --log-level info --timeout 3600
