#!/usr/bin/python
# -*- coding: utf-8 -*-
#description  :CI/CD скрипт для создания комментария на указанный список JIRA задач
#author       :Azamat Kalmurzayev
#usage        :python ci_post_task_comments.py JIRA_HOST JIRA_USER JIRA_PSWD COMMENT_TEXT JIRA_TASK_IDS...
#===================================================================

import sys
import json
import requests

## Posts a comment text on specified JIRA issue 
def post_jira_comment(jira_server, jira_user, jira_pw, jira_key, jira_comment):
    url = jira_server + '/rest/api/2/issue/' + jira_key + '/comment'
    try:
        headers = {
           "Accept": "application/json",
           "Content-Type": "application/json"
        }
        payload = json.dumps( {
            "body": jira_comment
        } )
        req = requests.post(url, auth=(jira_user, jira_pw), data=payload, headers=headers, verify=False)
        if not req.status_code in range(200,206):
            return (jira_key, req.status_code)
        return (jira_key, "sent")
    except requests.exceptions.Timeout:
        return (jira_key, "request timeout")
    except requests.exceptions.RequestException as exep:
        return (jira_key, "request exception")

## Python script parameters 
jira_server_arg = sys.argv[1]
jira_user_arg = sys.argv[2]
jira_password_arg = sys.argv[3]
jira_comment_text = sys.argv[4]
jira_key_arg_strings = sys.argv[5:]

for jira_key_arg in jira_key_arg_strings:
    jira_issue_tuple = post_jira_comment(jira_server_arg, jira_user_arg, jira_password_arg, jira_key_arg, jira_comment_text)
    print jira_issue_tuple[0] + ': ' + str(jira_issue_tuple[1])
