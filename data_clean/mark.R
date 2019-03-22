# set new mark column, and fill NA with neutral
voter <- voter2
nm <- colnames(voter2)[c(loc[c(loc0, loc1)],
                         40,41,43,186,187,117,118,119,153,275)]
for (i in 1:59) {
    new_name <- paste0(nm[i], "_mark")
    voter2[[new_name]] <- ifelse(is.na(voter2[[nm[i]]]), 0, 1) # new mark column
    voter2[[nm[i]]] <- ifelse(is.na(voter2[[nm[i]]]), 0, voter2[[nm[i]]]) # fill NA with neutral value
}

# find col with one valid level + NA
lu <- apply(voter2, 2, function(x) {
    return(length(unique(x)))
}) # vector: number of unique value for each col

loc_2_level <- which(lu == 2)

rm_na <- apply(voter2[,loc_2_level], 2, function(x){
    return(sum(is.na(unique(x))))
}) # vector: if one out of two unique value is NA

loc_rm_na <- loc_2_level[which(rm_na == 1)]

# turns out, there is only one col with one valid variable and NA
# which is: post_SenCand2Party_2012