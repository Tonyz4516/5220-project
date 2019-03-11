require(dplyr)
require(tidyverse)

# for missingness map
if (!require(Amelia)) {
    install.packages("Amelia")
    require(Amelia)
}

data <- read_csv("VOTER_Survey_December16_Release1.csv",
                 na = c("", "NA", "__NA__"))

# missingness map
# missmap(data)

co <- ncol(data)
ro <- nrow(data)
col_NA <- rep(NA, co)
row_NA <- rep(NA, ro)

for(i in 1:ncol(data)) {
    col_NA[i] <- sum(is.na(data[,i]))/ro
}

for(i in 1:nrow(data)) {
    row_NA[i] <- sum(is.na(data[i,]))/co
}

remove_col <- which(col_NA >= 0.5)
remove_row <- which(row_NA >= 0.25)
data_1 <- data[,-remove_col]
data_1 <- data_1[-remove_row,]

# missmap(data_1)

if (!require(Hmisc)) {
    install.packages("Hmisc")
    require(Hmisc)
}
data_2 <- impute(data_1)
# sum(is.na(data_2)) # should be zero
