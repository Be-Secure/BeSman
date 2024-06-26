import requests
import os

# Get environment variables
env_repo = os.environ.get("BESMAN_ENV_REPO")
branch = os.environ.get("BESMAN_ENV_REPO_BRANCH")
besman_dir = os.environ.get("BESMAN_DIR")

# Construct the URL
url = f'https://raw.githubusercontent.com/{env_repo}/{branch}/environment-metadata.json'

try:
    # Make the request
    response = requests.get(url)
    response.raise_for_status()  # Raise an exception for bad responses (4xx or 5xx)

    # Parse JSON response
    data = response.json()

    # print(data["environments"])
    # Open file for writing
    extracted_info = []
    for environment in data.get('environments', []):
        name = environment.get('name')
        author_name = environment.get('author', {}).get('name')
        version_tags = [version.get('tag') for version in environment.get('version', [])]

        for tag in version_tags:
            extracted_info.append(f"{name} {tag} {author_name}")

    print(extracted_info)
    # Write the extracted information to a file
    with open(f"{besman_dir}/tmp/environment_details.txt", "w") as tmp_file:
        tmp_file.write("\n".join(extracted_info))

    print("Playbook details written successfully.")
except requests.exceptions.RequestException as e:
    print(f"Error fetching data: {e}")
except (KeyError, TypeError) as e:
    print(f"Error parsing JSON: {e}")
except IOError as e:
    print(f"Error writing to file: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")

