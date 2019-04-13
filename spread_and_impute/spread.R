source("http://bit.ly/sentiment_required_packages")
library(caret) # for dummyVars
library(data.table)
rm(list = ls())

load("data_clean/step3.rda")

orders = 
    read.xlsx("data_clean/variable_identification.xlsx")

# one hot encoding (spread) for categorical data
loc = which(colnames(voter) %in% orders$X1[which(orders$category == "2.0")])

adjust = as.data.frame(apply(voter[,loc], 2, as.factor))
dmy = dummyVars(" ~ .", data = adjust)
newdf <- data.frame(predict(dmy, newdata = adjust))

voter2 = cbind(voter[,-loc], newdf)
# NA_col = apply(voter2, 2, function(x) sum(is.na(x)))
# voter2 = voter2[,-which(NA_col >= 4000)]

# train-test split
set.seed(12345)
folds <- cut(sample(1:8000,8000), breaks=10, labels=FALSE)
voter_train <- voter2[which(folds %in% 1:8),]
voter_test <- voter2[which(folds %in% 9:10),]

# impute train
library(mice)
voter_train_imp <- mice(voter_train, m=5, maxit = 50,
                        method = 'pmm', seed = 500)
