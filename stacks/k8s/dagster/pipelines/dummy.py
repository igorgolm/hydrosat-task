import os
import json
import urllib.request
from dagster import Definitions, job, op, Failure, run_failure_sensor, RunFailureSensorContext, DefaultSensorStatus

@op
def failing_op():
    raise Failure(description="This is a dummy failure for monitoring testing")

@job
def dummy_failing_job():
    failing_op()

@op
def successful_op():
    return "Success!"

@job
def dummy_success_job():
    successful_op()

# https://docs.dagster.io/integrations/libraries/slack/dagster-slack
@run_failure_sensor(default_status=DefaultSensorStatus.RUNNING)
def slack_on_failure_sensor(context: RunFailureSensorContext):
    webhook_url = os.getenv("SLACK_WEBHOOK_URL")
    if not webhook_url:
        context.log.warning("SLACK_WEBHOOK_URL not set, skipping slack notification")
        return

    base_url = os.getenv("DAGSTER_BASE_URL", "http://localhost:3000")
    run_url = f"{base_url}/runs/{context.dagster_run.run_id}"

    message = {
        "text": (
            f"❌ *Dagster Run Failed*\n"
            f"*Job:* {context.dagster_run.job_name}\n"
            f"*Run ID:* `{context.dagster_run.run_id}`\n"
            f"*URL:* <{run_url}|View in Dagster>\n"
            f"*Error:* {context.failure_event.message}"
        )
    }

    data = json.dumps(message).encode("utf-8")
    req = urllib.request.Request(webhook_url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as resp:
            context.log.info(f"Slack notification sent, status: {resp.status}")
    except Exception as e:
        context.log.error(f"Failed to send Slack notification: {e}")

# Use the standard 'definitions' name for the Dagster Definitions object
definitions = Definitions(
    jobs=[dummy_failing_job, dummy_success_job],
    sensors=[slack_on_failure_sensor],
)
