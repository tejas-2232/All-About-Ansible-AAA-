__Ubuntu build are available in [a PPA here](https://launchpad.net/~ansible/+archive/ubuntu/ansible)__

* To configure the PPA on our machine and install Ansible run these commands:

```
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo add-apt-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible 

```

Debian/Ubuntu packages can also be built from the source checkout, run:

```
$ make deb
```
