#script name: llc_0028_LCA_pooled_syntax_v1.r
#date created: 13.7.23
#date last edited: 26.04.24
#script authors: Teri North, Charlotte James
#script purpose: to read in the harmonised, pooled study data file and run LCA analyses by
#                 (1) study separately (2) all pooled together 
#notes: Some of the LCA code is adapted from code originally written by Bo Hou/Charlotte Huggins
#issues to resolve: (1)study weights (study design/non-response) are to be incorporated posthoc 
#                   (2)need to read in study ids as string NOT numeric - V IMPORTANT 
#                   (3)currently set seed at start of script, should change this to before each LCA
#                   (4)check poLCA options are ok
#                   (5)check core/maximal symptom sets are correct



rm(list=ls())

#set working directory
setwd("S:/LLC_0028/data/harmonised_all")

#install relevant packages
#install.packages("poLCA")
#install.packages("parallel")
#install.packages("tidyverse")
library(poLCA)
library(parallel)
#library(tidyverse)

#read in harmonised, pooled dataset with all studies 
data<-read.csv("llc_0028_full_harmonised_data_v2.csv") # read ids as string here
data<-data.frame(data)


#keep required variables

vars_ <-c('fever','cough','throat','chest_tight','breath',
              'nose','aches','fatigue','diarrhoea','smell_taste','nausea_vomit',
              'sneezing','headache',
              'concentrating','memory','covid_status', 'study','LLC_0028_stud_id')
data<-data[vars_]

#reduce to complete cases
data <- na.omit(data)

#some checks on the completeness of the data
sum(data$study=="bcs70")
sum(data$study=="bib")
sum(data$study=="mcs")
sum(data$study=="ncds")
sum(data$study=="nextstep")
sum(data$study=="nhsd46")
sum(data$study=="track19")
sum(data$study=="twins")
sum(data$study=="alspac")

#rows should be individuals, columns should be symptoms
#recode to 1=no symptom present; 2=yes symptom present
#currently we have 0=no symptoms present; 1=symptoms present
#to map from 0/1 to 1/2, add 1 to the variable so 0-->1 and 1-->2

data$fever<-data$fever+1
data$cough<-data$cough+1
data$throat<-data$throat+1
data$chest_tight<-data$chest_tight+1
data$breath<-data$breath+1
data$nose<-data$nose+1
data$aches<-data$aches+1
data$fatigue<-data$fatigue+1
data$diarrhoea<-data$diarrhoea+1
data$smell_taste<-data$smell_taste+1
data$nausea_vomit<-data$nausea_vomit+1
data$sneezing<-data$sneezing+1
data$headache<-data$headache+1
data$concentrating<-data$concentrating+1
data$memory<-data$memory+1


#set seed for reproducibility
set.seed(01010) # same seed as Bowyer et al.(2023) 
#European Jnl Epidemiol.38(2)199-210

#create a categorical variable for cohort study
#1=bcs70
#2=bib
#3=mcs
#4=ncds
#5=nextstep
#6=nhsd46
#7=track19
#8=twins
#9=alspac
#10=sabre

data$cohort<-NA
n<-length(data$study)

for (i in 1:n){
  if (data$study[i]=="bcs70"){
    data$cohort[i]<-1
  } else if (data$study[i]=="bib"){
    data$cohort[i]<-2
  } else if (data$study[i]=="mcs"){
    data$cohort[i]<-3
  } else if (data$study[i]=="ncds"){
    data$cohort[i]<-4
  } else if (data$study[i]=="nextstep"){
    data$cohort[i]<-5
  } else if (data$study[i]=="nhsd46"){
    data$cohort[i]<-6
  } else if (data$study[i]=="track19"){
    data$cohort[i]<-7
  } else if (data$study[i]=="twins"){
    data$cohort[i]<-8
  } else if (data$study[i]=="alspac"){
    data$cohort[i]<-9
  } else if (data$study[i]=="sabre"){
    data$cohort[i]<-10
  }
}

