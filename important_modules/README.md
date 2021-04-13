# IMP modules in Ansible

> ### We will look into following mostly used modules.

1. uri
2. shell
3. lineinfile module
4. file
5. service
6. template
7. fetch


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

* At times we want to insert a line after any specific pattern. This is the time when  ```insertafter``` and ```insertbefore``` comes into picture.
* In the below exaample a line is inserted after ```[defaults]``` in ansible.cfg file. ``'[' and ']'`` are escaped as they are special regex characters.

```YAML
- name: example of insertafter uisng lineinfile module
  lineinfile: 
    dest: /etc/ansible/ansible.cfg    # path of file
    # line to be inserted
    line: 'inventory = home/device1/inventory.ini'
    insertafter: '\[defaults\]'

```

* If we want to insert a line before any pattern then we can use ```insertbefore``` parameter.
* The following example will insert a line before the pattern '#library'  in ansible.cfg.


```YAML

- name: example of insertbefore using lineinfile module
  lineinfile:
    dest: /etc/ansible/ansible.cfg
    line: 'inventory = /home/device1/inventiry.ini'
    insertbefore: '#library'

```

**Removing a line:**

* We have to set the state parameter to ```absent```, to remove the lines specified. All the occurrences of that line will be removed.

```YAML
- hosts: loc
  tasks:
    - name: Ansible lineinfile remove line example
      lineinfile:
        dest: /home/device1/remote_server.txt
        line: Removed lines.
        state: absent
```

**Removing a line using REGEXP:**

* we can also specify a regexp to remove a line. We can remove all lines that start with 'hello'.
* We give the regular expression using lineinfile regexp parameter.
* The following example will remove all lines starting with azure.

```YAML

- hosts: loc
  tasks:
    - name: remove line using regexp
      lineinfile:
        dest: /home/device1/remote_server.txt
        regexp: "^azure"
        state: absent

```


**Replacing OR modifying a line using RegExp:**

* To perform this we need to use backrefs parameter along with regexp parameter. It should be used with state=present.
* If the regexp do not match any line then the file is not changed.
* If it matches multiple lines then the last matched line will be replaced.
* Also, the grouped elements in regexp are populated and can be used for modification

<p>

In the below example we are commenting a line. The full line is captured line by placing them inside the parenthesis to ‘\1’. The ‘#\1’ replaces the line with ‘#’ followed by what was captured.

You can have multiple captures and call them by using ‘\1’, ‘\2’, ‘\3’ etc. If you need to learn more information on grouping, refer [regular expression info](http://www.regular-expressions.info/brackets.html)

</p>

> Commenting a line with Ansible lineinfile backrefs

```YAML
- name: Ansible lineinfile regexp replace example
  lineinfile: 
    dest: /etc/ansible/ansible.cfg
    regexp: '(inventory = /home/linux/inventory.ini.*)'
    line: '#\1'
    backrefs: yes
```

> Uncommenting the line with lineinfile regexp

```YAML
- name: Ansible lineinfile backrefs example
  lineinfile: 
    dest: /etc/ansible/ansible.cfg
    regexp: '#(inventory = /home/linux/inventory.ini.*)'
    line: '\1'
    bacckrefs: yes   
```

<p>
  We can uncomment the same line with small modifications. Here I am placing the commented line with the ‘#’ outside the grouping. So now only the portion after ‘#’ is captured in \1. And after running the script, you can see the line is uncommented.
  
  </p>
  
**Lineinfile Multiple lines:**

* This section is for replacing multiple lineinfile tasks with a single task and using with_items.
*  If your intention is to add multiple lines to a file, you should use the [blockinfile module](https://docs.ansible.com/ansible/2.9/modules/blockinfile_module.html)
*  We can use with_items to loop throught list. We can specify dest, regexp, line, etc. for each task in the list.
*  Basically it's used instead of writing multiple tasks.

_Example:_

```YAML

- hosts: loc
  tasks:
  - name: Ansible lineinfile multiple lines with_items example
    lineinfile:
      dest: {{ item.dest }}
      regexp: {{ item.regexp }}
      line: {{ item.line }}
    with_items:
    - { dest: '/etc/asnsible/ansible.cfg', regexp: 'config file for ansible', line: 'line changes' }
    - { dest: '/home/device1/remote_server.txt', regexp: 'hello', line: 'world' }



```


