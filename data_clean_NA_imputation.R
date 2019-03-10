require(dplyr)
require(tidyverse)

data <- read_csv("VOTER_Survey_December16_Release1.csv",
                 na = c("", "NA", "__NA__"))

stat_NA <- rep(NA,ncol(data))

for(i in 1:ncol(data)){
    stat_NA[i]=sum(is.na(data[,i]))/nrow(data[,i])
}

# hist(stat_NA)

count <- as.numeric(0)
for(i in 1:length(stat_NA)){
    if (stat_NA[i]>=0.5) count <- count+1
}
remove_list <- rep(0,count)

# stat_NA[which(stat_NA >= 0.5)]
remove_list <- which(stat_NA >= 0.5)
data_1 <- data[,-remove_list]

sum(is.na(data_1))

require(Hmisc)
data_2 <- impute(data_1)

sum(is.na(data_2))