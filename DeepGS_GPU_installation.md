## DeepGS_GPU Docker image installation

### System requirements
* Ubuntu (>= 16.04)

### Step 1: install the latest version of Docker
```bash
# Take ubuntu 16.04 as an example
# Uninstall old versions
sudo apt-get remove docker docker-engine docker.io
# Update the apt package index
sudo apt-get update
# Install packages to allow apt to use a repository over HTTPS:
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Update the apt package index
sudo apt-get update
sudo apt-get install docker-ce
```

**Note:** Using following command to see if Docker is installed correctly. In addition, you can also refer to official manual (https://docs.docker.com/install) to install the latest Docker 
```bash
sudo docker run hello-world
```

### Step 2: cuda installation
```bash
# Take cuda 8.0 as an example
wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb
mv cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64.deb
sudo apt-get update
sudo apt-get install cuda-8-0
nvcc -V #The following information will be printed if cuda is installed correctly
nvcc: NVIDIA (R) Cuda compiler driver 
Copyright (c) 2005-2016 NVIDIA Corporation
Built on Tue_Jan_10_13:22:03_CST_2017
Cuda compilation tools, release 8.0, V8.0.61
```

### Step 3: Nvidia-docker installation
```bash
# Add the package repositories
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update

# Install nvidia-docker2 and reload the Docker daemon configuration
sudo apt-get install -y nvidia-docker2
```

### Step 4: Docker-engine setup
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker


sudo tee /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
sudo pkill -SIGHUP dockerd
# Checking nvidia-docker
nvidia-docker run —runtime=nvidia —rm nvidia/cuda nvidia-smi # If nvidia-docker is installed correctly, the graphics information will be printed
```
**Note:** Instructions above may not be available for different computers, please refer to (https://github.com/NVIDIA/nvidia-docker) official instructions.

### Step 5: DeepGS_GPU installation and quckly start
```bash
docker pull malab/deepgs_gpu
# Quickly start for deepgs_gpu
docker run --runtime=nvidia malab/deepgs_gpu Rdata(wheat_example)
```

### Step 6: Running a training exmaple of DeepGS
 ```R
 Markers <- wheat_example$Markers
y <- wheat_example$y
cvSampleList <- cvSampleIndex(length(y),10,1)
# cross validation set
cvIdx <- 1
trainIdx <- cvSampleList[[cvIdx]]$trainIdx
testIdx <- cvSampleList[[cvIdx]]$testIdx
trainMat <- Markers[trainIdx,]
trainPheno <- y[trainIdx]
validIdx <- sample(1:length(trainIdx),floor(length(trainIdx)*0.1))
validMat <- trainMat[validIdx,]
validPheno <- trainPheno[validIdx]
trainMat <- trainMat[-validIdx,]
trainPheno <- trainPheno[-validIdx]
conv_kernel <- c("1*18") ## convolution kernels (fileter shape)
conv_stride <- c("1*1")
conv_num_filter <- c(8)  ## number of filters
pool_act_type <- c("relu") ## active function for next pool
pool_type <- c("max") ## max pooling shape
pool_kernel <- c("1*4") ## pooling shape
pool_stride <- c("1*4") ## number of pool kernerls
fullayer_num_hidden <- c(32,1)
fullayer_act_type <- c("sigmoid")
drop_float <- c(0.2,0.1,0.05)
cnnFrame <- list(conv_kernel =conv_kernel,conv_num_filter = conv_num_filter,
                 conv_stride = conv_stride,pool_act_type = pool_act_type,
                 pool_type = pool_type,pool_kernel =pool_kernel,
                 pool_stride = pool_stride,fullayer_num_hidden= fullayer_num_hidden,
                 fullayer_act_type = fullayer_act_type,drop_float = drop_float)

markerImage = paste0("1*",ncol(trainMat))
trainGSmodel <- train_deepGSModel(trainMat = trainMat,trainPheno = trainPheno,
                validMat = validMat,validPheno = validPheno, markerImage = markerImage, 
                cnnFrame = cnnFrame,device_type = "gpu",gpuNum = 1, eval_metric = "mae",
                num_round = 6000,array_batch_size= 30,learning_rate = 0.01,
                momentum = 0.5,wd = 0.00001, randomseeds = 0,initializer_idx = 0.01)
 ```
