# Automating Container Management with Ansible

Here we will need 2 systems,
1. Ansible controller (any of these RHEL/CentOS/FreeBSD/Ubuntu)
2. remote host (any of these RHEL/CentOS/FreeBSD/Ubuntu)

**IMP**

* Ansible controller needs to have python 2.7 or python3.5 installed 


########################################################################################

## Docker Implemenation

### Docker Architecture

__We will Build container Images using Docker__

* docker uses client server architecture

**Client:** The command line toolis responsible for communicating with a server using a RESTful API to request operations


**Server:** It runs a daemon on an OS, does the heavy lifting of building, running and downloading container images.

**The daemon can run either on the same system as the docker client or remotely**


### Docker Daemon

Docker daemon needs to be started for docker commands to work. Manually you can run

```
systemctl enable --now docker
```

* Daemon is run as the root user, Docker commands must also be run as root. 
* Other container runtimes like podman do not require root to run containers

### Docker CLI

**Some of the most common commands are:**

|Command | Description |
|--------|-------------|
|docker search "term" |search an image registry for an image related to the term |
|docker pull "imagename" |download an image or images from a registry|
|docker run "imagename" | creates the container from the image|
|docker ps | List the containers|
|docker images | List the Downloaded images |
  
