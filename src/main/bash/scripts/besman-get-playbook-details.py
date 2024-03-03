import requests
import os

namespace = os.environ["BESMAN_NAMESPACE"]
url = f'https://raw.githubusercontent.com/{namespace}/besecure-playbooks-store/main/playbook-metadata.json'  
response = requests.get(url)
data = response.json()
besman_dir = os.environ['BESMAN_DIR']
tmp_file = open(f"{besman_dir}/tmp/playbook_details.txt", "w")

data = '\n'.join([playbook['name'] + " " + playbook['version'] + " " + playbook['type'] + " " + playbook['author']['name']  for playbook in data['playbooks']])

tmp_file.write(data)
tmp_file.close()
