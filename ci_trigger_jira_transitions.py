import sys
import json
import requests

## POST request for performing issue transition specified by its ID for specified jira issue 
def post_jira_transition(jira_server, jira_user, jira_pw, jira_key, jira_transition):
    url = jira_server + '/rest/api/2/issue/' + jira_key + '/transitions'
    try:
        headers = {
           "Accept": "application/json",
           "Content-Type": "application/json"
        }
        payload = json.dumps( {
            "transition": {
                "id": jira_transition
            }
        } )
        req = requests.post(url, auth=(jira_user, jira_pw), data=payload, headers=headers, verify=False)
        if not req.status_code in range(200,206):
            return (jira_key, req.status_code)
        return (jira_key, "transitioned")
    except requests.exceptions.Timeout:
        return (jira_key, "request timeout")
    except requests.exceptions.RequestException as exep:
        return (jira_key, "request exception")


jira_server_arg = sys.argv[1]
jira_user_arg = sys.argv[2]
jira_password_arg = sys.argv[3]
jira_issue_transition_id = sys.argv[4]
jira_key_arg_strings = sys.argv[5:]

for jira_key_arg in jira_key_arg_strings:
    jira_issue_tuple = post_jira_transition(jira_server_arg, jira_user_arg, jira_password_arg, jira_key_arg, jira_issue_transition_id)
    print jira_issue_tuple[0] + ': ' + str(jira_issue_tuple[1])




