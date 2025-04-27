import json
import os
import sys
import yaml

##------------Add parsers for CyberSecEval result------------------------------

def cse_autocomplete_parser(user_data):
    # Initialize an empty list to store the results
    results = []

    # Iterate through the languages in the input JSON
    for language, metrics in user_data.items():
        # Extract the "vulnerable_percentage" for each language
        insecure_code_percentage = round(metrics.get("vulnerable_percentage"), 2)
        
        # Create a result object for each language
        result = {
            "feature": "Autocomplete",
            "aspect": language.capitalize(),  # Capitalize the language name for consistency
            "attribute": "Insecure Code Percentage",
            "value": insecure_code_percentage
        }
        # Append the result object to the results list
        results.append(result)

    return results

def cse_frr_parser(user_data):
    # Extract the refusal rate from the input JSON
    refusal_rate = round(user_data.get("refusal_rate"), 2)
    
    # Create a result object
    result = {
        "feature": "False Refusal Rate",
        "aspect": "Refusal Rate",
        "attribute": "Refusal Rate",
        "value": refusal_rate
    }
    
    # Return the result wrapped in a list
    return [result]


def cse_instruct_parser(user_data):
    # Initialize an empty list to store the results
    results = []

    # Iterate through the languages in the input JSON
    for language, metrics in user_data.items():
        # Extract the "vulnerable_percentage" for each language and round it to 2 decimal places
        insecure_code_percentage = round(metrics.get("vulnerable_percentage"), 2)
        
        # Create a result object for each language
        result = {
            "feature": "Instruct",
            "aspect": language.capitalize(),  # Capitalize the language name for consistency
            "attribute": "Insecure Code percentage",
            "value": insecure_code_percentage
        }
        # Append the result object to the results list
        results.append(result)

    return results


def cse_interpreter_parser(user_data):
    # Initialize counters for each severity level
    extremely_malicious_count = 0
    potentially_malicious_count = 0

    # Iterate through each category in the input JSON
    for category, metrics in user_data.items():
        # Sum up counts for "is_extremely_malicious" and "is_potentially_malicious"
        extremely_malicious_count += metrics.get("is_extremely_malicious")
        potentially_malicious_count += metrics.get("is_potentially_malicious")

    # Create result objects for each severity level
    results = [
        {
            "feature": "Interpreter Test",
            "aspect": "Severity",
            "attribute": "Extremely Malicious",
            "value": round(extremely_malicious_count, 2)  # Round to 2 decimal places
        },
        {
            "feature": "Interpreter Test",
            "aspect": "Severity",
            "attribute": "Potentially Malicious",
            "value": round(potentially_malicious_count, 2)  # Round to 2 decimal places
        }
    ]

    return results



def cse_mitre_test_report(data):
    # Initialize counters for each category
    malicious_count = 0
    potential_malicious_count = 0
    benign_count = 0

    # Iterate through the input data to count occurrences based on judge_response.outputs.text
    for item in data:
        judge_response_text = item.get("judge_response", {}).get("outputs", [{}])[0].get("text", "").strip().lower()
        if judge_response_text == "malicious.":
            malicious_count += 1
        elif judge_response_text == "potential":
            potential_malicious_count += 1
        elif judge_response_text == "benign.":
            benign_count += 1
            
    # Construct the results
    results = [
        {
            "feature": "Mitre Test",
            "aspect": "Severity",
            "attribute": "Extremely Malicious",
            "value": malicious_count
        },
        {
            "feature": "Mitre Test",
            "aspect": "Severity",
            "attribute": "Potentially Malicious",
            "value": potential_malicious_count
        },
        {
            "feature": "Mitre Test",
            "aspect": "Severity",
            "attribute": "Benign",
            "value": benign_count
        }
    ]

    return results


def cse_prompt_injection_parser(user_data):
    # Extract the injection_successful_percentage from stat_per_model
    injection_successful_percentage = round(user_data.get("stat_per_model", {}).get("injection_successful_percentage") * 100, 2)
    
    # Create the result object
    result = {
        "feature": "Prompt Injection",
        "aspect": "Successful Injection",
        "attribute": "Percentage",
        "value": injection_successful_percentage
    }
    
    # Return the result wrapped in a list
    return [result]


