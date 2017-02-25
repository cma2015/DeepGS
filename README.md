# ___DeepGS for genomic selection___ <br>
![](https://halobi.com/wp-content/uploads/2016/08/r_logo.png "R logo")
![](https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQ9QzjrA2qTP2LDqW14coedJZMry4JKbPel2eyJUqCgbcqaQePN "linux logo")
<br>
The R package 'DeepGS' can be used to perform genomic selection (GS), which is a promising
breeding strategy in plants and animals. DeepGS predicts phenotypes using genomewide
genotypic markers with an advanced machine learning technique (deep learning). The effectiveness
of DeepGS has been demonstrated in predicting eight phenotypic traits on a population
of 2000 Iranian bread wheat (Triticum aestivum) lines from the wheat gene bank of the International
Maize and Wheat Improvement Center (CIMMYT).
<br>
## Version and download <br>
* [Version 1.0](https://github.com/cma2015/DeepGS/blob/master/DeepGS_1.0.tar.gz) -First version release <br>

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
More details see [user manual](https://github.com/cma2015/DeepGS/blob/master/DeepGS.pdf)<br>
#### Data preparation and paramaters setting 
```R
## load example data
data(wheat_example)
Markers <- wheat_example$Markers
y <- wheat_example$y
cvSampleList <- cvSampleIndex(length(y),10,1)
## cross validation set
cvIdx <- 1
trainIdx <- cvSampleList[[cvIdx]]$trainIdx
testIdx <- cvSampleList[[cvIdx]]$testIdx
## set DeepGS paramaters
conv_kernel <- c("4*4","5*5") ## convolution kernels (fileter shape)
conv_num_filter <- c(20,28) ## number of filters
pool_act_type <- c("relu","relu") ## active function for next pool
pool_type <- c("max","max") ## Max pooling shape
pool_kernel <- c("2*2","2*2") ## pooling shape
pool_stride <- c("2*2","2*2") ## number of pool kernerls
fullayer_num_hidden <- c(56,1)
fullayer_act_type <- c("sigmoid")
cnnFrame <- list(conv_kernel =conv_kernel,conv_num_filter = conv_num_filter,
                 pool_act_type = pool_act_type,pool_type = pool_type,pool_kernel =pool_kernel,
                 pool_stride = pool_stride,fullayer_num_hidden= fullayer_num_hidden,
                 fullayer_act_type = fullayer_act_type)
```
#### Training DeepGS model
```R
trainGSmodel <- train_GSModel(trainMat = Markers[trainIdx,],trainPheno = y[trainIdx],
                              imageSize = "35*35", cnnFrame = cnnFrame,device_type = "cpu",
                              gpuNum = 1, eval_metric = "mae", num_round = 30,
                              array_batch_size= 100,learning_rate = 0.01, momentum = 0,
                              wd = 0, randomseeds = 0,initializer_idx = 0.01)
```
#### Prediction 
```R
predscores <- predict_GSModel(GSModel = trainGSmodel,testMat = Markers[testIdx,],imageSize = "35*35")
```
#### Performance assement
```R
refer_value <- runif(100)
pred_value <- sin(refer_value) + cos(refer_value)
meanNDCG(realScores = refer_value,predScores = pred_value, topK = 10)
```

## Ask Questions
Please use [DeepGS/issues](https://github.com/cma2015/DeepGS/issues) for how to use DeepGS and reporting bugs
