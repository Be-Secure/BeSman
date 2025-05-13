import os

class ConstructURL:
    def __init__(self, repo, branch):
        self.repo = repo
        self.branch = branch
    
    def construct_raw_url(self, repo, branch):
        platform = os.environ.get("BESMAN_CODE_COLLAB_PLATFORM")
        # https://raw.githubusercontent.com/{env_repo}/{branch}/environment-metadata.json
        # http://lab.o31e.com/{env_repo}/-/raw/{branch}/environment-metadata.json
        url = ""  # Initialize url with a default value
        if platform == "github":
            url = f'https://raw.githubusercontent.com/{repo}/{branch}'
        elif platform == "gitlab":
            platform_url = os.environ.get("BESMAN_CODE_COLLAB_URL")
            url = f'{platform_url}/{repo}/-/raw/{branch}'
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