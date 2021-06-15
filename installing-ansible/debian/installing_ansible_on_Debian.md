__Debian users may leverage the same source as the [Ubuntu PPA](https://launchpad.net/~ansible/+archive/ubuntu/ansible)__

* Add the following line to `/etc/apt/sources.list`:

```
deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
```
* Then run these commands:

```
$ sudo apt-key adv --keyserver keyserver.ubuntu.com -recv-keys 93C4A3FD7BB9C367

$ sudo apt update

$ sudo apt install ansible

```

> Note: This method has been verified with the Trusty sources in Debian Jessie and Stretch but may not be supported in earlier versions. You may want to use ```apt-get``` instead of ```apt``` in older versions