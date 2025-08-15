#!/bin/bash

# Airflow Setup Script for dbt-duckdb project

set -e

echo "🚀 Setting up Airflow for dbt-duckdb project..."

# Set Airflow home to current directory
export AIRFLOW_HOME=$(pwd)
echo "AIRFLOW_HOME set to: $AIRFLOW_HOME"

# Install dependencies
echo "📦 Installing Airflow dependencies..."
pip install -r requirements.txt

# Initialize the database
echo "🗄️  Initializing Airflow database..."
airflow db init

# Create admin user
echo "👤 Creating admin user..."
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin

echo "✅ Airflow setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Set up Airflow Variables:"
echo "   airflow variables set GITHUB_TOKEN 'your-github-token'"
echo "   airflow variables set GITHUB_REPO_OWNER 'your-username'"
echo "   airflow variables set GITHUB_REPO_NAME 'dbt-duckdb'"
echo ""
echo "2. Start Airflow services:"
echo "   # Terminal 1:"
echo "   export AIRFLOW_HOME=$(pwd) && airflow webserver --port 8080"
echo ""
echo "   # Terminal 2:"
echo "   export AIRFLOW_HOME=$(pwd) && airflow scheduler"
echo ""
echo "3. Access Airflow UI:"
echo "   http://localhost:8080"
echo "   Username: admin"
echo "   Password: admin"