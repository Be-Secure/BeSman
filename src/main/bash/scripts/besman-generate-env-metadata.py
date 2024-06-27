import argparse
import os
import json
import sys

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
    except FileNotFoundError:
        print(f"{metadata_file_path} does not exist.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error decoding JSON in {metadata_file_path}.")
        sys.exit(1)
    
    print(json.dumps(data, indent=4))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process environment metadata.")
    parser.add_argument("--environment", required=True, help="Name of environment")
    parser.add_argument("--version", required=True, help="Version of the environment")
    
    args = parser.parse_args()
    
    main(args.environment, args.version)
