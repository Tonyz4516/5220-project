# set new mark column, and fill NA with neutral
require(readr)
require(dplyr)
require(plotly)
require(tidyr)

voter <- read_csv("step2_voter.csv")

source("convert_agree_disagree.R") # must run this to obtain vector: filtered & loc19
nm <- colnames(voter)[c(filtered,loc19)]

for (i in 1:59) {
    new_name <- paste0(nm[i], "_mark")
    voter[[new_name]] <- ifelse(is.na(voter[[nm[i]]]), 0, 1) # new mark column
    voter[[nm[i]]] <- ifelse(is.na(voter[[nm[i]]]), 0, voter[[nm[i]]]) # fill NA with neutral value
}

# find col with one valid level + NA
lu <- apply(voter, 2, function(x) {
    return(length(unique(x)))
}) # vector: number of unique value for each col

loc_2_level <- which(lu == 2)

rm_na <- apply(voter[,loc_2_level], 2, function(x){
    return(sum(is.na(unique(x))))
}) # vector: if one out of two unique value is NA

loc_rm_na <- loc_2_level[which(rm_na == 1)]

# turns out, there is only one col with one valid variable and NA
# which is: post_SenCand2Party_2012 # 451

voter <- voter[,-which(colnames(voter) == "post_SenCand2Party_2012")]

save(voter, nm, file = "step3.rda")
write.csv(voter, "step3_voter.csv")
