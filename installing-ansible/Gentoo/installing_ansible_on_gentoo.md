### Installing Ansible on Gentoo with portage

```
$ emerge -av app-admin/ansible
```

* To install the newest version, you may need to unmask the Ansible package prior to emerging:

```
$ echo 'app-admin/ansible' >> /etc/portage/package.accept_keywords

```