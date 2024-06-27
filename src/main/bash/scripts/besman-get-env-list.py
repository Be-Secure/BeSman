import requests
import os
import json
import sys

# Get environment variables
env_repo = os.environ.get("BESMAN_ENV_REPO")
branch = os.environ.get("BESMAN_ENV_REPO_BRANCH")
besman_dir = os.environ.get("BESMAN_DIR")
local_env = os.environ.get("BESMAN_LOCAL_ENV")
local_env_dir = os.environ.get("BESMAN_LOCAL_ENV_DIR")

# Construct the URL
url = f'https://raw.githubusercontent.com/{env_repo}/{branch}/environment-metadata.json'

try:
    # Load data
    if local_env == "True":
        # Load local JSON file
        with open(os.path.join(local_env_dir, 'environment-metadata.json'), 'r') as local_file:
            data = json.load(local_file)
    else:
        # Fetch JSON from URL
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for bad responses (4xx or 5xx)
        data = response.json()

    # Extract information
    extracted_info = []
    for environment in data.get('environments', []):
        name = environment.get('name')
        author_name = environment.get('author', {}).get('name')
        version_tags = [version.get('tag') for version in environment.get('version', [])]

        for tag in version_tags:
            extracted_info.append(f"{name} {author_name} {tag}")

    # Write the extracted information to a file
    output_file_path = os.path.join(besman_dir, "tmp", "environment_details.txt")
    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)  # Ensure the directory exists
    with open(output_file_path, "w") as tmp_file:
        tmp_file.write("\n".join(extracted_info))

    sys.exit(0)  # Exit with a success code
except requests.exceptions.RequestException as e:
    print(f"Error fetching data: {e}")
    sys.exit(1)  # Exit with an error code
except (KeyError, TypeError, json.JSONDecodeError) as e:
    print(f"Error parsing JSON: {e}")
    sys.exit(2)  # Exit with an error code
except IOError as e:
    print(f"Error writing to file: {e}")
    sys.exit(3)  # Exit with an error code
except Exception as e:
    print(f"An unexpected error occurred: {e}")
    sys.exit(4)  # Exit with an error code
