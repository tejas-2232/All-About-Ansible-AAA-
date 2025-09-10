# Intro to ansible for kubernetes

## Introduction 
The Kubernetes modules are part of the Ansible Kubernetes collection.

To install the collection, run the following:

```bash
$ ansible-galaxy collection install kubernetes.core
```

## requirements
To use the modules, you’ll need the following:

Ansible 2.9.17 or latest installed

[Kubernetes Python client](https://pypi.org/project/kubernetes/) installed on the host that will execute the modules.

## installation

The Kubernetes modules are part of the Ansible Kubernetes collection.

To install the collection, run the following:
```bash
$ ansible-galaxy collection install kubernetes.core
```

## Authenticating with API

* By default K8 rest client will look for `.kube/config` file and if found, connect using the active context. You can override the location of the file using the `kubeconfig` parameter and the context using the `context` parameter.

* Basic authentication is also supported using the `username` and `password` options.
* You can override the URL using the 'host' parameter.
* Certificate authentication works through the `ssl_ca_cert`, `cert_file`, and `key_file` parameters and for token authentication- use the `api_key` parameter.

* To disable SSL Certificate verification, set the `verify_ssl` parameter to `false`


# Using Kubernetes dynamic inventory plugin

## Kubernetes dynamic inventory plugin

* the best way to interact with Pods is to use the kubernetes dynamic inventory plugin, which queries K8 APIs using `kubectl` command line available on controller node and tells Ansible what Pods can be managed

## Requirements

To use the k8  dynamic inventory plugin, you muts install Kubernetes Python client, kubectl on your control node (the host that runs Ansible)

```bash
$ pip install kubernetes
```

* To use this Kubernetes dynamic inventory plugin, you need to enable it first by specifying the following in the ansible.cfg file:

```ini
[inventory]
enable_plugins = kubernetes.core.k8s
```

* Then create a file that ends in `.k8s.yml` or `.8s.yaml` in your working directory.

* The kubernetes.core.k8s inventory plugin takes in the same authentication information as any other Kubernetes modules.

* Here’s an example of a valid inventory file:

```yaml
plugin: kubernetes.core.k8s
```

* You can also specify the inventory file in the command line using the `-i` option.

```bash
ansible -i inventory.k8s.yml all -m ping
```

Executing `ansible-inventory --list -i <filename>.k8s.yml` will create a list of Pods that are ready to be configured using Ansible.

* You can also provide the namespace to gather information about specific pods from the given namespace. For example, to gather information about Pods under the test namespace you will specify the namespaces parameter:

```yaml
plugin: kubernetes.core.k8s
connections:
- namespaces:
    - test
```


# Creating K8S object

## introduction

how to utilize Ansible to create Kubernetes objects such as Pods, Deployments, and Secrets.

## Scenario Requirements

* Software
- - Ansible 2.9.17 or later must be installed
  -  The Python module kubernetes must be installed on the Ansible controller (or Target host if not executing against localhost)
  - Kubernetes Cluster
  - Kubectl binary installed on the Ansible controller

* Access / Credentials
  - Kubeconfig configured with the given Kubernetes cluster
  

## Assumptions

User has required level of authorization to create, delete and update resources on the given Kubernetes cluster.

## Example Description

In this use case / example, we will create a Pod in the given Kubernetes Cluster. The following Ansible playbook showcases the basic parameters that are needed for this.

```yaml
---
- hosts: all
  collections:
    - kubernetes.core
  tasks:
    - name: create a pod
      kubernetes.core.k8s_pod:
        state: present
        definition::
          api_version: v1
          kind: Pod
          metadata:
            name: "utilitypod-1"
            namespace: default
            labels:
              app: galaxy
        spec:
          containers:
            - name: utilitypod
              image: busybox
```

* Since Ansible utilizes the Kubernetes API to perform actions, in this case we will be connecting directly to the Kubernetes cluster

## what to expect

* The playbook will create a Pod in the given Kubernetes Cluster.
* The Pod will be named `utilitypod-1` and will be in the `default` namespace.
* The Pod will have the label `app: galaxy`.
* The Pod will have one container named `utilitypod` and will be using the `busybox` image.

You will see a bit of JSON output after this playbook completes. This output shows various parameters that are returned from the module and from cluster about the newly created Pod.

```json
{
    "changed": true,
    "method": "create",
    "result": {
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
            "creationTimestamp": "2020-10-03T15:36:25Z",
            "labels": {
                "app": "galaxy"
            },
            "name": "utilitypod-1",
            "namespace": "default",
            "resourceVersion": "4511073",
            "selfLink": "/api/v1/namespaces/default/pods/utilitypod-1",
            "uid": "c7dec819-09df-4efd-9d78-67cf010b4f4e"
        },
        "spec": {
            "containers": [{
                "image": "busybox",
                "imagePullPolicy": "Always",
                "name": "utilitypod",
                "resources": {},
                "terminationMessagePath": "/dev/termination-log",
                "terminationMessagePolicy": "File",
                "volumeMounts": [{
                    "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                    "name": "default-token-6j842",
                    "readOnly": true
                }]
            }],
            "dnsPolicy": "ClusterFirst",
            "enableServiceLinks": true,
            "priority": 0,
            "restartPolicy": "Always",
            "schedulerName": "default-scheduler",
            "securityContext": {},
            "serviceAccount": "default",
            "serviceAccountName": "default",
            "terminationGracePeriodSeconds": 30,
            "tolerations": [{
                    "effect": "NoExecute",
                    "key": "node.kubernetes.io/not-ready",
                    "operator": "Exists",
                    "tolerationSeconds": 300
                },
                {
                    "effect": "NoExecute",
                    "key": "node.kubernetes.io/unreachable",
                    "operator": "Exists",
                    "tolerationSeconds": 300
                }
            ],
            "volumes": [{
                "name": "default-token-6j842",
                "secret": {
                    "defaultMode": 420,
                    "secretName": "default-token-6j842"
                }
            }]
        },
        "status": {
            "phase": "Pending",
            "qosClass": "BestEffort"
        }
    }
}
```

# Kubernetes.core.helm Module - Manges Kubernetes packages with the Helm package manager

* Install, upgrade, delete packages with the Helm package manager.

## Examples

> deploy latets version of prometheus chart inside monitoring namespace (and Create it)

```yaml
- name: deploy latets version of prometheus chart inside monitoring namespace (and Create it)
  kubernetes.core.helm:
    name: test
    chart_ref: stable/prometheus
    release_namespace: monitoring
    create_namespace: true
```

> add stable chart repo

```yaml
# from repository
- name: add stable chart repo
  kubernetes.core.helm_repository:
    name: stable
    repo_url: "https://kubernetes.github.io/ingress-nginx"
```

> Deploy latest version of Grafana chart inside monitoring namespace with values

```yaml
- name: deploy latest version of Grafana chart inside monitoring namespace with values
  kubernetes.core.helm:
    name: test
    chart_ref: stable/grafana
    release_namespace: monitoring
    values:
      replicas: 2
```

> Separately update the repository cache

```yaml
- name: Separately update the repository cache
  kubernetes.core.helm:
    name: dummy
    namespace: kube-system
    state: absent
    update_repo_cache: true
``` 

> Deploy Bitnami's MongoDB latest chart from OCI registry

```yaml
- name: Deploy Bitnami's MongoDB latest chart from OCI registry
  kubernetes.core.helm:
    name: test
    chart_ref: "oci://registry-1.docker.io/bitnamicharts/mongodb"
    release_namespace: database
```

> deploy new-relic client chart

```yaml
# Using complex Values
- name: Deploy new-relic client chart
  kubernetes.core.helm:
    name: newrelic-bundle
    chart_ref: newrelic/nri-bundle
    release_namespace: default
    force: True
    wait: True
    replace: True
    update_repo_cache: True
    disable_hook: True
    values:
      global:
        licenseKey: "{{ nr_license_key }}"
        cluster: "{{ site_name }}"
      newrelic-infrastructure:
        privileged: True
      ksm:
        enabled: True
      prometheus:
        enabled: True
      kubeEvents:
        enabled: True
      logging:
        enabled: True
```