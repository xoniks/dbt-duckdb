# Local Airflow Setup for dbt-duckdb

This directory contains the local Airflow setup for triggering dbt models via GitHub Actions.

## Quick Start

1. **Navigate to airflow directory:**
   ```bash
   cd airflow
   ```

2. **Run setup script:**
   ```bash
   ./setup.sh
   ```

3. **Set Airflow Variables:**
   ```bash
   export AIRFLOW_HOME=$(pwd)
   airflow variables set GITHUB_TOKEN "your-github-personal-access-token"
   airflow variables set GITHUB_REPO_OWNER "your-github-username"
   airflow variables set GITHUB_REPO_NAME "dbt-duckdb"
   ```

4. **Start Airflow (requires 2 terminals):**
   
   **Terminal 1 - Web Server:**
   ```bash
   export AIRFLOW_HOME=$(pwd)
   airflow webserver --port 8080
   ```
   
   **Terminal 2 - Scheduler:**
   ```bash
   export AIRFLOW_HOME=$(pwd)
   airflow scheduler
   ```

5. **Access Airflow UI:**
   - URL: http://localhost:8080
   - Username: `admin`
   - Password: `admin`

## Triggering dbt Models

### Via Airflow UI:
1. Find the `trigger_dbt_via_github` DAG
2. Click "Trigger DAG w/ Config"
3. Use JSON configuration:
   ```json
   {
     "model_name": "gold_customer_summary"
   }
   ```

### Via CLI:
```bash
airflow dags trigger trigger_dbt_via_github -c '{"model_name": "gold_customer_summary"}'
```

## Available Models

**Gold Layer** (recommended for testing):
- `gold_customer_summary`
- `gold_product_sales`
- `gold_store_performance`

**Silver Layer**:
- `silver_customers`
- `silver_items`
- `silver_orders`
- `silver_suppliers`

**Bronze Layer**:
- `bronze_customers`
- `bronze_items`
- `bronze_orders`
- `bronze_products`
- `bronze_stores`
- `bronze_suppliers`

## Directory Structure

```
airflow/
├── dags/
│   └── trigger_dbt_dag.py     # Main DAG file
├── logs/                       # Airflow logs
├── requirements.txt           # Python dependencies
├── setup.sh                  # Setup script
├── README.md                 # This file
└── airflow.cfg               # Generated after init
```

## Troubleshooting

### Common Issues:

1. **"Variable GITHUB_TOKEN does not exist"**
   ```bash
   airflow variables set GITHUB_TOKEN "your-token"
   ```

2. **"Permission denied: ./setup.sh"**
   ```bash
   chmod +x setup.sh
   ```

3. **"Module not found" errors**
   ```bash
   pip install -r requirements.txt
   ```

4. **Airflow webserver won't start**
   - Check if port 8080 is already in use
   - Try a different port: `airflow webserver --port 8081`

### Logs:
- Airflow Task Logs: Available in Airflow UI
- Scheduler Logs: Terminal output where scheduler is running
- Web Server Logs: Terminal output where webserver is running

## GitHub Prerequisites

Before triggering workflows, ensure:

1. **GitHub Secrets are set** (in your repository settings):
   - `DATABRICKS_TOKEN`
   - `DATABRICKS_HOST`
   - `DATABRICKS_HTTP_PATH`

2. **GitHub Personal Access Token** has permissions:
   - `repo` (full repository access)
   - `workflow` (update workflows)

3. **GitHub Actions workflow** exists at `.github/workflows/dbt-run.yml`

## Monitoring

- **Airflow UI**: http://localhost:8080 - View DAG runs and logs
- **GitHub Actions**: Repository → Actions tab - View workflow executions
- **Databricks**: SQL Warehouse query history - View actual dbt executions