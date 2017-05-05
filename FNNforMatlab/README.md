# ___FNN model for genomic selection in matlab___ <br>
![](https://halobi.com/wp-content/uploads/2016/08/r_logo.png "R logo")
![](https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSvCvZWbl922EJkjahQ5gmTpcvsYr3ujQBpMdyX-YG99vGWfTAmfw "linux logo")
![](https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcS3RzhXKSfXpWhWhvClckwi1Llj1j3HvjKpjvU8CQv4cje23TwS "windows logo")
<br>
The implementation of Feedforward Multilayer Neural Network (FNN) model in matlab for genomic selection(GS).
<br>
## Code download <br>
* [FNN_rate_model_train](https://github.com/cma2015/DeepGS/blob/master/FNNforMatlab/FNN_rate_model_train.m)<br>

## Depends
* [matlab](https://www.mathworks.com/products/matlab.html) (>= Version 2015) <br>
* parpool for parallel(matlab version > 2015 )<br>

## Contents
* [Example data](https://github.com/cma2015/DeepGS/blob/master/FNNforMatlab/wheat.mat) <br>
* [Trainning model](https://github.com/cma2015/DeepGS/blob/master/FNNforMatlab/FNN_rate_model_train.m)  <br>

## Quick start
```matlab
%you may implement the FNN by the following steps
%clear variables 
clear
FNN_path = './FNN';%set FNN model path
data_path = './wheat.mat';%set dataset path
                          %crossvalind represents for the cross-validation label
                          %pheno represents for the phenotype
                          %SNP represents for the SNP marker matrix
save_path = './FNN_result.mat';%set saved result path
hidden = [35 35];%set hidden neurons
%you must use the MATLAB version no later than MATLAB2015,since the parallel tool used is the parpool
parallel_num = 10;%fit for the 10fold CV, the parallel devices were set to 10
%add the path where the model is located
addpath(genpath(FNN_path))
FNN_rate_model_train(parallel_num,data_path,save_path,hidden)
%you will get a result of FNN_result.mat
%the predict_phenotype represents for the predicted values
%the pheno represents for the real values
%the R represents for the correaltion between the predicted and real values
```
## Ask questions
Please use [DeepGS/issues](https://github.com/cma2015/DeepGS/issues) for how to use FNN and reporting bugs
