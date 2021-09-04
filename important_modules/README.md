
# Important modules in Ansible

![](https://miro.medium.com/max/5120/1*9z4jjgJZl_DyHaOEzP-wSw.jpeg)

> ### We will look into following popular modules.

[1. uri](#uri)

[2. shell](#shell)

[3. lineinfile module](#lineinfile)

[4. file](#file)

[5. service](#service)

[6. fetch](#fetch)

[7. get_url](#get_url)

[8. command](#command)

[9. block](#block)

[10. copy](#copy)

[11. set_fact](#set_fact) 

[12. script](#script)

[13. reboot](#reboot)

[14. wait_for](#wait_for)

[15. delegate_to](#delegate_to)

[16. yum](#yum)

[17. dnf](#dnf)

[18. mail](#mail)

[19. blockinfile](#blockinfile)

[20. raw](#raw)

[21. systemd](#systemd)

<hr>

1. #### uri:

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



2. #### shell:

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

3. #### lineinfile: 

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

4. #### file:

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

5. #### service:

* Ansible’s service module controls services on remote hosts and is useful for these common tasks:- Start, stop or restart a service on a remote host.

* For windows systems, Ansible provides a similar module named [win_service](https://docs.ansible.com/ansible/2.9/modules/win_service_module.html#win-service-module), which mostly works the same way with limitations of Windows operating systems.


* Supported init systems include BSD init, OpenRC, SysV, Solaris SMF, systemd, upstart.

__Examples:__


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
      
6. #### fetch:

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

7. #### get_url:

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

8. #### command:

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

9. #### Block:

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

* The tasks in `block` section execute normally. If any task in the block return `failed`, the `rescue` section exectes to recover from the error. 
* The `always` section runs regardless of the results of the `block` and `rescue` sections.

* If an error occures in block and rescue task succeeds, Ansible reverts the failed status of the original task for the run & continous to run as if the original task had succeeded.

* The rescued task is considered successful, and does not trigger max_fail_percentage or any_errors_fatal configurations. However, Ansible still reports a failure in the playbook statistics.

* We can use blocks with `flush_handlers` in a rescue task to ensure that all handlers run even if an error occurs:

__Example:__

```YAML
tasks:
  - name: Attempt and graceful roll back demo
    block:
      - name: print a message
        debug:
          msg: " I execute normally"
        changed_when: yes
        notify: run me even after an error
      
      - nama: force a failure
        command: /bin/false

    rescue: 
      - name: make sure all handlers run
        meta: flush_handlers

handlers:
  - name: run me even after an error
    debug:
      msg: "This handler runs even on error"
```

10. #### copy:

* Copy module is used to copy files from local or remote machine to a specific location on remote machine.
* We can also use _fetch_ module to copy files from remote machine to local machine.
* _template_ module is used if you want variable interpolation.
* For windows systems, Ansible provides a similar module named [win_copy](https://docs.ansible.com/ansible/2.4/win_copy_module.html#win-copy), which mostly works the same way with limitations of Windows operating systems.


__Examples:__

```YAML
- name: copy files
  copy:
    src: /etc/ansible/file.config
    dest: /home/machine2/project
    owner: foo
    group: foo
    mode: 0644
```

```YAML
- name: copy file with owner and permission,using symbolic representation.
  copy:
    src: /srv/myfiles/foo.conf]
    dest: /etc/ foo.conf
    owner: foo
    group: foo
    mode: u=rw,g=r,o=r
  

```

```YAML

- name: Copy a new "ntp.conf file to remote server,backing up the original if it differs from the copied version
  copy:
    src: /mine/ntp.conf
    dest: /etc/ntp.conf
    owner: foo
    group: foo
    mode: `0644`
    backup: yes

```

```YAML
- name: Copy a new "sudoers" file into place, after passing validation with visudo
  copy:
    src: /mine/sudoers
    dest: /etc/sudoers.edit
    validate: /usr/sbin/visudo -csf %s

```


```YAML
- name: copy a "sudoers" file on the remote machine for editing
  copy:
    src: /etc/sudoers
    dest: /etc/sudoers.edit
    remote_src: yes
    validate: /usr/sbin/visudo -csf %s

```

```YAML

- name: Copy using inline content
  copy:
    content: '# This file was moved to /etc/other.conf'
    dest: /etc/mine.conf
```

```YAML
- name: if follow= yes,path/to/file will be overwritten by contents of foo.conf
  copy:
    src: /etc/foo.conf
    dest: /path/to/link # link to path/to/file
    follow: yes
    
```


```YAML

- name: If follow=no, /path/to/link will become a file and be overwritten by contents of foo.conf
  copy:
    src: /etc/foo.conf
    dest: /path/to/link  # link to /path/to/file
    follow: no
```

11. #### set_fact:

* we can set new variables using this module.

* Variables are set on host-by-host basis just like facts discovered by the setup module.

* These variables will be available to subsequent plays during an ansible playbook run.

* We have option to set  `cacheable` to `yes` to save variables across executions using a fact cache.
 
* Variables created with set_fact have different precedence depending on whether they are or are not cached.

* This module is also supported for Windows targets.

__Examples:__

```YAML
# Example setting host facts using key=value pairs, note that this always creates strings or booleans

- set_fact: one_fact= "something" other_fact="{{ local_var }}"

```

```YAML
# Example setting host facts using complex arguments
 
- set_fact:
    one_fact: something
    other_fact: "{{ local_var * 2 }}"
    another_fact: " {{ some_registered_var.results | map(attribute= 'ansible_facts.some_fact') | list }} " 

```

```YAML
# As of Ansible 1.8, Ansible will convert boolean strings ('true', 'false', 'yes', 'no')
# to proper boolean values when using the key=value syntax, however it is still
# recommended that booleans be set using the complex argument style:

- set_fact: 
    one_fact: yes
    other_fact: no

    This module is also supported for Windows targets.

```

12. #### script:

* The script module takes the script name followed by a list of space-delimited arguments.

* Either a free form command or cmd parameter is required, see the examples.

* The local script at path will be transferred to the remote node and then executed.

* The given script will be processed through the shell environment on the remote node.
  
* This module does not require python on the remote system, much like the raw module.

* This module is also supported for Windows targets.


__Examples:__

```YAML
- name: run a script ith arguments (free form)
  script: /etc/cnf/script.sh  --some-argument 1234
```

```YAML
- name: run a acript with arguments (using 'cmd' param)
  script:
    cmd: /etc/cnf/script.sh  --some-argument 1234
```

```YAML
- name: run a script only if file.txt  does not exist on the remote node
  script: /etc/cnf/script.sh  --some-argument 1234
  args:
    creates: /created/file.txt
```
```YAML
- name: run a script only if file.txt exists on the remote node
  script: /etc/cnf/script.sh  --some-argument 1234
  args:
    removes: /removed/file.txt
```

```YAML
- name: run a script using an executable in non-system path
  script: /local/script
  args:
    executable: /path/to/an/executable
```

```YAML
- name: run a script using an executable in system path
  script: /local/script.py
  args:
    executable: python3
```

13. #### reboot:

* Reboot a machine, wait for it to shut down, come back up, and respond to commands.
* For windows target,use win_reboot module.

<hr>

> __Parameters__

<hr>

| Parameters |Choices/Defaults | Use |
|--------|-------|-------|
| __connect_timeout__ <br> integer || maximum seconds to waitfor a successful connection to the managed hosts before trying again.|
| __msg__ <br> string | __Default:__ <br> "Reboot initiated by Ansible | message to display to user before reboot|
| __post_reboot_delay__ <br> integer | __Default:__ <br> 0| Seconds to wait afte reboot command is successful before attempting to valiadte the system rebooted successfullt. <br> This is useful if you want for something to settle despite your connection already working.|
|__pre_reboot_delay__ | __Default__ <br> 0 |Seconds to wait before reboot. Passed as a parameter to the reboot command. |
|__reboot_command__ <br> string |__Default:__<br>"[determined based on target OS]"|Command to run that reboots the system, including any parameters passed to the command. |
| __reboot_timeout__ <br> integer | __Default__ <br> 600 | Maximum seconds to wait for machine to reboot and respond to a test command <br>This timeout is evaluated separately for both reboot verification and test command success so the maximum execution time for the module is twice this amount.|
|__search_paths__ <br> list/elements=true|__Default__|Paths to search on the remote machine for the __shutdown__ command. <br>_Only_ these paths will be searched for the shutdown command. PATH is ignored in the remote node when searching for the shutdown command|
|__test_command__<br> string|__Default:__ <br>"whoami"|Command to run on the rebooted host and expect success from to determine the machine is ready for further tasks.|


__Examples:__

```YAML
- name: unconditionally reboot the machine with all defaults
  reboot:

```

```YAML
- name: reboot a slow machine that might have lots of updates to apply
  reboot:
    reboot_timeout:3600
```

14. #### wait_for:

* Wait_for is used to wait for a condition before executing

* _timeout_ is used to wait for a certain amount time and it's deafult if nothing is set.

* Waiting for a port to become available is useful when services are not immediately available after their init scripts return which is true for certain Java application servers.

* It is also useful when starting guests with the virt module and needing to pause until they are ready.

* This module is also used to wait for a regex to match a string to be present in a file.

* For Windows targets, use the [win_wait_for](https://docs.ansible.com/ansible/2.9/modules/win_wait_for_module.html#win-wait-for-module) module instead.

__Example:__


```YAML
- name: sleep for 300 seconds anad continue with play
  wait_for:
    timeout: 300
  delegate_to: localhost

```

```YAML
- name: wait for port 8000 to become open on the host , don't start checking for 10 seconds
  wait_for:
    port: 8000
    delay: 10
```

```YAML
- name: wait for port 8000 of any IP to close active connections, don't start checking for 10 seconds
  wait_for:
    host: 0.0.0.
    port: 8000
    delay: 10
    state: drained
```

```YAML
- name: wait for port 8000 of any IP to close active connections,ignoring connections for specified hosts
  wait_for:
    host: 0.0.0.0
    port: 8000
    state: drained
    exclude_hosts: 10.45.90.12, 13.56.78.99
```

```YAML
- name:  wait until the file /etc/file.cfg is present beforee continuing
  wait_for:
    path: /etc/file.cfg
```

```YAML
- name: wait until the string "completed" is in the file /etc/file.cfg before continuning
  wait_for:
    path: /etc'file.cfg
    search_regex: completed
```

```YAML
- name: Wait until regex pattern matches in the file /tmp/foo and print the matched group
  wait_for:
    path: /etc/file.cfg
    search_regexp: completed (?P<task>\w+)
  register: waitfor
-debug:
  msg: completed {{ waitfor['groupdict']['task'] }}
```

```YAML
- name: Wait until the lock file is removed
  wait_for:
    path: /var/lock/file.lock
    state: absent
```

```YAML
- name: Wait until the process is finished and pid was destroyed
  wait_for:
    path: /proc/3466/status
    state: absent
```

```YAML
- name: Output customized message when failed
  wait_for:
    path: /etc/file.cfg
    state: present
    msg: Timeout to find file /etc/file.cfg
```

15. #### delegate_to:

* If we want to run any task on any particular machine, we can use ansible delegate_to module
* The process of hadling over the execution of task to other machine is known as __delegation.__
* 

```YAML
- name: install httpd
  yum:
    name: httpd
    state: latest
  delegate_to: web.etm1
```
* Above task will run on web.etmll machine

16. #### yum:

* Installs, upgrade, downgrades, removes, and lists packages and groups with the yum package manager.
* This module works on python 2 only.
* If you need python 3 support then use dnf module.

__Examples:__

```YAML
- name: install the latest version of Apache
  yum:
    name: httpd
    state: latest
```

```YAML
- name: ensure a list of packages is installed
  yum:
    name: "{{ packages }} "
  vars:
    packages:
    - httpd
    - httpd-tools
```

```YAML
- name: Remove apache package
  yum:
    name: httpd
    state: absent
```

```YAML
- name: install the latest version of Apache from the testing repo
  yum:
    name: https
    enablerepo: testing
    state: present
```

```YAML
- name: install one specific version of apache
  yum:
    name: httpd-2.2.29-1.4.amzn1
    state: absnet
```

```YAML
- name: upgrade all packages
  yum:
    name: '*'
    state: latest
```

```YAML
- name: upgrade all packages, excluding kernel and foo related packages
  yum:
    name: '*'
    state: latest
    exclude: kernel*, foo*
```

```YAML
- name: install nginx rmp from a remote repo
  yum: 
    name: http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    state: latest
```

```YAML
- name: install nginx rpm froma local file
  yum:
    name: /usr/local/src/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    state: present
```

```YAML
- name: install ' Development tools' packae from group
  yum:
    name: @Development Tools
    state: present
```

```YAML
- name: install the 'Gnome desktop' environment group
  yum:
    name: "@^gnome-desktop-environment"
    state: present
```

```YAML
- name: list ansible packages and register with result to print with debig later
  yum:
    list: asnible
  register: result
```

```YAML
- name: Install package with multiple repos enabled
  yum:
    name: sos
    enablerepo: "epel, o17_latest"
```

```YAML
- name: Install package with multiple repos disabled
  yum:
    name: sos
    disablerepo: "epel,ol7_latest"
```

```YAML
- name: install list a package
  yum:  
    name:
    - nginx`
    - postgresql
    - postgresql-server
  state: present  
```

```YAML
- name: Download the nginx package but do not install it
  yum:
    name: 
      - nginx
    state: latest
    download_only: true
```

17. #### dnf

* Installs, upgrade, removes, and lists packages and groups with the dnf package manager.
* This module works with the support of python3

__Examples__

```YAML

- name: Install the latest version of Apache
  dnf:
    name: httpd
    state: latest
```
```YAML
- name: Install Apache >= 2.4
  dnf:
    name: httpd>=2.4
    state: present
```

```YAML
- name: remove apache package
  dnf:
    name: httpd
    state: absent
```

```YAML
- name: install latest version of apache from a testing repo
  dnf:
    name: httpd
    enablerepo: testing
    state: present
```

```YAML
- name: upgrade all packages
  dnf:
    name: "*"
    state: latest
```

```YAML
- name: install the nginx rpm from a remote repo
  dnf:
    name: 'http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm'
    state: present
```

```YAML
- name: install nginx rpm from a local file
  dnf:
    name: /usr/local/src/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    state: present
```

```YAML
- name: install the 'Development tools' package group
  dnf:
    name: '@Development tools'
    state: present
```
```YAML
- name: Autoremove unneeded packages installed as dependencies
  dnf:
    autoremove: yes
```

```YAML
- name: Uninstall httpd but keep its dependencies
  dnf:
    name: httpd
    state: absent
    autoremove: no
```

```YAML
- name: Install a modularity appstream with defined stream and profile
  dnf:
    name: '@postgresql:9.6/client'
    state: present
```

```YAML
- name: Install a modularity appstream with defined stream
  dnf:
    name: '@postgresql:9.6'
    state: present
```

```YAML
- name: Install a modularity appstream with defined profile
  dnf:
    name: '@postgresql/client'
    state: present
```

18. #### mail:

* This module is useful for sending emails from playbooks.

* One may wonder why automate sending emails? In complex environments there are from time to time processes that cannot be automated, either because you lack the authority to make it so, or because not everyone agrees to a common approach.

* If you cannot automate a specific step, but the step is non-blocking, sending out an email to the responsible party to make them perform their part of the bargain is an elegant way to put the responsibility in someone else’s lap.

* Of course sending out a mail can be equally useful as a way to notify one or more people in a team that a specific action has been (successfully) taken.

__Examples:__

```YAML
- name: Example of sending mail to root
  mail: 
    subject: System {{ ansible_hostname }} has been successfully provisioned
  delegate_to: localhost
```

```YAML
- name: Sending an e-mail using the remote machine, not the Ansible controller node
  community.general.mail:
    host: localhost
    port: 25
    to: John Smith <john.smith@example.com>
    subject: Ansible-report
    body: System {{ ansible_hostname }} has been successfully provisioned.

```


19. #### blockinfile:

* This module is used to insert/update/remove a text block surrounded by marker lines.

__EXAMPLE:__


```YAML
- name: Insert/Update "Match User" configuration block in /etc/ssh/sshd_config
  blockinfile:
    path: /etc/ssh/sshd_config
    block: | 
      Match User ansible-agent
      PasswordAuthentication no
```
```YAML

- name: Insert/Update eth0 configuration stanza in /etc/network/interfaces (it might be better to copy files into /etc/network/interfaces.d/)
  blockinfile:
    path: /etc/network/interfaces
    block: |
      iface eth0 inet static
          address 192.0.2.23
          netmask 255.255.255.0
```

```YAML
- name: Insert/Update configuration using a local file and validate it
  blockinfile:
    block: "{{ lookup('file', './local/sshd_config') }}"
    path: /etc/ssh/sshd_config
    backup: yes
    validate: /usr/sbin/sshd -T -f %s
```

```YAML
- name: Insert/Update HTML surrounded by custom markers after <body> line
  blockinfile:
    path: /var/www/html/index.html
    marker: "<!-- {mark} ANSIBLE MANAGED BLOCK -->"
    insertafter: "<body>"
    block: |
      <h1>Welcome to {{ ansible_hostname }}</h1>
      <p>Last updated on {{ ansible_date_time.iso8601 }}</p>

```

```YAML
- name: Remove HTML as well as surrounding markers
  blockinfile:
    path: /var/www/html/index.html
    marker: "<!-- {mark} ANSIBLE MANAGED BLOCK -->"
    block: ""

```

```YAML
- name: add mapping to /etc/hosts
  blockinfile:
    path: /etc/hosts
    block: |
      {{ item.ip}} {{item.name}}
    marker: "# {mark} Ansible Managed Block {{item.name}} "
  loop:
    - { name: host1, ip: 10.10.1.10 }
    - { name: host2, ip: 10.10.1.11 }
    - { name: host3, ip: 10.10.1.12 }
    - { name: host4, ip: 10.10.1.13 }
    
```

20. #### raw:
 
* Executes a low-down and dirty SSH command, not going through the module subsystem.

* This is useful and should only be done in a few cases. A common case is installing python on a system without python installed by default. 

* Another is speaking to any devices such as routers that do not have any Python installed. In any other case, using the `shell` or `command` module is much more appropriate.

* Arguments given to raw are run directly through the configured remote shell.

* Standard output, error output and return code are returned when available.

* This module does not require python on the remote system, much like the script module.

* This module is also supported for Windows targets.

```YAML
- name: bootstrap a host without python2 installed.
  raw: dnf install -y python2 python2-dnf libselinux-python
```

```YAML
- name: Run a command that uses non-posix shell-isms (in this example /bin/sh doesn't handle redirection and wildcards together but bash does)
  raw: cat < /tnp/*txt
  args:   
    executable: /bin/bash
```

```YAML
- name: Safely use templated variables. Always use quote filter to avoid injection issues.
  raw: "{{ package_mgr|quote }} {{ pkg_flags|quote }} install {{ python|quote }}"  
```

```YAML
- name: List user accounts on a Windows system
  raw: Get-WmiObject -Class Win32_UserAccount

```


21. #### systemd:

* systemd module is used to control systemd services on remote hosts.
* It requires A system managed by systemd

<hr>

> Parameters

<hr>

|parameter|choices| comments|
|----|----|----|
|daemon_reexec| choices<br> * yes <br> * no | Run daemon_reexec command before doing any other operations, the systemd manager will serialize the manager state.|


__Examples:__

```YAML
- name: make sure a service is running
  systemd:
    name: httpd
    state: started
```

```YAML
- name: stop service cron on debian if running
  systemd:
    name: cron
    stata: stopped
```

```YAML
- name: run a service cron on cent os, in all cases, also issue deamon-reload to pick upconfig changes
  systemd:
    state: restarted
    daemon_reload: yes
    name: cron
    
```

```YAML
- name: reload service httpd in all cases
  systemd:
    name: httpd
    state: reloaded
```
```YAML
- name: enable service httpd and ensure it is not masked
  systemd:
    name: httpd
    enabled: yes
    masked: no
```
```YAML
- name: enable a timer for dnf-automatic
  systemd:
    name: dnf-automatic.timer
    state: started
    enabled: yes
```

```YAML
 name: just force systemd to reread configs (2.4 and above)
  systemd:
    daemon_reload: yes
```

```YAML
- name: just force systemd to re-execute itself (2.8 and above)
  systemd:
    daemon_reexec: yes


```
