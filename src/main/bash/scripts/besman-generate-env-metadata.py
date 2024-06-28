import argparse
import os
import json
import sys
from datetime import datetime


def get_current_date():
    # Get the current date and time
    current_datetime = datetime.now()

    # Format the current date and time as per the specified format
    formatted_datetime = current_datetime.strftime("%Y-%m-%dT%H:%M:%S")

    return formatted_datetime


def update_metadata(environment, version):
    json_template = {
        "name": environment,
        "version": [{"tag": version, "release_date": ""}],
        "author": {"name": "BeSLab", "type": "Lab"},
        "date_of_creation": get_current_date(),
        "last_update_date": get_current_date(),
        "last_execution": {
            "name": "BeSLab",
            "type": "Lab",
            "status": "Success",
            "timestamp": get_current_date(),
        },
        "compatible_playbooks": [{"name": "", "version": [""]}],
    }

    return json_template


def main(environment, version):
    local_env_dir = os.environ.get("BESMAN_LOCAL_ENV_DIR")
    if not local_env_dir:
        print("Environment variable BESMAN_LOCAL_ENV_DIR is not set.")
        sys.exit(1)

    metadata_file = "environment-metadata.json"
    metadata_file_path = os.path.join(local_env_dir, metadata_file)

    try:
        with open(metadata_file_path, "r") as data_file:
            data = json.load(data_file)
            env_list = data["environments"]
    except FileNotFoundError:
        print(f"{metadata_file_path} does not exist.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error decoding JSON in {metadata_file_path}.")
        sys.exit(1)

    new_metadata = update_metadata(environment, version)
    env_list.append(new_metadata)  # Append the new metadata to the existing data

    with open(metadata_file_path, "w") as outfile:
        json.dump(env_list, outfile, indent=4)

    print("Metadata updated successfully.")


if __name__ == "__main__":
    # os.environ["BESMAN_LOCAL_ENV_DIR"] = "/home/arunsuresh/besecure-ce-env-repo"
    parser = argparse.ArgumentParser(description="Process environment metadata.")
    parser.add_argument("--environment", required=True, help="Name of environment")
    parser.add_argument("--version", required=True, help="Version of the environment")

    args = parser.parse_args()
    main(args.environment, args.version)