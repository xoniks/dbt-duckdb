from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable
import requests
import logging

# DAG configuration
default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

def trigger_github_workflow(**context):
    """
    Trigger GitHub Actions workflow via repository dispatch
    """
    # Get configuration from Airflow Variables
    github_token = Variable.get("GITHUB_TOKEN")
    repo_owner = Variable.get("GITHUB_REPO_OWNER", default_var="your-username")
    repo_name = Variable.get("GITHUB_REPO_NAME", default_var="dbt-duckdb")
    
    # Get model name from DAG run configuration
    model_name = context['dag_run'].conf.get('model_name', 'gold_customer_summary')
    
    # GitHub API endpoint
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"
    
    # Request headers
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    }
    
    # Request payload
    payload = {
        'event_type': 'run-dbt-model',
        'client_payload': {
            'model_name': model_name,
            'triggered_by': 'airflow',
            'timestamp': datetime.now().isoformat(),
            'dag_run_id': context['dag_run'].run_id
        }
    }
    
    # Make the request
    try:
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        
        logging.info(f"Successfully triggered GitHub workflow for model: {model_name}")
        logging.info(f"Response status: {response.status_code}")
        logging.info(f"GitHub API URL: {url}")
        
        return {
            'status': 'success',
            'model_name': model_name,
            'github_response_code': response.status_code,
            'dag_run_id': context['dag_run'].run_id
        }
        
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to trigger GitHub workflow: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            logging.error(f"Response content: {e.response.text}")
        raise

def validate_configuration(**context):
    """
    Validate that required Airflow Variables are set
    """
    required_vars = ['GITHUB_TOKEN', 'GITHUB_REPO_OWNER', 'GITHUB_REPO_NAME']
    missing_vars = []
    
    for var in required_vars:
        try:
            Variable.get(var)
        except KeyError:
            missing_vars.append(var)
    
    if missing_vars:
        raise ValueError(f"Missing required Airflow Variables: {', '.join(missing_vars)}")
    
    logging.info("Configuration validation passed")
    return True

# Define the DAG
dag = DAG(
    'trigger_dbt_via_github',
    default_args=default_args,
    description='Trigger dbt models via GitHub Actions',
    schedule_interval=None,  # Manual trigger only
    catchup=False,
    tags=['dbt', 'github-actions', 'databricks'],
    max_active_runs=1
)

# Define the tasks
validate_config_task = PythonOperator(
    task_id='validate_configuration',
    python_callable=validate_configuration,
    dag=dag,
    provide_context=True
)

trigger_task = PythonOperator(
    task_id='trigger_github_workflow',
    python_callable=trigger_github_workflow,
    dag=dag,
    provide_context=True
)

# Set task dependencies
validate_config_task >> trigger_task