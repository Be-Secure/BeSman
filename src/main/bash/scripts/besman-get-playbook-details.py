import argparse
import requests
import os
import json
import sys
def get_master_list():
    playbook_repo = os.environ.get("BESMAN_PLAYBOOK_REPO")
    branch = os.environ.get("BESMAN_PLAYBOOK_REPO_BRANCH")
    url = f'https://raw.githubusercontent.com/{playbook_repo}/{branch}/playbook-metadata.json'
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for 4xx and 5xx status codes
        data = response.json()
        save_playbook_details_to_file(data['playbooks'])
    except requests.RequestException as e:
        print(f"Failed to fetch playbook metadata: {e}")
        sys.exit(1)

def fetch_playbook_metadata(playbooks):
    playbook_repo = os.environ.get("BESMAN_PLAYBOOK_REPO")
    branch = os.environ.get("BESMAN_PLAYBOOK_REPO_BRANCH")
    url = f'https://raw.githubusercontent.com/{playbook_repo}/{branch}/playbook-metadata.json'
    compatible_playbooks = []
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for 4xx and 5xx status codes
        data = response.json()
        # return data['playbooks']
        master_playbooks = data['playbooks']
    except requests.RequestException as e:
        print(f"Failed to fetch playbook metadata: {e}")
        return []
    
    for playbook in playbooks:
        for pl in master_playbooks:
            if playbook['name'] == pl['name']:
                for version in playbook['version']:
                    if version == pl['version']:
                        compatible_playbooks.append(pl)
    # print(compatible_playbooks)
    return compatible_playbooks

    

def save_playbook_details_to_file(playbooks):
    besman_dir = os.environ.get('BESMAN_DIR')
    file_path = os.path.join(besman_dir, 'tmp', 'playbook_details.txt')
    
    with open(file_path, 'w') as file:
        for playbook in playbooks:
            details = f"{playbook['name']} {playbook['version']} {playbook['type']} {playbook['author']['name']}\n"
            file.write(details)

def get_env_compatible_playbooks(environment, version):

    local_env_flag = os.environ.get("BESMAN_LOCAL_ENV")
    if local_env_flag == "false":
        env_repo = os.environ.get("BESMAN_ENV_REPO")
        env_repo_branch = os.environ.get("BESMAN_ENV_REPO_BRANCH")
        url = f'https://raw.githubusercontent.com/{env_repo}/{env_repo_branch}/environment-metadata.json'

        try:
            response = requests.get(url)
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