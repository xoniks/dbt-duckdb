# dbt-DuckDB Project Setup

This project uses [dbt](https://www.getdbt.com/) with [DuckDB](https://duckdb.org/), an in-memory analytical database, to transform and model e-commerce data (e.g., Jaffle Shop dataset). This README provides step-by-step instructions to set up the project, including installing DuckDB, dbt, and required dependencies.

## Prerequisites
- **Python**: Version 3.8 or higher.
- **pip**: Python package manager.
- **Operating System**: Windows, macOS, or Linux.
- **Terminal**: Command-line interface (e.g., PowerShell on Windows, Terminal on macOS/Linux).
- **Optional**: Git for cloning the project repository (if applicable).

## Setup Instructions

### 1. Create a Project Directory
Create and navigate to a new directory for the project:
```bash
mkdir dbt_duckdb_project
cd dbt_duckdb_project
```

### 2. Set Up a Python Virtual Environment
Create and activate a Python virtual environment to isolate dependencies:
```bash
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

### 3. Install dbt-core and dbt-duckdb
Install the dbt core package and the DuckDB adapter:
```bash
pip install dbt-core dbt-duckdb
```

### 4. Install DuckDB
DuckDB is required for the `dbt-duckdb` adapter to function. Install the DuckDB CLI or Python package as follows:

#### Option 1: Install DuckDB CLI
The DuckDB CLI is useful for querying the database directly.
- **Download and Install**:
  - Visit the [DuckDB Releases page](https://github.com/duckdb/duckdb/releases) and download the latest CLI binary for your platform (e.g., `duckdb.exe` for Windows, `duckdb` for macOS/Linux).
  - For **Windows**:
    - Place `duckdb.exe` in a directory included in your system's PATH (e.g., `C:\Program Files\DuckDB`) or in the project directory (`dbt_duckdb_project`).
    - Update PATH (optional):
      ```powershell
      $env:Path += ";C:\Program Files\DuckDB"
      ```
  - For **macOS/Linux**:
    - Move the binary to `/usr/local/bin/`:
      ```bash
      sudo mv duckdb /usr/local/bin/
      chmod +x /usr/local/bin/duckdb
      ```
- **Verify Installation**:
  ```bash
  duckdb --version
  ```
  Expected output: `v1.3.0` (or the installed version).

#### Option 2: Install DuckDB Python Package
The `dbt-duckdb` adapter uses the DuckDB Python package, which is often installed automatically as a dependency. To ensure it’s installed:
```bash
pip install duckdb
```
Verify:
```bash
python -c "import duckdb; print(duckdb.__version__)"
```
Expected output: `1.3.0` (or the installed version).

### 5. Verify dbt Installation
Check that dbt and the DuckDB adapter are installed:
```bash
dbt --version
```
Expected output includes:
```
Core:
  - installed: 1.9.5
  - latest:    1.9.5 - Up to date!

Plugins:
  - duckdb: 1.9.3 - Up to date!
```

### 6. Initialize the dbt Project
If you haven’t initialized the dbt project, do so:
```bash
dbt init my_duckdb_project
cd my_duckdb_project
```
Follow prompts to configure the project with the DuckDB adapter, pointing to `database.duckdb` in the project directory.

### 7. Run the Project
Load seed data, run models, and test:
```bash
dbt seed
dbt run
dbt test
```

### 8. Query the Database
Use the DuckDB CLI to explore the database:
```bash
duckdb database.duckdb
```
Example queries:
```sql
SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema IN ('main', 'bronze', 'silver', 'gold');
SELECT * FROM gold.gold_customer_summary LIMIT 5;
```

## Project Structure
- **Seeds**: CSV files (e.g., `raw_customers.csv`) in `seeds/`, loaded into the `main` schema.
- **Models**: SQL files in `models/bronze/`, `models/silver/`, `models/gold/` for data transformation.
- **Database**: `database.duckdb` in the project root.
- **Configuration**:
  - `dbt_project.yml`: Defines schema structure (`main` for seeds, `bronze`, `silver`, `gold` for models).
  - `profiles.yml`: Configures DuckDB connection (in `~/.dbt/` or project directory).
  - `_sources.yml`: Defines source tables in `main`.
  - `schema.yml`: Defines model metadata (e.g., in `models/gold/schema.yml` for `gold_customer_summary`).

## Troubleshooting
- **File Lock Error** (`IO Error: File is already open`):
  - Close DuckDB CLI or terminate `duckdb.exe`:
    ```powershell
    taskkill /F /IM duckdb.exe
    ```
- **Schema Mismatch**: Ensure `_sources.yml` references `schema: main` and `dbt_project.yml` sets models to `bronze`, `silver`, `gold`.
- **Missing SKUs**: Verify `raw_products.csv` includes `BEV-003`, `BEV-004`, `BEV-005`.
- **DuckDB Not Found**: Ensure `duckdb` is in your PATH or project directory.

For issues, share the output of `dbt run`, `dbt test`, or DuckDB CLI queries.