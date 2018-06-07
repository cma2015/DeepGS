# ___DeepGS for genomic selection___ <br>
![](https://halobi.com/wp-content/uploads/2016/08/r_logo.png "R logo")
![](https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSvCvZWbl922EJkjahQ5gmTpcvsYr3ujQBpMdyX-YG99vGWfTAmfw "linux logo")
![](https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcS3RzhXKSfXpWhWhvClckwi1Llj1j3HvjKpjvU8CQv4cje23TwS "windows logo")
<br>
The R package 'DeepGS' can be used to perform genomic selection (GS), which is a promising
breeding strategy in plants and animals. DeepGS predicts phenotypes using genomewide
genotypic markers with an advanced machine learning technique (deep learning). The effectiveness
of DeepGS has been demonstrated in predicting eight phenotypic traits on a population
of 2000 Iranian bread wheat (_Triticum aestivum_) lines from the wheat gene bank of the International
Maize and Wheat Improvement Center (CIMMYT).
<br>
## Version and download <br>
* [Version 1.0](https://github.com/cma2015/DeepGS/blob/master/DeepGS_1.0.tar.gz) -First version released on Feb, 15th, 2017<br>
* [Version 1.1](https://github.com/cma2015/DeepGS/blob/master/DeepGS_1.1.tar.gz) -Second version released on Oct, 12th, 2017<br>
* [Version 1.2](https://github.com/cma2015/DeepGS/blob/master/DeepGS_1.2.tar.gz) -Third version released on Oct, 12th, 2018<br>
1.'ELBPSO' funtion was added for ensemble learning based on particle swarm optimization (ELBPSO) <br>
2.Update package document <br>
3.Function optimization for building deep learning Genomic selection prediction model <br>
## DeepGS-CPU Installation ##
### Docker installation and start ###
#### For Windows (Test on Windows 10 Enterprise version): ####
* Download [Docker](<https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe>) for windows </br>
* Double click the EXE file to open it;
* Follow the wizard instruction and complete installation;
* Search docker, select ___Docker for Windows___ in the search results and clickit.
#### For Mac OS X (Test on macOS Sierra version 10.12.6 and macOS High Sierra version 10.13.3): ####
* Download [Docker](<https://download.docker.com/mac/stable/Docker.dmg>) for Mac os <br>
* Double click the DMG file to open it;
* Drag the docker into Applications and complete installation;
* Start docker from Launchpad by click it.
#### For Ubuntu (Test on Ubuntu 14.04 LTS and Ubuntu 16.04 LTS): ####
* Go to [Docker](<https://download.docker.com/linux/ubuntu/dists/>), choose your Ubuntuversion, browse to ___pool/stable___ and choose ___amd64, armhf, ppc64el or s390x.____ Download the ___DEB___ file for the Docker version you want to install;
* Install Docker, supposing that the DEB file is download into following path:___"/home/docker-ce<version-XXX>~ubuntu_amd64.deb"___ </br>
```bash
$ sudo dpkg -i /home/docker-ce<version-XXX>~ubuntu_amd64.deb      
$ sudo apt-get install -f
```
 ### Verify if Docker is installed correctly ### 
----------------------------------------
   Once Docker installation is completed, we can run ____hello-world____ image to verify if Docker is installed correctly. Open terminal in Mac OS X and Linux operating system and open CMD for Windows operating system, then type the following command:
```bash
$ docker run hello-world
```
   **<font color =red>Note</font>:** root permission is required for Linux operating system.
   **<font color =red>Note</font>:** considering that differences between different computers may exist, please refer to [official installation manual](https://docs.docker.com/install) if instructions above don’t work.
### DeepGS-CPU Docker image installation and quickly start ### 

```bash
$ docker pull malab/deepgs_cpu
$ docker run -it -v /host directory of dataset:/home/data malab/deepgs_cpu R  
```
**Note:** Supposing that users’ private dataset is located in directory ___`/home/test`____, then change the words above (____`/host directory of dataset`____) to host directory (____`/home/test`____)  
```R
library(DeepGS)  
setwd("/home/data/")  
```
**Important:** the directory (____`/home/data/`____) is a virtual directory in DeepGS Docker image. In order to use private dataset more easily, the parameter “-v” is strongly recommended to mount host directory of dataset to DeepGS image.  

## DeepGS-GPU Installation ##
The details of DeepGS installation are available at: https://github.com/cma2015/DeepGS/blob/master/DeepGS_GPU_installation.md

## Data preparation and paramaters setting 
```R
data(wheat_example)
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

```
## Training DeepGS model
```R
trainGSmodel <- train_deepGSModel(trainMat = trainMat,trainPheno = trainPheno,
                validMat = validMat,validPheno = validPheno, markerImage = markerImage, 
                cnnFrame = cnnFrame,device_type = "cpu",gpuNum = 1, eval_metric = "mae",
                num_round = 6000,array_batch_size= 30,learning_rate = 0.01,
                momentum = 0.5,wd = 0.00001, randomseeds = 0,initializer_idx = 0.01,
                verbose = TRUE)
```
## Prediction 
```R
predscores <- predict_GSModel(GSModel = trainGSmodel,testMat = Markers[testIdx,],
              markerImage = markerImage )
```
## Performance evaluation
```R
refer_value <- runif(100)
pred_value <- sin(refer_value) + cos(refer_value)
meanNDCG(realScores = refer_value,predScores = pred_value, topAlpha = 10)
```
## ELBPSO
```R
## Not run
# example for rrBLUP model
# library(DeepGS)
# library(rrBLUP)
# data("wheat_example")
# Markers <- wheat_example$Markers
# y <- wheat_example$y
# cvSampleList <- cvSampleIndex(length(y),10,1)
## select one fold
# cvIdx <- 1
# trainIdx <- cvSampleList[[cvIdx]]$trainIdx
# testIdx <- cvSampleList[[cvIdx]]$testIdx
# trainMat = Markers[trainIdx,]
# trainPheno = y[trainIdx]
# testMat = Markers[testIdx,]
# testPheno = y[testIdx]
# rrBLUP_obj <-mixed.solve(trainPheno, Z=trainMat, K=NULL, SE = FALSE, return.Hinv=FALSE)
# rrBLUP_pred <-  testMat %*% rrBLUP_obj$u + as.numeric(rrBLUP_obj$beta )
## End not run 
# calculating the weight of different training model by using their predict socres
test_datapath <- system.file("exdata", "test_ELBPSO.RData",
                             package = "DeepGS")
load(test_datapath)
weight <- ELBPSO(rep_times = 100,interation_times = 25,weight_dimension = 2,
                 weight_min = 0,weight_max=1,rate_min = -0.01,rate_max = 0.01,
                 paticle_number = 10, pred_matrix = train_predMat,IW = 1,
                 AF1 = 2, AF2 = 2)

new_pre <- (test_predMat %*% weight)/sum(weight)
```
## Ask questions
Please use [DeepGS/issues](https://github.com/cma2015/DeepGS/issues) for how to use DeepGS and reporting bugs.
