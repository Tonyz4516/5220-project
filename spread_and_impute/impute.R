# impute train
rm(list = ls())
load("spread_and_impute/train_test.rda")

loc = rep(0, 1292)
for (i in 1:1292) {
    if (class(voter_train[,i]) == "numeric") {
        loc[i] = 1
    }
}
voter_train = voter_train[,which(loc == 1)]
voter_test = voter_test[,which(loc == 1)]

library(Amelia)
voter_train_imp <- 
    amelia(voter_train, m=1, 
           parallel = "multicore", noms = "accurately_counted_2016")
