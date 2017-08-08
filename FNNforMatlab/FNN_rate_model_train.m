%feed forward neural network (FNN) for genomic selection
function FNN_rate_model_train(parallel_num,data_path,save_path,hidden)
%select how many decives used to train the model
parpool(parallel_num,'IdleTimeout', 6000);
%load the data
load(data_path);
SNP=SNP';    
[~,trait_size]=size(pheno);
for j=1:trait_size
    disp(['trait ', num2str(j)])
    trait_y=pheno(:,j)';%extract the phenotype data    
    best_train_FNN=cell(10,1);%save the trained model
    tic
    parfor i=1:parallel_num %parallel computation of the 10-fold cross validation        
        inputs_train=SNP(:,crossvalind(:,i)==0);% train set = 0
        targets_train=trait_y(:,crossvalind(:,i)==0);%train target set = 0
        inputs_test=SNP(:,crossvalind(:,i)==1);% test set = 1
        targets_test=trait_y(:,crossvalind(:,i)==1);%test target set = 0
        best_train_FNN{i,1}=FNN_rate_model_train_max(inputs_train,targets_train,hidden);%find the best FNN model    
        inputs_testn_FNN=inputs_test ;           
        probality{i,1}=FNN_rate_model_max_once(inputs_testn_FNN,targets_test,best_train_FNN{i,1});%evaluate the FNN model on test set

    end
    toc
    %combind the 10-fold cross validation result
    for i=1:10
       predict_phenotype(crossvalind(:,i)==1,j)=((probality{i,1})');
       %predict_phenotype(crossvalind(:,i)==1,j)=((probality{i,1})')/2-flag(j);
    end
    %calculated the correlation between the predicted and real data
    rr=corrcoef(predict_phenotype(:,j),trait_y');
    R(1,j)=rr(1,2);
end
%save result
save(save_path,'predict_phenotype','R','pheno')   
%close the parallel tool
delete(gcp)
end 


%find the best FNN model 
function net=FNN_rate_model_train_max(a_train,b_train)
    an_train = a_train ;
    targetsTr_FNN = b_train ;
    clear net
    %constuct the FNN model
    net = feedforwardnet([18 32]);
    net.trainFcn = 'trainscg';
    net.trainParam.showWindow = false;
    net.trainParam.showCommandLine = false;
    net.trainParam.epochs = 6000;
    net.trainParam.max_fail = 600;    
    net.divideParam.trainRatio=0.9;
    net.divideParam.valRatio=0.1;    
    %initialize the FNN model
    net=init(net);
    %train the FNN model
    [net,~] = train(net, an_train, targetsTr_FNN) ; 
end
    
%evaluate the FNN model on test set
function net=FNN_rate_model_max_once(inputs_testn_FNN,targetsTst,best_train_FNN)
    net =best_train_FNN(inputs_testn_FNN);
end    
