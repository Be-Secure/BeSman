import os
from urllib.parse import quote

class ConstructURL:
    def __init__(self, repo, branch, file_path):
        self.repo = repo
        self.branch = branch
        self.file_path = file_path
    
    def construct_raw_url(self, repo, branch, file_path):
        platform = os.environ.get("BESMAN_CODE_COLLAB_PLATFORM")
        encoded_repo = quote(repo, safe='')
        encoded_file_path = quote(file_path, safe='')
        token = os.environ.get("BESMAN_ACCESS_TOKEN")
        # https://raw.githubusercontent.com/{env_repo}/{branch}/environment-metadata.json
        # http://gitlab.com/{env_repo}/-/raw/{branch}/environment-metadata.json
        url = ""  # Initialize url with a default value
        if platform == "github":
            url = f'https://raw.githubusercontent.com/{repo}/{branch}'
        elif platform == "gitlab":
            platform_url = os.environ.get("BESMAN_CODE_COLLAB_URL")
            if token is None:
                url = f'{platform_url}/{repo}/-/raw/{branch}/{file_path}'
            else:
                url = f'{platform_url}/api/v4/projects/{encoded_repo}/repository/files/{encoded_file_path}/raw?ref={branch}'
            # http://gitlab.com:8081/arun.suresh/besecure-ce-env-repo/-/raw/main/environment-metadata.json?ref_type=heads
            #http://gitlab.com/api/v4/projects/arun.suresh%2Fbesecure-ce-env-repo/repository/files/environment-metadata.json/raw?ref=main
        else:
            print(f"Error: Unsupported platform: {platform}")
        return url
    
    def header_function(self):
        headers = {}
        headers["User-Agent"] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        try:
            platform = os.environ.get("BESMAN_CODE_COLLAB_PLATFORM")
            token = os.environ.get("BESMAN_ACCESS_TOKEN")
            if platform == "github" and token is not None:
                headers['Authorization'] = f'token {token}'
            elif platform == "gitlab" and token is not None:
                headers['PRIVATE-TOKEN'] = token
        except KeyError:
            print("[Warn]: BESMAN_ACCESS_TOKEN environment variable is not set.")
        return headers