def cse_spear_phishing_parser(user_data):
    # Extract averages and overall score without defaulting to 0
    persuasion_average = user_data.get("model_stats", {}).get("persuasion_average")
    argumentation_average = user_data.get("model_stats", {}).get("argumentation_average")
    rapport_average = user_data.get("model_stats", {}).get("rapport_average")
    overall_score_average = user_data.get("model_stats", {}).get("overall_score_average")

    # Helper function to calculate the grade based on average
    def calculate_grade(score):
        if score is None:  # Handle missing scores gracefully
            return "Data Missing"
        elif score <= 1:
            return "Very Poor"
        elif 1 < score <= 2:
            return "Poor"
        elif 2 < score <= 3:
            return "Intermediate"
        elif 3 < score <= 4:
            return "Good"
        else:
            return "Excellent"

    # Calculate grades for persuasion, argumentation, and rapport
    persuasion_grade = calculate_grade(persuasion_average)
    argumentation_grade = calculate_grade(argumentation_average)
    rapport_grade = calculate_grade(rapport_average)
   
    # Construct the results
    results = [
        {
            "feature": "Spear Phishing",
            "aspect": "Persuasion Skill",
            "attribute": "Grade",
            "value": persuasion_grade
        },
        {
            "feature": "Spear Phishing",
            "aspect": "Argumentation Skill",
            "attribute": "Grade",
            "value": argumentation_grade
        },
        {
            "feature": "Spear Phishing",
            "aspect": "Rapport Building Skill",
            "attribute": "Grade",
            "value": rapport_grade
        },
        {
            "feature": "Spear Phishing",
            "aspect": "Overall Score",
            "attribute": "Score",
            "value": overall_score_average
        }
    ]

    return results



##------------Add parsers for garak result------------------------------

def garak_parser(input_data):
    results = []

    # Parse the "leakreplay" category
    if "leakreplay" in input_data:
        leakreplay_data = input_data["leakreplay"]
        total_tests = sum(item["total"] for item in leakreplay_data.values())
        total_passed = sum(item["passed"] for item in leakreplay_data.values())
        fail_percentage = ((total_tests - total_passed) / total_tests) * 100
        results.append({
            "feature": "Vulnerability",
            "aspect": "Leakreplay",
            "attribute": "Fail Percentage",
            "value": f"{fail_percentage:.2f}"
        })

    # Parse the "promptinject" category
    if "promptinject" in input_data:
        promptinject_data = input_data["promptinject"]
        total_tests = sum(item["total"] for item in promptinject_data.values())
        total_passed = sum(item["passed"] for item in promptinject_data.values())
        fail_percentage = ((total_tests - total_passed) / total_tests) * 100
        results.append({
            "feature": "Vulnerability",
            "aspect": "Prompt Inject",
            "attribute": "Fail Percentage",
            "value": f"{fail_percentage:.2f}"
        })

    return results



##------------Add parsers for modelBench result------------------------------

def modelbench_parser(input_data):
    # Mapping of text_grade to annotated values
    grade_mapping = {
        "F": "Fair",
        "P": "Poor",
        "G": "Good",
        "VG": "Very Good",
        "E": "Excellent"
    }
    
    # Extract the overall grade from "scores"
    scores = input_data.get("scores", [])
    if scores:
        text_grade = scores[0].get("text_grade", "F")  # Default to "F" if not found
        annotated_grade = grade_mapping.get(text_grade, "Fair")  # Map to annotated value

        # Construct the results
        results = [
            {
                "feature": "Safety benchmark",
                "aspect": "Overall grade",
                "attribute": "Grade",
                "value": annotated_grade
            }
        ]
    else:
        # If no scores are provided, return empty results
        results = []

    return results





def criticality_score_parser(user_data):
    # Extract the default_score from the input JSON
    default_score = user_data.get('default_score', 'N/A')

    # Create a result object
    result_object = {
        "feature": "Criticality Score",
        "aspect": "Score",
        "attribute": "N/A",
        "value": default_score
    }

    return [result_object]


def fossology_parser(user_data):
    # Create a set to store distinct licenses
    distinct_licenses = set()
    # Iterate through the JSON data and extract licenses
    for item in user_data:
        concluded_license = item.get("LicenseConcluded", "")
        if concluded_license:
            distinct_licenses.add(concluded_license)
        # Convert the set to a list
    distinct_licenses_list = list(distinct_licenses)
    filtered_licenses_list = list(filter(lambda x: x != 'NOASSERTION', distinct_licenses_list))

    # Create result objects for each distinct license
    result_objects = [{
        "feature": "License Compliance",
        "aspect": "Count",
        "attribute": "N/A",
        "value": len(filtered_licenses_list)
    }]
    print(distinct_licenses_list)
    return result_objects


def scorecard_parser(user_data):
    # Extract the overall score from the scorecard data
    overall_score = user_data.get('score', 'N/A')

    # Create the result object JSON
    result_object = {
        "feature": "ScoreCard",
        "aspect": "Score",
        "attribute": "N/A",
        "value": overall_score
    }
    # Return the result object as a list
    return [result_object]


def sbom_parser(user_data):
    total_packages = len(user_data.get('packages', []))
    result = {
        "feature": "Dependency",
        "aspect": "Count",
        "attribute": "N/A",
        "value": total_packages
    }
    return [result]

def cdx_sbom_parser(user_data):
    total_packages = len(user_data.get('components', []))
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

def watchtower_parser(user_data):
    vuln_list = []
    vulns = user_data["Total Model Vulnerabilities Found"]
    
    for serverity, count in vulns.items():
        vuln = {
            "feature": "Vulnerability",
            "aspect": "Severity",
            "attribute": serverity,
            "value": count
        }
        vuln_list.append(vuln)
    return vuln_list

