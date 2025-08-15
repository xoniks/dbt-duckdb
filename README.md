# dbt-Databricks Project with Airflow CI/CD

This project uses [dbt](https://www.getdbt.com/) with [Databricks](https://databricks.com/) to transform and model e-commerce data (Jaffle Shop dataset) in the cloud. It features **5 different ways to trigger dbt models** through GitHub Actions CI/CD, including local Airflow orchestration.

## 🚀 Key Features

- **Multiple Trigger Methods**: Airflow, Git Push, Pull Request, Manual, Smart Detection
- **Secure Configuration**: Environment variables and GitHub secrets
- **Smart Model Detection**: Automatically runs only changed models
- **Comprehensive Testing**: Automated dbt tests and validation
- **Local Airflow Integration**: Full orchestration capabilities

## Prerequisites
- **Python**: Version 3.8 or higher
- **pip**: Python package manager
- **Operating System**: Windows, macOS, or Linux
- **Terminal**: Command-line interface
- **Databricks Account**: Free Edition account (no credit card required)
- **GitHub Account**: For CI/CD workflows
- **Git**: For version control and triggers
- **Optional**: Local Airflow for advanced orchestration

## Setup Instructions

### 1. Create Databricks Free Edition Account
1. Visit [databricks.com/try-databricks](https://databricks.com/try-databricks)
2. Sign up for **Free Edition** (no Azure/AWS/GCP account needed)
3. Complete the registration process
4. Access your Databricks workspace

### 2. Set Up Databricks Workspace
Once in your workspace:
1. **Create a SQL Warehouse** (if not automatically created):
   - Go to **SQL Warehouses** in the sidebar
   - Click **Create SQL Warehouse**
   - Choose **Serverless** (recommended for Free Edition)
   - Note the **HTTP Path** (you'll need this later)

2. **Get your connection details**:
   - **Host**: Your workspace URL (e.g., `your-workspace.cloud.databricks.com`)
   - **HTTP Path**: Found in SQL Warehouse connection details (e.g., `/sql/1.0/warehouses/abc123def456`)
   - **Token**: Create in **User Settings** → **Developer** → **Access Tokens**

### 3. Create Project Directory and Virtual Environment
```bash
mkdir dbt_databricks_project
cd dbt_databricks_project
python -m venv .venv
```
Activate the virtual environment:
- **On Windows**:
  ```bash
  .venv\Scripts\activate
  ```
- **On macOS/Linux**:
  ```bash
  source .venv/bin/activate
  ```

### 4. Install dbt-databricks
Install the dbt core package and the Databricks adapter:
```bash
pip install dbt-core dbt-databricks
```

### 5. Initialize the dbt Project
If starting fresh, initialize the project:
```bash
dbt init my_databricks_project
cd my_databricks_project
```

### 6. Configure dbt Profiles
Create or update your `profiles.yml` file (in `~/.dbt/` or project root):
```yaml
default:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: workspace
      schema: default
      host: <your-workspace-url>
      http_path: <your-http-path>
      token: <your-access-token>
```

Replace the placeholders:
- `<your-workspace-url>`: e.g., `dbc-3b7b1a98-b6df.cloud.databricks.com`
- `<your-http-path>`: e.g., `/sql/1.0/warehouses/61c7488cd0db2884`
- `<your-access-token>`: Your personal access token

### 7. Verify dbt Installation and Connection
Check that dbt and the Databricks adapter are installed:
```bash
dbt --version
```
Expected output includes:
```
Core:
  - installed: 1.9.5

Plugins:
  - databricks: 1.10.3
```

Test the connection:
```bash
dbt debug
```
You should see "Connection test: [OK]" in the output.

### 8. Create Raw Data Tables in Databricks
Before running dbt, create the raw tables in your Databricks workspace. Run this SQL in a Databricks notebook or SQL editor:

```sql
-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS workspace.main;

-- Create raw_customers table
CREATE OR REPLACE TABLE workspace.main.raw_customers (
    id STRING,
    name STRING
) USING DELTA;

-- Create raw_orders table  
CREATE OR REPLACE TABLE workspace.main.raw_orders (
    id STRING,
    customer STRING,
    ordered_at TIMESTAMP,
    store_id STRING,
    subtotal DECIMAL(10,2),
    tax_paid DECIMAL(10,2),
    order_total DECIMAL(10,2)
) USING DELTA;

-- Create other raw tables (raw_items, raw_products, raw_stores, raw_suppliers)
-- [Full SQL provided in repository]

-- Insert sample data
INSERT INTO workspace.main.raw_customers VALUES
('1', 'John Doe'),
('2', 'Jane Smith'),
('3', 'Bob Johnson');

-- [Additional sample data inserts provided in repository]
```

### 9. Run the Project
Load seed data (if any), run models, and test:
```bash
dbt seed    # If you have seed files
dbt run     # Run transformations
dbt test    # Test data quality
```

## 🚀 DBT Trigger Methods (5 Ways to Run Models)

This project supports **5 different ways** to trigger dbt model runs via GitHub Actions CI/CD:

### Method 1: 🌪️ Local Airflow Orchestration
**Best for**: Scheduled runs, complex orchestration, integration with other systems

**Setup**: See [Airflow Setup Guide](#airflow-setup)

**Usage**:
```bash
# Via Airflow UI (http://localhost:8080)
# Trigger "trigger_dbt_via_github" DAG with config:
{"model_name": "gold_customer_summary"}

# Via Airflow CLI  
airflow dags trigger trigger_dbt_via_github -c '{"model_name": "gold_product_sales"}'
```

### Method 2: 📝 Git Push Trigger
**Best for**: Continuous integration, automatic testing of changes

**Usage**:
```bash
# Make changes to dbt models
vim my_duckdb_project/models/gold/gold_customer_summary.sql

# Commit and push (triggers CI/CD automatically)
git add .
git commit -m "Update customer summary model"
git push origin main
```

**Triggers when**:
- Changes to `my_duckdb_project/models/**`
- Changes to `dbt_project.yml` or `profiles.yml`
- Changes to seed files

### Method 3: 🔀 Pull Request Trigger
**Best for**: Code review process, testing before merge

**Usage**:
```bash
# Create feature branch
git checkout -b feature/improve-customer-model

# Make changes and push
git add . && git commit -m "Improve customer logic"
git push origin feature/improve-customer-model

# Create PR via GitHub UI (triggers CI/CD automatically)
```

### Method 4: 🎯 Manual GitHub UI Trigger
**Best for**: Ad-hoc model runs, testing specific models

**Usage**:
1. Go to GitHub repository → **Actions** tab
2. Select **"DBT Unified Workflow"** workflow  
3. Click **"Run workflow"** button
4. Set parameters:
   - **Model name**: `gold_customer_summary`
   - **Run tests**: `true`
5. Click **"Run workflow"**

### Method 5: 🧠 Smart Model Detection (Automatic)
**Best for**: Efficient CI/CD, large dbt projects, avoiding unnecessary runs  
**Note**: This happens automatically within the unified workflow for git triggers

**How it works**:
- Automatically detects which `.sql` files changed in push/PR
- Runs only changed models + their dependencies  
- Falls back to default model if no changes detected
- No separate workflow needed!

**Example**:
```bash
# If you modify:
my_duckdb_project/models/silver/silver_customers.sql
my_duckdb_project/models/gold/gold_customer_summary.sql

# Unified workflow automatically:
# 1. Detects: silver_customers, gold_customer_summary changed
# 2. Runs: both models + any downstream dependencies
# 3. Tests: all affected models
# 4. Reports: "Smart detection" in logs
```

### Available Models

You can run any of these models with any trigger method:

**Gold Layer** (Business Ready):
- `gold_customer_summary` - Customer analytics
- `gold_product_sales` - Product performance  
- `gold_store_performance` - Store metrics

**Silver Layer** (Cleaned):
- `silver_customers`, `silver_items`, `silver_orders`, `silver_suppliers`

**Bronze Layer** (Raw):
- `bronze_customers`, `bronze_items`, `bronze_orders`, `bronze_products`, `bronze_stores`, `bronze_suppliers`

## 🔐 Security Setup (Required for CI/CD)

Before using any trigger methods, you must set up GitHub secrets:

### 1. GitHub Repository Secrets
Go to Repository → Settings → Secrets and variables → Actions, and add:

- `DATABRICKS_TOKEN`: Your Databricks personal access token
- `DATABRICKS_HOST`: `dbc-3b7b1a98-b6df.cloud.databricks.com`  
- `DATABRICKS_HTTP_PATH`: `/sql/1.0/warehouses/61c7488cd0db2884`

### 2. GitHub Personal Access Token (for Airflow)
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate token with `repo` and `workflow` permissions
3. Add to Airflow:
```bash
airflow variables set GITHUB_TOKEN "your-github-token"
airflow variables set GITHUB_REPO_OWNER "your-username"
airflow variables set GITHUB_REPO_NAME "dbt-duckdb"
```

**Note**: The original hardcoded credentials have been moved to secure environment variables.

## ⚡ Quick Start (Test the Setup)

### 1. Set up GitHub Secrets (Required)
Follow the [Security Setup](#security-setup-required-for-cicd) section above.

### 2. Test with Git Push (Easiest)
```bash
# Make a small change to trigger CI/CD  
echo "-- Updated $(date)" >> my_duckdb_project/models/gold/gold_customer_summary.sql

# Push to main branch (triggers workflow automatically)
git add .
git commit -m "Test CI/CD: update customer summary"
git push origin main
```

### 3. Monitor the Run
- **GitHub**: Go to Actions tab, watch "DBT Unified Workflow"
- **Databricks**: Check SQL Warehouse query history
- **Result**: `gold_customer_summary` model runs with tests

### 4. Optional: Set up Local Airflow
```bash
cd airflow && ./setup.sh
# Follow setup prompts, then access http://localhost:8080
```

## 🛠️ Airflow Setup

### Quick Setup:
```bash
# Navigate to airflow directory
cd airflow

# Run setup script
./setup.sh

# Set variables and start services (see airflow/README.md)
```

### Manual Setup:
```bash
cd airflow
pip install -r requirements.txt
export AIRFLOW_HOME=$(pwd)
airflow db init
airflow users create --username admin --password admin --role Admin \
    --email admin@example.com --firstname Admin --lastname User

# Start services (2 terminals)
airflow webserver --port 8080  # Terminal 1
airflow scheduler               # Terminal 2
```

Access Airflow at: http://localhost:8080 (admin/admin)

### 10. Explore Your Data
Use Databricks SQL editor or notebooks to explore:
```sql
-- View all schemas
SHOW SCHEMAS;

-- Preview bronze tables
SELECT * FROM workspace.bronze.bronze_customers LIMIT 5;

-- Check gold layer results
SELECT * FROM workspace.gold.gold_customer_summary LIMIT 10;

-- Data quality metrics
SELECT 
  COUNT(*) AS total_customers,
  AVG(total_spend) AS avg_spend,
  MAX(total_orders) AS max_orders
FROM workspace.gold.gold_customer_summary;
```

## Project Structure
- **Seeds**: CSV files (if any) in `seeds/`, loaded into Databricks
- **Models**: SQL files in `models/bronze/`, `models/silver/`, `models/gold/` for data transformation
- **Database**: Delta tables in Databricks workspace
- **Configuration**:
  - `dbt_project.yml`: Defines schema structure and Delta Lake settings
  - `profiles.yml`: Configures Databricks connection
  - `models/bronze/_sources.yml`: Defines source tables in `workspace.main`
  - `models/gold/schema.yml`: Defines model metadata and tests

## Key Differences from DuckDB Version

| Aspect | DuckDB | Databricks |
|--------|--------|------------|
| **Connection** | Local file | Cloud workspace |
| **Storage** | Local disk | Delta Lake |
| **Compute** | Single-threaded | Distributed |
| **File Format** | Native DuckDB | Delta tables |
| **Schema Management** | Simple | Three-level namespace (catalog.schema.table) |
| **Collaboration** | Local only | Real-time collaboration |

## 🔍 Monitoring & Debugging

### Check Workflow Status:
- **GitHub Actions**: Repository → Actions tab  
- **Airflow Logs**: http://localhost:8080
- **Databricks**: SQL Warehouse → Query History

### Debugging Commands:
```bash
# Check which files would trigger workflows
git diff --name-only HEAD~1 HEAD | grep -E "my_duckdb_project/models/.*\.sql$"

# Test dbt connection locally
cd my_duckdb_project
dbt debug

# Run specific model locally  
dbt run --select gold_customer_summary

# List all available models
dbt list --select models
```

## Troubleshooting

### CI/CD Issues:
- **Workflow Not Triggering**: Check branch name (`git branch --show-current`) and file paths
- **Model Not Found**: Verify model exists (`ls models/gold/gold_customer_summary.sql`)
- **Authentication Failed**: Verify GitHub secrets and Databricks token
- **Variable Not Found**: Set Airflow variables (`airflow variables set GITHUB_TOKEN "..."`)

### dbt Issues:
- **"Catalog not found"**: Ensure your catalog exists and update `database` field in sources
- **"Table not found"**: Verify raw tables exist in Databricks with correct names  
- **"SQL Warehouse not available"**: Ensure your SQL Warehouse is running

### GitHub Actions Issues:
- **403 Forbidden**: Check GitHub personal access token permissions
- **Repository dispatch failed**: Verify repository owner and name are correct
- **Secrets not found**: Ensure all required secrets are set in repository settings

### Performance Tips:
- Use **Serverless SQL Warehouses** for development
- Consider **partitioning** for large tables
- Enable **auto-optimize** for Delta tables
- Use **clustering** for frequently queried columns

## Migration from DuckDB
If migrating from the DuckDB version:
1. Update `dbt_project.yml` to use `databricks` profile
2. Replace `dbt-duckdb` with `dbt-databricks` in dependencies
3. Update source configuration for three-level namespace
4. Create raw tables in Databricks (SQL provided above)
5. Your model SQL should work with minimal changes

## 📁 Project Files

### Core dbt Files
- `my_duckdb_project/` - Main dbt project directory
- `my_duckdb_project/models/` - Bronze, Silver, Gold layer models
- `my_duckdb_project/profiles.yml` - Databricks connection (now uses env vars)

### CI/CD Files  
- `.github/workflows/dbt-run.yml` - Unified workflow (all triggers + smart detection)

### Airflow Files
- `airflow/dags/trigger_dbt_dag.py` - Main Airflow DAG
- `airflow/setup.sh` - Automated setup script
- `airflow/README.md` - Detailed Airflow guide

### Documentation & Config
- `claude_airflow_upgrade.md` - Complete implementation guide  
- `SETUP_GITHUB_SECRETS.md` - Security setup guide
- `.env.example` - Environment variable template

## 🚦 Best Practices

### Development Workflow
1. **Feature Branch**: Use smart detection on PRs for testing
2. **Main Branch**: Use push triggers for integration
3. **Production**: Use Airflow for scheduled orchestration  
4. **Ad-hoc**: Use manual GitHub triggers for debugging

### Model Recommendations
- **Start with**: `gold_customer_summary` (simple, fast)
- **For testing**: Any gold layer model
- **For development**: Models you're actively changing

### Commit Hygiene  
- Use clear commit messages describing model changes
- Group related model changes in single commits
- Test locally with `dbt run` before pushing

## Additional Resources
- [Databricks Free Edition Documentation](https://docs.databricks.com/en/getting-started/free-edition.html)
- [dbt-databricks Documentation](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Delta Lake Documentation](https://docs.delta.io/)

## 🆘 Getting Help

For issues, please provide:
- Output of `dbt debug`
- GitHub Actions workflow logs
- Airflow task logs (if using Airflow)
- Databricks SQL Warehouse query history

**Quick Test**: Try the [Quick Start](#quick-start-test-the-setup) section first to verify your setup!