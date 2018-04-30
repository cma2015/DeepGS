# ___DeepGS for genomic selection___ <br>
![](https://halobi.com/wp-content/uploads/2016/08/r_logo.png "R logo")
![](https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSvCvZWbl922EJkjahQ5gmTpcvsYr3ujQBpMdyX-YG99vGWfTAmfw "linux logo")
![](https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcS3RzhXKSfXpWhWhvClckwi1Llj1j3HvjKpjvU8CQv4cje23TwS "windows logo")
<br>
The R package 'DeepGS' can be used to perform genomic selection (GS), which is a promising
breeding strategy in plants and animals. DeepGS predicts phenotypes using genomewide
genotypic markers with an advanced machine learning technique (deep learning). The effectiveness
of DeepGS has been demonstrated in predicting eight phenotypic traits on a population
of 2000 Iranian bread wheat (Triticum aestivum) lines from the wheat gene bank of the International
Maize and Wheat Improvement Center (CIMMYT).
<br>
## Version and download <br>
* [Version 1.0](https://github.com/cma2015/DeepGS/blob/master/DeepGS_1.0.tar.gz) -First version released on Feb, 15th, 2017<br>
* [Version 1.1](https://github.com/cma2015/DeepGS/blob/master/DeepGS_1.1.tar.gz) -Second version released on Oct, 12th, 2017<br>
1.'ELBPSO' funtion was added for ensemble learning based on particle swarm optimization (ELBPSO) <br>
2.Update package document <br>
3.Function optimization for building deep learning Genomic selection prediction model <br>
## Installation <br>
```R
install.package("Download path/DeepGS_1.0.tar.gz")
```
<br>

## Depends
* [R](https://www.r-project.org/) (>= 3.3.1) <br>
* [mxnet](https://github.com/dmlc/mxnet) (>= 0.6)<br>

## Contents
* Example data <br>
* Trainning model  <br>
* Performance assement <br>
* Cross validation <br>
* [User manual](https://github.com/cma2015/DeepGS/blob/master/DeepGS.pdf)<br>

## Quick start
More details please see [user manual](https://github.com/cma2015/DeepGS/blob/master/DeepGS.pdf)<br>
#### Data preparation and paramaters setting 
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
#### Training DeepGS model
```R
trainGSmodel <- train_deepGSModel(trainMat = trainMat,trainPheno = trainPheno,
                validMat = validMat,validPheno = validPheno, markerImage = markerImage, 
                cnnFrame = cnnFrame,device_type = "cpu",gpuNum = 1, eval_metric = "mae",
                num_round = 6000,array_batch_size= 30,learning_rate = 0.01,
                momentum = 0.5,wd = 0.00001, randomseeds = 0,initializer_idx = 0.01)
```
#### Prediction 
```R
predscores <- predict_GSModel(GSModel = trainGSmodel,testMat = Markers[testIdx,],
              markerImage = markerImage )
```
#### Performance assement
```R
refer_value <- runif(100)
pred_value <- sin(refer_value) + cos(refer_value)
meanNDCG(realScores = refer_value,predScores = pred_value, topK = 10)
```
#### ELBPSO
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

new_pre <- (test_predMat % * % weight)/sum(weight)
```
## Ask questions
Please use [DeepGS/issues](https://github.com/cma2015/DeepGS/issues) for how to use DeepGS and reporting bugs.