############################
#define function to run LCA#
############################


run_lca <- function(f, data, max_iter, n_rep, fname){
  
  
  #real run - from 1 to 5 classes
  lc1 <- poLCA(f, data, nclass = 1, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('1 class complete')

  lc2 <- poLCA(f, data, nclass = 2, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('2 class complete')

  lc3 <- poLCA(f, data, nclass = 3, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('3 class complete')

  lc4 <- poLCA(f, data, nclass = 4, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('4 class complete')

  lc5 <- poLCA(f, data, nclass = 5, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('5 class complete')
  
  lc6 <- poLCA(f, data, nclass = 6, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('6 class complete')
  
  lc7 <- poLCA(f, data, nclass = 7, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('7 class complete')
  
  lc8 <- poLCA(f, data, nclass = 8, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('8 class complete')
  
  lc9 <- poLCA(f, data, nclass = 9, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('9 class complete')
  
  lc10 <- poLCA(f, data, nclass = 10, maxiter = max_iter, na.rm =F,
               nrep = n_rep, verbose = T)
  print('10 class complete')
  
  gc()
  
  #Extract model fit statistics 
  
  #ent2 <- poLCA.entropy(lc2)
  #ent3 <- poLCA.entropy(lc3)
  #ent4 <- poLCA.entropy(lc4)
  #ent5 <- poLCA.entropy(lc5)
  
  print('entropy calculated')
  
  ##RELATIVE ENTROPY (DOUBLE CHECK THIS FORMULA)
  ##Numerator:
  nume.2 <- -sum(lc2$posterior * log(lc2$posterior))
  nume.3 <- -sum(lc3$posterior * log(lc3$posterior))
  nume.4 <- -sum(lc4$posterior * log(lc4$posterior))
  nume.5 <- -sum(lc5$posterior * log(lc5$posterior))
  nume.6 <- -sum(lc6$posterior * log(lc6$posterior))
  nume.7 <- -sum(lc7$posterior * log(lc7$posterior))
  nume.8 <- -sum(lc8$posterior * log(lc8$posterior))
  nume.9 <- -sum(lc9$posterior * log(lc9$posterior))
  nume.10 <- -sum(lc10$posterior * log(lc10$posterior))
  print('numerator calculated')
  
  ##Denominator (n*log(K)): ## n is a sample size, and K is a number of class
  ssize <-length(data$LLC_0028_stud_id) # need to check no duplicates!
  deno.2 <- ssize*log(2)
  deno.3 <- ssize*log(3)
  deno.4 <- ssize*log(4)
  deno.5 <- ssize*log(5)
  deno.6 <- ssize*log(6)
  deno.7 <- ssize*log(7)
  deno.8 <- ssize*log(8)
  deno.9 <- ssize*log(9)
  deno.10 <- ssize*log(10)
  print('denominator calculated')

  #NOTE: Original BiB R script also includes adjusted BIC and "smallest class" 
  #- see script for more detail
  
  #data frame to store results
  results <- data.frame(Model=integer(),
                        log_likelihood=double(),
                        df = double(),
                        BIC=double(),
                        AIC = double(), 
                        likelihood_ratio=double(),
                        entropy = double(),
                        paramets = double(),
                        ssize = integer())
  
  results[1,1]<-1
  results[2,1]<-2
  results[3,1]<-3
  results[4,1]<-4
  results[5,1]<-5
  results[6,1]<-6
  results[7,1]<-7
  results[8,1]<-8
  results[9,1]<-9
  results[10,1]<-10
  
  results[1,2]<-lc1$llik
  results[2,2]<-lc2$llik
  results[3,2]<-lc3$llik
  results[4,2]<-lc4$llik
  results[5,2]<-lc5$llik
  results[6,2]<-lc6$llik
  results[7,2]<-lc7$llik
  results[8,2]<-lc8$llik
  results[9,2]<-lc9$llik
  results[10,2]<-lc10$llik
  print('llik added')
  
  results[1,3]<-lc1$resid.df
  results[2,3]<-lc2$resid.df
  results[3,3]<-lc3$resid.df
  results[4,3]<-lc4$resid.df
  results[5,3]<-lc5$resid.df
  results[6,3]<-lc6$resid.df
  results[7,3]<-lc7$resid.df
  results[8,3]<-lc8$resid.df
  results[9,3]<-lc9$resid.df
  results[10,3]<-lc10$resid.df
  print('resid added')
  
  results[1,4]<-lc1$bic
  results[2,4]<-lc2$bic
  results[3,4]<-lc3$bic
  results[4,4]<-lc4$bic
  results[5,4]<-lc5$bic
  results[6,4]<-lc6$bic
  results[7,4]<-lc7$bic
  results[8,4]<-lc8$bic
  results[9,4]<-lc9$bic
  results[10,4]<-lc10$bic
  print('bic added')
  
  results[1,5]<- lc1$aic
  results[2,5]<- lc2$aic 
  results[3,5]<- lc3$aic
  results[4,5]<- lc4$aic
  results[5,5]<- lc5$aic
  results[6,5]<- lc6$aic
  results[7,5]<- lc7$aic 
  results[8,5]<- lc8$aic
  results[9,5]<- lc9$aic
  results[10,5]<- lc10$aic
  print('aic added')
  
  results[1,6]<-lc1$Gsq
  results[2,6]<-lc2$Gsq
  results[3,6]<-lc3$Gsq
  results[4,6]<-lc4$Gsq
  results[5,6]<-lc5$Gsq 
  results[6,6]<-lc6$Gsq
  results[7,6]<-lc7$Gsq
  results[8,6]<-lc8$Gsq
  results[9,6]<-lc9$Gsq
  results[10,6]<-lc10$Gsq 
  print('Gsq added')
  
  #Note that this populates lc1 with entropy, lc2-5 with "relative entropy"
  results[1,7]<- 1 #
  results[2,7]<- 1-(nume.2/deno.2)
  results[3,7]<- 1-(nume.3/deno.3)
  results[4,7]<- 1-(nume.4/deno.4)
  results[5,7]<- 1-(nume.5/deno.5)
  results[6,7]<- 1-(nume.6/deno.6)
  results[7,7]<- 1-(nume.7/deno.7)
  results[8,7]<- 1-(nume.8/deno.8)
  results[9,7]<- 1-(nume.9/deno.9)
  results[10,7]<- 1-(nume.10/deno.10)
  
  results[1,8]<- lc1$npar
  results[2,8]<- lc2$npar
  results[3,8]<- lc3$npar
  results[4,8]<- lc4$npar
  results[5,8]<- lc5$npar
  results[6,8]<- lc6$npar
  results[7,8]<- lc7$npar
  results[8,8]<- lc8$npar
  results[9,8]<- lc9$npar
  results[10,8]<- lc10$npar
  
  results[1,9]<- ssize
  results[2,9]<- ssize
  results[3,9]<- ssize
  results[4,9]<- ssize
  results[5,9]<- ssize
  results[6,9]<- ssize
  results[7,9]<- ssize
  results[8,9]<- ssize
  results[9,9]<- ssize
  results[10,9]<- ssize
  
  print('saving results')
  #save results to csv
  write.csv(results,
            paste("S:/LLC_0028/data/lca_results/v2/", fname, ".csv", sep=""),
            row.names = TRUE)
  
  #dataframe to store class assignments
  classes<-data.frame(matrix(nrow = ssize, ncol = 11))
  colnames(classes) = c('lc1','lc2','lc3','lc4','lc5',
                        'lc6','lc7','lc8','lc9','lc10',
                        'LLC_0028_stud_id')
  
  classes$lc1<- lc1$predclass
  classes$lc2<- lc2$predclass
  classes$lc3<- lc3$predclass
  classes$lc4<- lc4$predclass
  classes$lc5<- lc5$predclass
  classes$lc6<- lc6$predclass
  classes$lc7<- lc7$predclass
  classes$lc8<- lc8$predclass
  classes$lc9<- lc9$predclass
  classes$lc10<- lc10$predclass
  classes$LLC_0028_stud_id<- data$LLC_0028_stud_id
  
  write.csv(classes,
            paste("S:/LLC_0028/data/lca_results/v2/", fname, "_classes.csv", sep=""),
            row.names = TRUE)
  
  #save class probabilities

  probabilities <- data.frame(lc1$posterior)
  probabilities$LLC_0028_stud_id <- data$LLC_0028_stud_id
  
  write.csv(probabilities,
              paste("S:/LLC_0028/data/lca_results/probabilities/", fname,
                    "lc1_class_probs.csv", sep=""),
              row.names = TRUE)
  
  probabilities <- data.frame(lc2$posterior)
  probabilities$LLC_0028_stud_id <- data$LLC_0028_stud_id
  
  write.csv(probabilities,
            paste("S:/LLC_0028/data/lca_results/probabilities/", fname,
                  "lc2_class_probs.csv", sep=""),
            row.names = TRUE)
  
  probabilities <- data.frame(lc3$posterior)
  probabilities$LLC_0028_stud_id <- data$LLC_0028_stud_id
  
  write.csv(probabilities,
            paste("S:/LLC_0028/data/lca_results/probabilities/", fname,
                  "lc3_class_probs.csv", sep=""),
            row.names = TRUE)
  
  probabilities <- data.frame(lc4$posterior)
  probabilities$LLC_0028_stud_id <- data$LLC_0028_stud_id
  
  write.csv(probabilities,
            paste("S:/LLC_0028/data/lca_results/probabilities/", fname,
                  "lc4_class_probs.csv", sep=""),
            row.names = TRUE)
  
  probabilities <- data.frame(lc5$posterior)
  probabilities$LLC_0028_stud_id <- data$LLC_0028_stud_id
  
  write.csv(probabilities,
            paste("S:/LLC_0028/data/lca_results/probabilities/", fname,
                  "lc5_class_probs.csv", sep=""),
            row.names = TRUE)


  
}


########################
#define symptom vectors#
########################

f_core<-cbind(fever,cough,throat,chest_tight,breath,nose,aches,fatigue,
         diarrhoea,smell_taste,nausea_vomit,sneezing,
         headache,concentrating,memory)~study


symp_core <-c('fever','cough','throat','chest_tight','breath',
                'nose','aches','fatigue','diarrhoea','smell_taste','nausea_vomit',
                'sneezing','headache',
                'concentrating','memory','study','LLC_0028_stud_id')
########################
#define LCA parameters #
########################

max_iter=10000
n_rep=10


###########
#No covid #
###########
set.seed(01010)

reduced_dat<-subset(data, covid_status==0)
reduced_dat <- reduced_dat[,symp_core]

#core symptom set#

run_lca(f_core, reduced_dat, max_iter=max_iter, n_rep=n_rep, 
        fname="core_pooled_nocovid_2")


#clear memory#
gc()



#####################
#Covid <12 weeks ago#
#####################


set.seed(01010)
reduced_dat<-subset(data, covid_status==1)
reduced_dat <- reduced_dat[,symp_core]

run_lca(f_core, reduced_dat, max_iter=max_iter, n_rep=n_rep, 
        fname="core_pooled_l12_2")


gc()

######################
#Covid >=12 weeks ago#
######################

reduced_dat<-subset(data, covid_status==2)
reduced_dat <- reduced_dat[,symp_core]

run_lca(f_core, reduced_dat, max_iter=max_iter, n_rep=n_rep, 
        fname="core_pooled_g12_2")

rm(reduced_dat)
gc()

###############################
#All covid categories combined#
###############################


reduced_dat <- data[,symp_core]

run_lca(f_core, reduced_dat, max_iter, n_rep, 
        fname="core_pooled_all_2")


