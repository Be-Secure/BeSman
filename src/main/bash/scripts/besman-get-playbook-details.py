import argparse
import requests
import os
import json
import sys
from besman_python_helper import ConstructURL

def get_master_list():
    playbook_repo = os.environ.get("BESMAN_PLAYBOOK_REPO")
    branch = os.environ.get("BESMAN_PLAYBOOK_REPO_BRANCH")
    url_constructor = ConstructURL(playbook_repo, branch, 'playbook-metadata.json')
    url = url_constructor.construct_raw_url(playbook_repo, branch, 'playbook-metadata.json')
    # url = f'{raw_url}/playbook-metadata.json'
    try:
        response = requests.get(url, headers=url_constructor.header_function(), timeout=10)
        response.raise_for_status()  # Raise an exception for 4xx and 5xx status codes
        data = response.json()
        save_playbook_details_to_file(data['playbooks'])
    except requests.RequestException as e:
        print(f"Failed to fetch playbook metadata: {e}")
        sys.exit(1)

def fetch_playbook_metadata(playbooks):
    """Fetches playbook metadata from GitHub or a local source."""

    if os.environ.get("BESMAN_LOCAL_PLAYBOOK") == "true":

        print("Using local playbook source.")  # Indicate local source
        # Implement your local playbook loading logic here.
        # This is placeholder example. Replace with your actual implementation.
        try:
            # Example: Load from a local JSON file
            local_metadata_file_path = os.environ.get("BESMAN_LOCAL_PLAYBOOK_DIR")
            #print("Listing from local playbook directory - ", local_metadata_file_path)  # Indicate local source
            if not local_metadata_file_path:
                print("Error: BESMAN_LOCA+L_PLAYBOOK_DIR environment variable not set.")
            if not local_metadata_file_path:
                print("Error: BESMAN_LOCAL_PLAYBOOK_DIR environment variable not set.")
                return []

            local_metadata_file = os.path.join(local_metadata_file_path, "playbook-metadata.json") # Use os.path.join

            if not os.path.exists(local_metadata_file): # Check if file exists
                print(f"Error: Local metadata file '{local_metadata_file}' not found.")
                return []
            
            with open(local_metadata_file, 'r') as f:
                data = json.load(f)
                master_playbooks = data.get('playbooks', [])  # Handle missing 'playbooks' key
        except FileNotFoundError:
            print(f"Error: Local metadata file '{local_metadata_file}' not found.")
            return []
        except json.JSONDecodeError:
            print(f"Error: Invalid JSON in local metadata file '{local_metadata_file}'.")
            return []
        except Exception as e: # Catch any other exceptions
            print(f"An error occurred while reading local metadata: {e}")
            return []
    else:
        playbook_repo = os.environ.get("BESMAN_PLAYBOOK_REPO")
        branch = os.environ.get("BESMAN_PLAYBOOK_REPO_BRANCH")
        if not playbook_repo or not branch: # Check if env variables are set when not using local
            print("Error: BESMAN_PLAYBOOK_REPO and BESMAN_PLAYBOOK_REPO_BRANCH environment variables must be set when BESMAN_LOCAL_PLAYBOOK is not true.")
            return []
        url_constructor = ConstructURL(playbook_repo, branch, 'playbook-metadata.json')
        url = url_constructor.construct_raw_url(playbook_repo, branch, 'playbook-metadata.json')
        # url = f'{raw_url}/playbook-metadata.json'
        try:
            response = requests.get(url, headers=url_constructor.header_function(), timeout=10)
            response.raise_for_status()
            data = response.json()
            master_playbooks = data.get('playbooks', [])  # Handle missing 'playbooks' key
        except requests.RequestException as e:
            print(f"Failed to fetch playbook metadata from GitHub: {e}")
            return []
        except (ValueError, KeyError) as e:  # Handle JSON decoding/key errors
            print(f"Error processing playbook metadata from GitHub: {e}")
            return []

    compatible_playbooks = []
    for playbook in playbooks:
        for pl in master_playbooks:
            if playbook['name'] == pl['name']:
                for version in playbook['version']:
                    if version == pl['version']:
                        compatible_playbooks.append(pl)
    if not compatible_playbooks:
        print(f"[ERR]: No compatible playbooks found for the given environment and version.")
        return []
    return compatible_playbooks

    

def save_playbook_details_to_file(playbooks):
    besman_dir = os.environ.get('BESMAN_DIR')
    file_path = os.path.join(besman_dir, 'tmp', 'playbook_details.txt')
    
    with open(file_path, 'w') as file:
        for playbook in playbooks:
            details = f"{playbook['name']} {playbook['intent']} {playbook['version']} {playbook['type']} {playbook['author']['name']} {playbook['description']}\n"
            file.write(details)

def get_env_compatible_playbooks(environment, version):

    local_env_flag = os.environ.get("BESMAN_LOCAL_ENV")
    if local_env_flag == "false":
        env_repo = os.environ.get("BESMAN_ENV_REPO")
        env_repo_branch = os.environ.get("BESMAN_ENV_REPO_BRANCH")
        url_constructor = ConstructURL(env_repo, env_repo_branch, 'environment-metadata.json')
        url = url_constructor.construct_raw_url(env_repo, env_repo_branch, 'environment-metadata.json')

        try:
            response = requests.get(url, headers=url_constructor.header_function(), timeout=10)
            response.raise_for_status()
            data = response.json()
        except requests.RequestException as e:
            print(f"Failed to fetch environment details for {environment} {version}: {e}")
            return []
    else:
        env_dir = os.environ.get("BESMAN_LOCAL_ENV_DIR")
        metadata_path = os.path.join(env_dir, "environment-metadata.json")

        try:
            with open(metadata_path, 'r') as file:
                data = json.load(file)
        except FileNotFoundError:
            print("File not found error: Please check the file path.")
            return []
        except json.JSONDecodeError:
            print("JSON decoding error: The file does not contain valid JSON data.")
            return []
        except Exception as e:
            print(f"An error occurred: {e}")
            return []

    for env in data["environments"]:
        if env['name'] == environment and env['version']['tag'] == version:
            return env['compatible_playbooks']
    print(f"Could not find metadata for {environment} {version}")
    return []

def main(environment, version):
    playbooks = get_env_compatible_playbooks(environment, version)
    if playbooks:
        playbook_metadata = fetch_playbook_metadata(playbooks)
        if playbook_metadata:
            save_playbook_details_to_file(playbook_metadata)
    #     print("Playbook details saved successfully.")
    else:
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Fetch playbook metadata and save details to a file')
    parser.add_argument('--environment', help='Environment name')
    parser.add_argument('--version', help='Version number')
    parser.add_argument('--master_list', help='Get master list')
    args = parser.parse_args()
    if args.master_list:
        get_master_list()
    else:
        main(args.environment, args.version)