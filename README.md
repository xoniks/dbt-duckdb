# dbt-Databricks Project Setup

This project uses [dbt](https://www.getdbt.com/) with [Databricks](https://databricks.com/), a unified analytics platform, to transform and model e-commerce data (e.g., Jaffle Shop dataset) in the cloud. This README provides step-by-step instructions to migrate from the DuckDB version to Databricks, including setting up Databricks Free Edition and configuring dbt.

## Prerequisites
- **Python**: Version 3.8 or higher.
- **pip**: Python package manager.
- **Operating System**: Windows, macOS, or Linux.
- **Terminal**: Command-line interface (e.g., PowerShell on Windows, Terminal on macOS/Linux).
- **Databricks Account**: Free Edition account (no credit card required).
- **Optional**: Git for cloning the project repository.

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

## Troubleshooting

### Common Issues:
- **"Catalog not found"**: Ensure your catalog exists and update `database` field in sources
- **"Table not found"**: Verify raw tables exist in Databricks with correct names
- **"Authentication failed"**: Check your token and ensure it has necessary permissions
- **"SQL Warehouse not available"**: Ensure your SQL Warehouse is running

### Schema Issues:
- **Tables created with `default_` prefix**: Add custom schema macro (see repository)
- **Source not found**: Verify `_sources.yml` references correct catalog and schema

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

## Additional Resources
- [Databricks Free Edition Documentation](https://docs.databricks.com/en/getting-started/free-edition.html)
- [dbt-databricks Documentation](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup)
- [Databricks Learning](https://www.databricks.com/resources/learn/training/databricks-fundamentals?itm_data=traininghomepromo2lfhtraining) - Free courses
- [Delta Lake Documentation](https://docs.delta.io/)

For issues, share the output of `dbt debug`, `dbt run`, or Databricks SQL queries.