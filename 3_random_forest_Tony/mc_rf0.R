#source("http://bit.ly/sentiment_required_packages")	
require(caret)
require(randomForest)
require(e1071)
require(openxlsx)
require(Hmisc)

load("data_clean/step3.rda")

category = read.xlsx("data_clean/variable_identification.xlsx")	

set.seed(12345)	
orders = sample(1:8000,8000)	
voter_train = voter[orders[1:6400],]	
voter_test = voter[orders[6401:8000],]	

# impute with random value
voter_train = apply(voter_train, 2,	
                    function(x) Hmisc::impute(x, 'random'))	
voter_train = as.data.frame(voter_train, stringsAsFactors = F)	


# ordinal and contious variables	
col_num = which(category$category %in% c("1.0", "3.0"))	
for (i in 1:length(col_num)) {	
    if (sum(is.na(as.numeric(voter_train[,col_num[i]]))) == 0) {	
        voter_train[,col_num[i]] =	
            as.numeric(voter_train[,col_num[i]])	
    } else {	
        # if convert failed, it is not numeric	
        col_num[i] = NA	
    }	
}	
col_num = col_num[!is.na(col_num)]	
	
# convert factor	
count = 1	
drop_col = rep(NA, 200)	
col_fac = which(! 1:ncol(voter_train) %in% col_num)	
# View(voter_train[1:100, col_fac])	
for (i in 1:length(col_fac)) {	
    voter_train[,col_fac[i]] = as.factor(voter_train[,col_fac[i]])	
    if (length(levels(voter_train[,col_fac[i]])) <= 1) {	
        drop_col[count] = col_fac[i]	
        count = count + 1	
    }	
}	
drop_col = drop_col[!is.na(drop_col)]	
voter_train = voter_train[,-drop_col]	
voter_train = voter_train[,-c(1:2)]	
	
# we only care about 3 classes for results, so convert:	
	
r = as.character(voter_train$presvote16post_2016)	
r = ifelse(r %in% c("donald trump", "hillary clinton"), r, "others")	
voter_train$presvote16post_2016 = as.factor(r)	
	
# repeat the same for voter_test	
	
voter_test = apply(voter_test, 2,	
                   function(x) Hmisc::impute(x, 'random'))	
voter_test = as.data.frame(voter_test, stringsAsFactors = F)	
	
for (i in 1:length(col_num)) {	
    voter_test[,col_num[i]] =	
        as.numeric(voter_test[,col_num[i]])	
}	
	
for (i in 1:length(col_fac)) {	
    voter_test[,col_fac[i]] = as.factor(voter_test[,col_fac[i]])	
}	
	
voter_test = voter_test[,-drop_col]	
voter_test = voter_test[,-c(1:2)]	
	
r1 = as.character(voter_test$presvote16post_2016)	
r1 = ifelse(r1 %in% c("donald trump", "hillary clinton"),	
            r1, "others")	
voter_test$presvote16post_2016 = as.factor(r1)