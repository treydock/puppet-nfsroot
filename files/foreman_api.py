#!/usr/bin/env python

import json
import requests
import sys
from getpass import getuser
from urlparse import urljoin
from requests_oauthlib import OAuth1

# Disable SSL warnings
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

class ForemanAPI(object):
    def __init__(self, url):
        self.api_auth = None
        self.url = url
        self.headers = {
            'Accept': 'version=2,application/json',
            'Content-Type': 'application/json',
        }

    def auth(self, oauth_key=None, oauth_secret=None, oauth_user=None, user=None, password=None):
        auth = None
        if oauth_key and oauth_secret:
            auth = OAuth1(oauth_key, oauth_secret)
            if getuser() == 'root' and oauth_user:
                self.headers['FOREMAN_USER'] = oauth_user
            else:
                self.headers['FOREMAN_USER'] = getuser()
        elif user and password:
            auth = requests.auth.HTTPBasicAuth(user, password)
        self.api_auth = auth

    def get_data(self, path, params=None, paged=False):
        results = []
        query = True
        page = 1
        per_page = 500
        url = urljoin(self.url, path)
        while query:
            if paged:
                if params:
                    params['page'] = page
                    params['per_page'] = per_page
                else:
                    params = {'page': page, 'per_page': per_page}
            get_r = requests.get(url, params=params, headers=self.headers, auth=self.api_auth, verify=False)
            if get_r.status_code == requests.codes.ok:
                json_data = get_r.json()
                #print json.dumps(json_data, sort_keys=True, indent=4)
                if 'results' in json_data:
                    data = json_data.get('results')
                    if data:
                        results = results + data
                        # Force end of while loop if not doing paging
                        if not paged:
                            query = False
                    else:
                        query = False
                else:
                    if not results:
                        results = json_data
                    query = False
            else:
                if get_r.status_code == 404:
                    sys.stderr.write("ERROR: URL %s not found, 404\n" % url)
                    return None
                json_data = get_r.json()
                print json.dumps(json_data, sort_keys=True, indent=4)
                message = ''
                details = ''
                if 'error' in json_data:
                    if 'message' in json_data['error']:
                        message = json_data['error']['message']
                    if 'details' in json_data['error']:
                        details = json_data['error']['details']
                sys.stderr.write("ERROR: Failed to query %s, message=%s, details=%s\n" % (url, message, details))
                return None
            page += 1
        return results

    def send_data(self, path, data, method='put'):
        _data = json.dumps(data)
        url = urljoin(self.url, path)
        if method == 'put':
            send_r = requests.put(url, data=_data, headers=self.headers, auth=self.api_auth, verify=False)
        elif method == 'post':
            send_r = requests.post(url, data=_data, headers=self.headers, auth=self.api_auth, verify=False)
        if send_r.status_code in [200, 201]:
            json_data = send_r.json()
        else:
            if send_r.status_code == 404:
                sys.stderr.write("ERROR: URL %s not found, 404\n" % url)
                return None
            json_data = send_r.json()
            message = ''
            details = ''
            if 'error' in json_data:
                if 'message' in json_data['error']:
                    message = json_data['error']['message']
                if 'full_messages' in json_data['error']:
                    message = json_data['error']['full_messages']
                if 'details' in json_data['error']:
                    details = json_data['error']['details']
            sys.stderr.write("ERROR: Failed to update %s, message=%s, details=%s \n" % (url, message, details))
            return None
        return json_data

    def delete_data(self, path):
        url = urljoin(self.url, path)
        delete_r = requests.delete(url, headers=self.headers, auth=self.api_auth, verify=False)
        if delete_r.status_code == requests.codes.ok:
            json_data = delete_r.json()
        else:
            if delete_r.status_code == 404:
                sys.stderr.write("ERROR: URL %s not found, 404\n" % url)
                return None
            json_data = delete_r.json()
            message = ''
            details = ''
            if 'error' in json_data:
                if 'message' in json_data['error']:
                    message = json_data['error']['message']
                if 'details' in json_data['error']:
                    details = json_data['error']['details']
            sys.stderr.write("ERROR: Failed to delete %s, message=%s, details=%s \n" % (url, message, details))
            return None
        return json_data
