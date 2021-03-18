# IMP modules in Ansible

> We will look into following mostly used modules.

1. uri
2. shell
3. lineinfile module
4. win_shell
5. file
6. win_file
7. service
8. template
9. fetch

__1. uri:__

* Interacts with HTTP and HTTPS web services and supports Digest, Basic and WSSE HTTP authentication mechanisms.

* For Windows targets, use the ansible.windows.win_uri module instead

For Example:

```YAML

- name: Check that you can connect (GET) to a page and it returns a status 200
  uri:
    url: http://www.example.com

```

```YAML
- name: Check that a page returns a status 200 and fail if the word AWESOME is not in the page contents
  uri:
    url: http://www.example.com
    return_content: yes
  register: this
  failed_when: "'AWESOME' not in this.content"

```

```YAML
- name: Connect to website using a previously stored cookie
  uri:
    url: https://your.form.based.auth.example.com/dashboard.php
    method: GET
    return_content: yes
    headers:
      Cookie: "{{ login.cookies_string }}"
```

```YAML
- name: Create a JIRA issue
  uri:
    url: https://your.jira.example.com/rest/api/2/issue/
    user: your_username
    password: your_pass
    method: POST
    body: "{{ lookup('file','issue.json') }}"
    force_basic_auth: yes
    status_code: 201
    body_format: json

```
* More info about (https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/201)[Status code 201] 



__2. Shell:__

* The ```shell``` module takes the command name followed by a list of space-delimited arguments
* either a free form command or ```cmd``` parameter is required.