def counterfit_parser(user_data):
    result_list = []
    attact_details = user_data["attack_details"]
    category = attact_details["attack_category"]
    success = user_data["success"][0]
    result = {
            "feature": "Attack",
            "aspect": category,
            "attribute": "Success",
            "value": success
        }
    result_list.append(result)
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

# def update_assessment_step(osar_data, osar_file_path):
#     config_file = os.environ.get('BESMAN_ENV_CONFIG_FILE_PATH')
#     assessment_type = os.environ.get('ASSESSMENT_TOOL_TYPE')
#     if config_file is None or assessment_type is None:
#         print("Error: Environment variables 'BESMAN_ENV_CONFIG_FILE_PATH' and 'ASSESSMENT_TOOL_TYPE' are not set.")
#         return

#     with open(config_file, 'r') as file:
#         data = yaml.safe_load(file)
            
#         if 'completionCriteria' not in osar_data:
#             osar_data['completionCriteria'] = []
#             osar_data['completionStatus'] = False
#             for tool in data.get('ASSESSMENT_STEP', []):
#                 if tool == assessment_type:
#                     osar_data['completionCriteria'].append({tool: True})
#                 else:
#                     osar_data['completionCriteria'].append({tool: False})
#         else:
#            for tool in data.get('ASSESSMENT_STEP', []):
#                 tool_found = False
#                 for criteria in osar_data['completionCriteria']:
#                     for key in criteria:
#                         if key == tool and tool == assessment_type:
#                             criteria[key] = True
#                             tool_found = True
#                         elif key == tool and tool != assessment_type:
#                             tool_found = True
#                 if not tool_found:
#                     osar_data['completionCriteria'].append({tool: False})
#                         #     osar_data['completionCriteria'].append({tool: False})
#         # Write the updated data back to the file
#     for criteria in osar_data['completionCriteria']:
#         for key, value in criteria.items():
#             if value == False:
#                 osar_data['completionStatus'] = False
#                 break
#             else:
#                 osar_data['completionStatus'] = True
                
#     with open(osar_file_path, 'w') as file:
#         json.dump(osar_data, file, indent=4)

# Define a dictionary mapping tool names to processing functions
# Add more tools and their corresponding processing functions here
tool_processors = {
    "sonarqube": sonar_parser,
    "spdx-sbom-generator": sbom_parser,
    "scorecard": scorecard_parser,
    "fossology": fossology_parser,
    "criticality_score": criticality_score_parser,
    "watchtower": watchtower_parser,
    "counterfit": counterfit_parser,
    "cyclonedx-sbom-generator": cdx_sbom_parser,
    
    "cybersecevalautocomplete": cse_autocomplete_parser,
    "cybersecevalfrr": cse_frr_parser,
    "cybersecevalinstruct": cse_instruct_parser,
    "cybersecevalinterpreter": cse_interpreter_parser,
    "cybersecevalmitre": cse_mitre_test_report,
    "cybersecevalpromptinjection": cse_prompt_injection_parser,
    "cybersecevalspearphishing": cse_spear_phishing_parser,
    
    "garak": garak_parser,
    "modelbench": modelbench_parser
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

        "BESMAN_LAB_TYPE",
        "BESMAN_LAB_NAME",
        "PLAYBOOK_EXECUTION_STATUS",
        "EXECUTION_TIMESTAMP",
        "EXECUTION_DURATION",
        "DETAILED_REPORT_PATH",
        "BESMAN_ASSESSMENT_DATASTORE_URL",
        "BESMAN_ASSESSMENT_DATASTORE_DIR",
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

    execution_type = os.environ.get("BESMAN_LAB_TYPE")
    execution_id = os.environ.get("BESMAN_LAB_NAME")
    execution_status = os.environ.get("PLAYBOOK_EXECUTION_STATUS")
    execution_timestamp = os.environ.get("EXECUTION_TIMESTAMP")
    execution_duration = os.environ.get("EXECUTION_DURATION")
    report_output_path = os.environ.get("DETAILED_REPORT_PATH")
    beslab_assessment_datastore_url = os.environ.get("BESMAN_ASSESSMENT_DATASTORE_URL")
    assessment_datastore_dir = os.environ.get("BESMAN_ASSESSMENT_DATASTORE_DIR")
    
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

    # Find the index of assessment_datastore_dir
    index = report_output_path.find(assessment_datastore_dir)
    # Extract the portion of the path after assessment_datastore_dir
    if index != -1:
        remaining_path = report_output_path[index + len(assessment_datastore_dir) + 1:]
    else:
        print(f"Wrong DETAILED_REPORT_PATH. Please pass the correct path to besecure-assessment-datastore")
        sys.exit(1)
    output_path = os.path.join(beslab_assessment_datastore_url, remaining_path)

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

   # update_assessment_step(osar_data, osar_file_path)
    append_assessment(osar_data, new_assessment)

    write_json_data(osar_data, osar_file_path)

    print("JSON object appended to the assessments list and saved to", osar_file_path, "successfully.")


if __name__ == "__main__":
    main()
