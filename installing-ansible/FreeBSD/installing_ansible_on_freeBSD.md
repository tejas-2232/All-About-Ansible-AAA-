* Though Ansible works with both Python 2 and 3 versions, FreeBSD has different packages 
   for each Python version. So to install you can use:

```
$ sudo pkg install py27-Ansible 
```   

__or:__

```
$ sudo pkg install py37-Ansible 
```   
* You may also wish to install from ports, run:

```
sudo make -C /usr/ports/sysutils/ansible install
```

* You can also choose a specific version, for example ```ansible25```

* Older versions of FreeBSD worked with something like this (substitute for your choice of package manager):

```
$ sudo pkg install ansible
```


