import sys
import json
import requests
jira_bugfix_type = '10203'

## Get Jira details
def get_jira_task_name(jira_server, jira_user, jira_pw, jira_key):
    url = jira_server + '/rest/api/2/issue/' + jira_key
    try:
        req = requests.get(url, auth=(jira_user, jira_pw), verify=False)
        if not req.status_code in range(200,206):
            print('Error connecting to Jira.. check config file')
            sys.exit()
        jira = req.json()
        task_type = jira["fields"]["issuetype"]["id"]
        task_name = jira["fields"]["summary"].encode('utf-8')
        return [task_type, task_name]
    except requests.exceptions.Timeout:
        return [jira_bugfix_type, 'title unavailable, request timeout']
    except requests.exceptions.RequestException as exep:
        # catastrophic error. bail.
        #print('error connecting to jira: ' + str(exep))
        return [jira_bugfix_type, 'title unavailable, jira connection error']
        

jira_server_arg = sys.argv[1]
jira_user_arg = sys.argv[2]
jira_password_arg = sys.argv[3]
jira_key_arg_strings = sys.argv[4:]

extracted_features = []
extracted_bugfixes = []
for jira_key_arg in jira_key_arg_strings:
    type_and_name = get_jira_task_name(jira_server_arg, jira_user_arg, jira_password_arg, jira_key_arg)
    task_string = jira_key_arg + ': ' + type_and_name[1]
    if type_and_name[0] == jira_bugfix_type:
        extracted_bugfixes.append(task_string)
    else:
        extracted_features.append(task_string)

output_string = ''
if len(extracted_features) > 0:
    output_string = "What's new:\n\n"
    output_string = output_string + '\n'.join(extracted_features)

if len(extracted_bugfixes) > 0:
    output_string = output_string + '\n\nFixes:\n\n'
    output_string = output_string + '\n'.join(extracted_bugfixes)
print output_string