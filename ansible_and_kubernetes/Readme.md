# How to Install Kubernetes Cluster using Ansible Playbook Automation

## Ansible playbooks to setup a kubernetes cluster

* This repo has ansible playbooks to setup a kubernetes cluster on centos.
* Its fully automated with one master node and two worker nodes.

### setup instructions

1. make the servers ready
2. make entry of each host in /etc/hosts file for name resolution
3. make sure k8 master and worker nodes are reachable between each other
4. clone this repo 
5. add all k8 nodes entreis hosts file in centos dir
6. provide server details in `env_variables` file
7. Deploy the ssh key from master node to other nodes for password less authentication 
    `ssh-keygen`
    copy the public key to other nodes including master node and make sure you are able to login without password
8. Run `settingup_kubernetes_cluster.yml` playbook to setup all nodes and k8 master configuration     
   `ansible-playbook -i hosts settingup_kubernetes_cluster.yml`

9. Run `join_kubernetes_workers_nodes.yml` playbook to join the worker nodes to the kubernetes master node
   `ansible-playbook -i hosts join_kubernetes_workers_nodes.yml`

10. Verify the configuration from master node.
     `kubectl get nodes`


## files used

* ansible.cfg: anisble config file  

* hosts: Ansible Inventory File

* env_variables: Main environment variable file where we have to specify based on our environment.

* settingup_kubernetes_cluster.yml: Ansible Playbook to perform prerequisites ready, setting up nodes, configure master node.

* configure_worker_nodes.yml: Ansible Playbook to join worker nodes with master node.

* clear_k8s_setup.yml: Ansible Playbook helps to delete entire configurations from all nodes.

* playbooks: holds all playbooks.


### There are also other ways to setup a kubernetes cluster using ansible playbooks. Need some modification to dir structure, files and some ansible modules to be used.

