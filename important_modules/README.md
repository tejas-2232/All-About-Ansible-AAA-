
# Important modules in Ansible

![](https://miro.medium.com/max/5120/1*9z4jjgJZl_DyHaOEzP-wSw.jpeg)

> ### We will look into following popular modules.

1. uri
2. shell
3. lineinfile module
4. file
5. service
6. fetch
7. get_url
8. command
9. block
10. copy
11. set_fact
12. script
13. reboot
14. wait_for
15. delegate_to



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

* For windows systems, Ansible provides a similar module named win_shell, which mostly works the same way with limitations of Windows operating systems.

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

* For windows systems, Ansible provides a similar module named win_lineinfile, which mostly works the same way with limitations of Windows operating systems.

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


__4. File:__ 

* File module is mainly used to deal with files, directories, and symlinks.
* This module is used to manage properties and set or remove attributes of files, directories, and symlinks.
* For windows systems, Ansible provides a similar module named win_file, which mostly works the same way with limitations of Windows operating systems.

**How the File module works?**

* Ansible file module takes the parameters and options mentioned by you in playbooks. Then these are sent to target remote nodes where the tasks are parsed into command set and executed accordingly.

* In this module’s parameter, we must consider that all the execution will be done on remote target nodes, so when changing ownership of files, directories; relevant user and group must exist on remote target nodes, else notebook  execution will fail.

* So in such kind of cases, its always better to check user or group’s existence first on remote target nodes, then try to set ownership to those users or groups

__Some Important parameters of file module:__

* access_time: This parameter is used to set the file’s access Default is “preserve” means no modification needed for files, directories, soft links, and hard links. Also for new files where state is touch, then default is “now”.

* access_time_format: This is parameter is used when we are also using access_time This parameter is used to set the time format of access time of files. Default format is based on the default python-format on your remote machine. But mostly it is “%Y%m%d%H%M.%S”.
 
* attributes: To set the attributes of resulting directory or The acceptable flags are same as chattr. Which can be seen by using lsattr.

* follow: This is to set whether filesystems links should be followed or not. Default is yes. Acceptable values are yes and no.

* force: This is to force the creation of syslinks. Acceptable values are yes and no. default is yes.

* group: – This is used to set the group ownership of a file or diretory.

* mode: – To set the permission of target file or directory. Better practice is use 4 octal numbers inside single quotes to represent the permission like ‘0777’ or ‘0644’.

* modification_time: – To set the file’s modification time. Default is “preserve” means no modification needed for files, directories, soft links, and hard links. Also for new files where state is touch, then default is “now”.

* modification_time_format: – This is parameter is used when we are also using modification_time This parameter is used to set the format of modification time of files. Default format is based on the default python format on your remote machine. But mostly it is “%Y%m%d%H%M.%S”.

* owner: – To Set the owner of file or directory.

* path: – The file’s path, which is our task’s target.

* recurse: – This is used when state parameter have directory as value and we want to update the content of a directory in terms of file attributes.
    selevel, serole, setype, seuser: – These are used to update the selinux file context.
    
* src: – This is to give the path of the file to link to.

* state: – Acceptable values are touch, absent, directory, file, hard and link. Default value is file.

__Examples:__

```YAML
- name: change file ownership,, group, permission
  file:
    path: /etc/file.conf
    owner: sam
    group: isi
    mode: '0644'
    
```

```YAML
- name: give insecure permission to ana existing file
  file:
    path: /work
    owner: root
    group: root
    momde: '1777'
```

```YAML
- name: create a symbolic link
  file:
    src: /file/to/be/linked
    dest: path/t/symlink
    owner: foo
    group: foo
    state: link

```

```YAML

- name: create two hard links
  file:
    src: '/tmp/{{ item.src }}'
    dest: '{{ item.dest }}'
    state: hard
  loop:
    - {src: x, dest: y }
    - {src: z, dest: k }
```

```YAML
- name: touch a file, using symbolic link modes to set the permissions (equivalent to 0644)
  file:
    path: /etc/file.conf
    state: touch
    mode: u=rw,g=r,o=r

```

```YAML
- name: Touch the same file, but add/remove some permissions
  file:
    path: /etc/foo.conf
    state: touch
    mode: u+rw,g-wx,o-rwx
```

```YAML
- name: touch again the same file, but don't change times this makes task idempotent
  file:
    path: /etc/file.conf
    state: touch
    mode: u+rw,g-wx,o-rwx
    modification_time: preserve
    access_time: preserve
    
```

```YAML
- name: create a directory if it does not exists
  file:
    path: /etc/some_directory
    state: directory
    mode: 0755
    
```


```YAML
- name: update modification and access time of given file
  file:
    path: /ect/some_file
    state: file
    modification_time: now
    access_time:now
```


```YAML
- name: recursively change ownership of drirectory
  file:
    path: /etc/httpd
    state: directory
    recurse: yes
    owner: foo
    group: foo    
```

```YAML
- name: remove a file
  file:
    path: /etc/file.txt
    state: absent
```

```YAML
- name: recursively remove directory
  file:
    path: /etc/foo
    state: absent
```

__5. Service:__

* Ansible’s service module controls services on remote hosts and is useful for these common tasks:- Start, stop or restart a service on a remote host.

* For windows systems, Ansible provides a similar module named win_service, which mostly works the same way with limitations of Windows operating systems.

Examples:

```YAML
- name: Start service httpd, if not started
  service:
    #put name of your service below
    name: httpd
    state: started

```
```YAML
- name: Stop service httpd, if started
  service:
    name: httpd
    state: stopped

```

```YAML
- name: restart the httpd service, in all cases
  service:  
    name: httpd
    state: restarted
```

```YAML
- name: reload httpd service, in all cases
  service: 
    name: httpd
    state:reloaded
```


```YAML
# this is used to start any service which resides in complex folder systems
# In below example service named foo is started
- name: start service foo, based on running process /usr/bin/foo
  service:   
    name: foo
    pattern: /usr/bin/foo
    state: started
```

```YAML
- name: enable service httpd and not touch the state
  service:
    name: httpd
    enabled: yes
```

```YAML
- name: restart network service for interface eth0
  service:
    name: network
    state: restarted
    args: eth0
```
      
__6. Fetch:__

* Fetch module works like copy module, but in reverse.

* Fetch module is used for fetching files from remote machines and storing them locally in a file tree, organised by hostname.

* File that are already present at destination will be overwritten if they are different than the src.

* This module also supports windows targets.

###### Parameters:

|Parameter |Choice/defaults | Comments |
|----------|----------------|----------|
|dest| | A directory to save the file into. For Example, if the dest directory is _/backup_ a src file named _/etc/profile_ on host _host.example.com_, would be saved into `_/backup/host.example.com/etc/profile_`. The host name is based on the inventory name.|
|flat<br> _boolean_|__Choice__ <br> 1. yes <br> 2. No|When set to `yes`, the task will fail if the remote file cannot be read for any reason.<br> Prior to ansible 2.5,setting this would only fail if the source file was missing. <br> The default was changed to `yes` in Ansible 2.5|
|src | | The file on  the remote system to fetch <br> This must be a file,not a directory. <br> Recursive fetching may be supported in a later release|
| Validate_checksum <br> _boolean_| __Choice__ <br> 1. yes<br>2. No| Verify that the source and destination checksums match adter the files are fetched|


__Examples:__

```YAML
- name: store fie into /tmp/fetched/host.exaample.com/tmp/somefile
  fetch: 
    src: /tmp/somefile
    dest: /tmp/fetched
```

```YAML
- name: specifying a path directly
  fetch:  
    src: /tmp/somefile
    dest: /tmp/prefix-{{ inventory_hostname}}
    flat: yes
```

```YAML
- name: specifying destination path
  fetch:
    src: /tmp/uniquefile
    dest: /tmp/special/
    flat: yes
```
  
```YAML
- name: storing in a path relative to playbook
  fetch:
    src: /tmp/uniquefile
    dest: special/prefix-{{ inventory_hostname }}
    flat:yes
```
<hr>

__Note for fetch module:__

* When running fetch with `become`, the <font color='blue'> `slurp` </font> module will also be used to fetch the contents of the file for determining the remote checksum. This effectively doubles the transfer size, and depending on the file size can consume all available memory on the remote or local hosts causing a `MemoryError`. Due to this it is advisable to run this module without become whenever possible.

__7. get_url:__

* get_url is used to downloads files from HTTP, HTTPS, or FTP to the remote server.
* The remote server must have direct access to the remote resource
* By default, if an environment variable `<protocol>_proxy` is set on the target host, requests will be sent through that proxy. This behaviour can be overridden by setting a variable for this task or by using the use_proxy option.

* HTTP redirects can redirect from HTTP to HTTPS so you should be sure that your proxy environment for both protocols is correct.

* From Ansible 2.4 when run with `--check`, it will do a HEAD request to validate the URL but will not download the entire file or verify it against hashes.

* For Windows targets, use the [win_get_url](https://docs.ansible.com/ansible/2.9/modules/win_get_url_module.html#win-get-url-module) module instead.

__Examples:__



```YAML

- name: download foo.conf file
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    mode: '0440'
```

```YAML
- name: download file and force basic auth
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    force_basic_auth: yes
```

```YAML
- name: download file with custom HTTP headers
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    headers:
      key1: one
      key2: two
```

```YAML
- name: download file with check(SHA256)
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    checksum: sha256:52fd3b1d61e25b23cb1e796a0b9d813f9cdf812012f4850b878a8dc4e4944cd7
```

```YAML
- name: download file with check(md5)
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    checksum: md5:66dffb5228a211e61d6d7ef4a86f5758

```
```YAML
- name: Download file from a file path
  get_url:
    url: file:///tmp/afile.txt
    dest: /tmp/afilecopy.txt
```
```YAML
- name: < Fetch file that requires authentication.
        username/password only available since 2.8, in older versions you need to use url_username/url_password
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    username: daniel
    password: '{{ mysecret }}'
```

__8. command:__

* It is used to execute commands on targets.
* The `command` module takes the command name followed by a list of space-delimited arguments.
* The given command will be executed on all selected nodes.
* __The command(s) will not be processed through the shell__, so variables like `$HOME` and operations like `"<"`,`">"`,`"|"`,`";"` and `"&"` will not work. You can use [shell](https://docs.ansible.com/ansible/2.9/modules/shell_module.html#shell-module) module if you need these features. 
* To create `command` tasks that are easier to read than the ones using space-delimited arguments, pass parameters using the `args` task keyword or use `cmd` parameter.
* Either a free form command or cmd parameter is required.
* For Windows targets, use the [win_command](https://docs.ansible.com/ansible/2.9/modules/win_command_module.html#win-command-module) module instead.

__Examples:__

```YAML
- name: Run command if /path/to/database does not exist (without 'args' keyword).
  command: /usr/bin/make_database.sh db_user db_name creates=/path/to/database

```

```YAML
# 'args' is a task keyword, passed at the same level as the module
- name: Run command if /path/to/database does not exist (with 'args' keyword).
  command: /usr/bin/make_database.sh db_user db_name
  args:
    creates: /path/to/database
```
```YAML
# cmd is module parameter
- name: Run command if path to databse does not exists (with 'cmd' parameter)
  command:
    cmd: /usr/bin/make_database.sh db_user db_name
    creates: /path/to/database
```

```YAML
- name: change the directory to somedir/ and run the command as db_owner of path/to/database does not exists.
  command: /usr/bin/make_database.sh db_user db_name
  become: yes
  become_user: db_owne
  args:
    chdir: somedir/
    creates: path/to/database
```

__9. Block:__

* Blocks create logical groups of tasks. Blocks also offer ways to handle task errors, similar to exception handling in many programming languages.
  * Grouping tasks with blocks
  * Handling errors with blocks

__Grouping tasks with blocks:__

* All tasks in a block inherit directives applied at the block level. 
* Most of what you can apply to a single task (with the exception of loops) can be applied at the block level, so blocks make it much easier to set data or directives common to the tasks. The directive does not affect the block itself, it is only inherited by the tasks enclosed by a block. 
* For example, a when statement is applied to the tasks within a block, not to the block itself.

*Block example with named tasks inside the block:*

```YAML

tasks;
  - name: Install,configure and start apache
    block:
      - name: install httpd and memcached
        yum:
        - httpd
        - memcached
        state: present
        
      - name: Apply the foo config template
        template:
          src: templates/src.j2
          dest: /etc/foo.conf  
      - name: start service bar and enable it    
        service:
          name: bar
          state: started
          enabled: true
    when: ansible_facts['distribution'] == 'CentOS'
    become: true
    become_user: root
    ignore_errors: yes
```

* In the above example, when condition is executed before Ansible runs each of the above three tasks.
* All three tasks also inherit the privilages escalation directives, running as the root user. 
*  `ignore_errors: yes` ensures that Ansible continues to execute the playbook even if some of the taska fail.


__Handling errors with blocks:__

* You can control how Ansible responds to task errors using blocks with `rescue` and `always` sections.
* Rescue blocks specify tasks to run when an earlier task in a block fails. This approach is similar to exception handling in many programming languages.
* Ansible runs rescue block only after a task return __failed__ state.

* __Bad task definitions__ and __unreachable hosts__ will _not trigger_ the rescue block.

__Examples:__

```YAML
tasks:
  - name: handle the error
    block:
      - name: print a message
        debug:
          msg: 'I Execute normally'
      
      - name: force a failure
        command: /bin/false

      - name: never print this
        debug:
          msg: ' I never execute, due to above task failing, :-( '
    
    rescue: 
      - name: print when errors
        debug:
          msg: " I caught an error, can do stuff here to fix it :-) '


```

We can also add an `always` section to a block. Tasks in the `always` section run no matter what the task status of the previous block is.

__Example:__
```YAML

- name: always do X
  block:
    - name: print a message
      debug:
        msg: 'I execute normally'

    - name: force a failure
      command: /bin/false

    - name: never print this
      debug:
        msg: 'I never execute'

  always:
    - name: always do this task
      debug:
        msg: "This Always executes"
```
<br>
<hr>
Together these elements offer complex error handling__
<hr>


__Example__

```YAML
- name: Attempt and graceful roll back demo
  block:
    - name: Print a message
      ansible.builtin.debug:
        msg: 'I execute normally'

    - name: Force a failure
      ansible.builtin.command: /bin/false

    - name: Never print this
      ansible.builtin.debug:
        msg: 'I never execute, due to the above task failing, :-('
  rescue:
    - name: Print when errors
      ansible.builtin.debug:
        msg: 'I caught an error'

    - name: Force a failure in middle of recovery! >:-)
      ansible.builtin.command: /bin/false

    - name: Never print this
      ansible.builtin.debug:
        msg: 'I also never execute :-('
  always:
    - name: Always do this
      ansible.builtin.debug:
        msg: "This always executes"


```
