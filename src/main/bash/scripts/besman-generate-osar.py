import json
import os
import sys
from datetime import datetime


def sbom_parser(user_data):
    total_packages = len(user_data.get('packages', []))
    result = {
        "feature": "Dependency",
        "aspect": "Count",
        "attribute": "N/A",
        "value": total_packages
    }
    return [result]


def count_severity(vul_list):
    severity_counts = {}

    # Count occurrences of each severity level
    for vul in vul_list:
        severity = vul["severity"]
        if severity in severity_counts:
            severity_counts[severity] += 1
        else:
            severity_counts[severity] = 1

    # Create list of objects with severity and count
    result_list = []
    for severity, count in severity_counts.items():
        result_list.append({"feature": "Vulnerability", "aspect": "Severity",
                            "attribute": severity, "value": count})

    return result_list


def sonar_parser(user_data):
    vul_list = []
    for issue in user_data.get('issues', []):
        tags = ','.join(issue.get('tags', []))

        vul = {
            "tool_name": "Sonarqube",
            "severity": issue.get("severity", 'N/A'),
            "message": issue.get("message", 'N/A'),
            "component": issue.get("component", 'N/A'),
            "tags": tags,
            "effort": issue.get("effort", 'N/A'),

        }
        vul_list.append(vul)
    result_list = count_severity(vul_list)
    return result_list


def read_json_file(filename):
    try:
        with open(filename, 'r') as f:
            json_data = f.read()
            if not json_data:
                print(f"Error: JSON file '{filename}' is empty.")
                return None
            return json.loads(json_data)
    except (FileNotFoundError, json.decoder.JSONDecodeError) as e:
        print(f"Error reading JSON file '{filename}': {e}")
        return None


def validate_env_variables(env_variables):
    for var in env_variables:
        if var not in os.environ:
            print(f"Error: Environment variable '{var}' is not set.")
            return False
    return True


def append_assessment(osar_data, new_assessment):
    tool_name = new_assessment["tool"]["name"]
    if "assessments" not in osar_data:
        osar_data["assessments"] = []
    for assessment in osar_data["assessments"]:
        if assessment["tool"]["name"] == tool_name:
            assessment.update(new_assessment)
            return
    osar_data["assessments"].append(new_assessment)


def write_json_data(osar_data, osar_file_path):
    with open(osar_file_path, 'w') as f:
        json.dump(osar_data, f, indent=4)


# Define a dictionary mapping tool names to processing functions
# Add more tools and their corresponding processing functions here
tool_processors = {
    "sonarqube": sonar_parser,
    "spdx-sbom-generator": sbom_parser
}


def main():
    # Define a list of required environment variables
    required_env_variables = [
        "BESMAN_ARTIFACT_TYPE",
        "BESMAN_ARTIFACT_NAME",
        "BESMAN_ARTIFACT_VERSION",
        "BESMAN_ARTIFACT_URL",
        "BESMAN_ENV_NAME",

        "ASSESSMENT_TOOL_NAME",
        "ASSESSMENT_TOOL_TYPE",
        "ASSESSMENT_TOOL_VERSION",
        "ASSESSMENT_TOOL_PLAYBOOK",

        "BESMAN_LAB_OWNER_TYPE",
        "BESMAN_LAB_OWNER_NAME",
        "PLAYBOOK_EXECUTION_STATUS",
        "EXECUTION_TIMESTAMP",
        "EXECUTION_DURATION",
        "DETAILED_REPORT_PATH",
        "BESMAN_ASSESSMENT_DATASTORE_URL",

        "OSAR_PATH"
    ]

    # Validate if all required environment variables are set
    if not validate_env_variables(required_env_variables):
        sys.exit(1)

    # Retrieve values from environment variables
    asset_type = os.environ.get("BESMAN_ARTIFACT_TYPE")
    asset_name = os.environ.get("BESMAN_ARTIFACT_NAME")
    asset_version = os.environ.get("BESMAN_ARTIFACT_VERSION")
    asset_url = os.environ.get("BESMAN_ARTIFACT_URL")
    environment = os.environ.get("BESMAN_ENV_NAME")

    tool_name = os.environ.get("ASSESSMENT_TOOL_NAME")
    tool_type = os.environ.get("ASSESSMENT_TOOL_TYPE")
    tool_version = os.environ.get("ASSESSMENT_TOOL_VERSION")
    playbook = os.environ.get("ASSESSMENT_TOOL_PLAYBOOK")

    execution_type = os.environ.get("BESMAN_LAB_OWNER_TYPE")
    execution_id = os.environ.get("BESMAN_LAB_OWNER_NAME")
    execution_status = os.environ.get("PLAYBOOK_EXECUTION_STATUS")
    execution_timestamp = os.environ.get("EXECUTION_TIMESTAMP")
    execution_duration = os.environ.get("EXECUTION_DURATION")
    report_output_path = os.environ.get("DETAILED_REPORT_PATH")
    BESMAN_ASSESSMENT_DATASTORE_URL = os.environ.get("BESMAN_ASSESSMENT_DATASTORE_URL")

    osar_path = os.environ.get("OSAR_PATH")

    # Read and parse the JSON file(user data e.g. sonar-scan-json, snyk, sbom etc...) specified by report_output_path
    output_json_data = read_json_file(report_output_path)
    if output_json_data is None:
        print("Unable to read or parse the specified JSON file. Please validate the report json file")
        sys.exit(1)

    # Check the tool_name_arg for case-insensitive comparison
    if tool_name.lower() in tool_processors:
        # Perform processing on output_json_data as needed
        user_data = tool_processors[tool_name.lower()](output_json_data)
    else:
        available_tools = ", ".join(tool_processors.keys())
        print(f"Unsupported tool_name. Available tools support : {available_tools}")
        sys.exit(1)

    # Find the index of "besecure-assessment-datastore"
    index = report_output_path.find("besecure-assessment-datastore")
    # Extract the portion of the path after "besecure-assessment-datastore"
    if index != -1:
        remaining_path = report_output_path[index + len("besecure-assessment-datastore") + 1:]
    else:
        print(f"Wrong DETAILED_REPORT_PATH. Please pass the correct path to besecure-assessment-datastore")
        sys.exit(1)
    output_path = os.path.join(BESMAN_ASSESSMENT_DATASTORE_URL, remaining_path)

    new_assessment = {
        "tool": {
            "name": tool_name,
            "type": tool_type,
            "version": tool_version,
            "playbook": playbook
        },
        "execution": {
            "type": execution_type,
            "id": execution_id,
            "status": execution_status,
            "timestamp": execution_timestamp,
            "duration": f"{execution_duration} sec",
            "output_path": output_path
        },
        "results": user_data
    }

    osar_file_path = os.path.abspath(osar_path)
    # Ensure the directory containing the osar file exists, creating it if necessary
    os.makedirs(os.path.dirname(osar_file_path), exist_ok=True)

    # Check if the file exists
    if not os.path.exists(osar_file_path):
        # Create an empty JSON structure
        osar_data = {'schema_version': "0.1.0", 'asset': {}}
    else:
        # Read existing JSON data from the file
        osar_data = read_json_file(osar_file_path)

    osar_data['asset'].update({
        "type": asset_type,
        "name": asset_name,
        "version": asset_version,
        "url": asset_url,
        "environment": environment
    })

    append_assessment(osar_data, new_assessment)

    write_json_data(osar_data, osar_file_path)

    print("JSON object appended to the assessments list and saved to", osar_file_path, "successfully.")


if __name__ == "__main__":
    main()
