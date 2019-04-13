# impute train
library(mice)
voter_train_imp <- mice(voter_train, m=5, maxit = 50,
                        method = 'pmm', seed = 500)