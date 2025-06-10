# Create a project directory
mkdir dbt_duckdb_project
cd dbt_duckdb_project

# Set up a Python virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dbt-core and dbt-duckdb
pip install dbt-core dbt-duckdb