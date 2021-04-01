# IMP modules in Ansible

> ### We will look into following mostly used modules.

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

_For Example:_

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
* More info about [Status code 201](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/201) 



__2. Shell:__

* The ```shell``` module takes the command name followed by a list of space-delimited arguments
* either a free form command or ```cmd``` parameter is required.
* Its almost like [ansible.builin.command](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html#ansible-collections-ansible-builtin-command-module)  module but runs thr command through a shell (/bin/sh) on remote node.

<hr>

> __Parameters__

<hr>

| Parameters | Use |
|--------|-------|
|   chdir (path)|  change into this directory before running the command|
|   cmd (string)  | the command to run followed by optional argument  |
|   creates (path)|A filename, when it already exists, this step will not run|
|executable (path) |change the shell module used to execute the command. This expects an absolute path to executable.|
| removes (path)| A filename,when it doesn't exists,this step will not run|
| stdin (string) |Set the stdin of the command directly to the specified value.|
| warn (boolean- no,yes) |Whether to enable task warnings.|
| stdin_add_newline (boolean- no,yes) | whether to append a newline to stdin data.|



_For Examples:_

```YAML
- name: Execute the command in remote shell; stdout goes to the specified file on the remote
  shell: somescript.sh >> somelog.txt

```

```YAML
- name: Change the working directory to somedir/  before exeuting the command
  shell: somescript.sh >> log.txt     #output stored in log.txt file 
  args:
    chdir: somedir/                     #change the directory

```

```YAML

-name: this command will change the working directory to somedir/and will only run when somedir/somelog.txt does not exists.
 shell: somescript.sh >> somelog.txt
 args:
   chdir: /somedir
   creates: somelog.txt


```

```YAML
- name: this command will change the working directory to somedir/
  shell:
    cmd: ls -l | grep log
    chdir: somedir/

```

__3. lineinfile:__ 

* Used to manage lines in text files

* Ansible lineinfile module can be used to insert a line, modify an existing line, remove an existing line or to replace a line.

* create parameter means if the file is absent on remote then it will create new file with the given name.

**Inserting a line:** 

* First, we will see how to write a line to a file if it's not present.

* we can set the path of the file to be modified by dest/path(Ansible verison > 2.3 ) parameter. Then  line will be inserted using the line parameter.

* The next example will write a line ```This line is written for test purpose"``` to the file ```"file_RemoteServer.txt"```.
* The new line will be added to EOF. If the line already exists, then it will not be added.

* We also have to set the ```create parameter``` which means if the file is absent then create a new file.
* The default value is present but I added it for more clarity.

```YAML

- hosts: local
  tasks:
    - name: example of inserting a line in file
      lineinfile: 
        dest: /home/device1/file_RemoteServer.txt
        line: This line is written for test purpose
        state: present
        create: yes

```
Isssue 1: 

* If you get the following error,

> lineinfile unsupported parameter for module: path

* It is probably due to the issue with path parameter. Till ansible 2.3 this parameter was ‘dest‘. 
* So if your ansible version is less than 2.3, then change the parameter to ‘dest‘. It should solve the issue

Issue 2: 

* If the destination file does not exist, then Ansible would throw an error like below. 
* You can either make sure the file exists in the remote file or you can set the ‘create‘ parameter to yes to solve this issue.

>  Destination /home/device1/file_RemoteServer.txt does not exist
<hr>

* create parameter means if the file is absent on remote then it will create new file with the given name.


**Inserting a line after/before a pattern:**

* At times we want to insert a line after any specific pattern. This the time when  ```insertafter``` and ```insertbefore``` comes into picture.
*  In the below exaample a line is inserted after ```[defaults]``` in ansible.cfg file.
*  ``'[' and ']'`` are escaped as they are special regex characters.

```YAML
- name: example of insertafter uisng lineinfile module
  lineinfile: 
    dest: /etc/ansible/ansible.cfg    # path of file
    # line to be inserted
    line: 'inventory = home/device1/inventory.ini'
    insertafter: '\[defaults\]'


```
