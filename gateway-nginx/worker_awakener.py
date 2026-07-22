import os
import sys
import time
import boto3
from botocore.exceptions import BotoCoreError, ClientError

WORKER_INSTANCE_ID = os.getenv("PDF_WORKER_INSTANCE_ID", "")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")


def wake_worker_if_needed():
    if not WORKER_INSTANCE_ID:
        print("[Gateway] PDF_WORKER_INSTANCE_ID not configured, skipping auto-start.")
        return True

    ec2 = boto3.client("ec2", region_name=AWS_REGION)
    try:
        response = ec2.describe_instances(InstanceIds=[WORKER_INSTANCE_ID])
        state = response["Reservations"][0]["Instances"][0]["State"]["Name"]

        if state == "running":
            print("[Gateway] PDF Worker EC2 is already running.")
            return True

        if state in ["stopped", "stopping"]:
            print(f"[Gateway] PDF Worker EC2 state is '{state}'. Triggering startInstances...")
            ec2.start_instances(InstanceIds=[WORKER_INSTANCE_ID])

            # Wait for instance to reach running state (up to 45 seconds)
            for _ in range(15):
                time.sleep(3)
                check = ec2.describe_instances(InstanceIds=[WORKER_INSTANCE_ID])
                curr_state = check["Reservations"][0]["Instances"][0]["State"]["Name"]
                if curr_state == "running":
                    print("[Gateway] PDF Worker EC2 is now RUNNING and ready to process requests.")
                    return True
            print("[Gateway] Timeout waiting for PDF Worker to start.")
            return False

        return True
    except (BotoCoreError, ClientError) as e:
        print(f"[Gateway Error] AWS API failure waking worker: {str(e)}")
        return False


if __name__ == "__main__":
    success = wake_worker_if_needed()
    sys.exit(0 if success else 1)
