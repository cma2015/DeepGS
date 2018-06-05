## Nvidia-docker installation
### System requirements
* Ubuntu (>= 16.04)

### Step 1: install the latest version of Docker
```bash
# Take ubuntu 16.04 as an example
# Uninstall old versions
$ sudo apt-get remove docker docker-engine docker.io
# Update the apt package index
$ sudo apt-get update
# Install packages to allow apt to use a repository over HTTPS:
$ sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
# Add Docker’s official GPG key
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Update the apt package index
$ sudo apt-get update
$ sudo apt-get install docker-ce
```

**Note:** Using following command to see if Docker is installed correctly. In addition, the official 
```bash
$ docker run hello-world
```

### Step 2: cuda installation
