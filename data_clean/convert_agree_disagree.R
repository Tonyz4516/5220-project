# convert agree / disagree cols to numeric
# source("data_clean.R")
# variable converted in this step: "imiss_a_2016","imiss_b_2016","imiss_c_2016","imiss_d_2016","imiss_e_2016","imiss_f_2016","imiss_g_2016","imiss_h_2016","imiss_i_2016","imiss_j_2016","imiss_k_2016","imiss_l_2016","imiss_m_2016","imiss_n_2016","imiss_o_2016","imiss_p_2016","imiss_q_2016","imiss_r_2016","imiss_s_2016","imiss_t_2016","imiss_u_2016","imiss_x_2016","imiss_y_2016","ambornin_2016","amcit_2016","amlived_2016","amenglish_2016","amchrstn_2016","amgovt_2016","amwhite_2016","amdiverse_2016","imiss_a_baseline","imiss_b_baseline","imiss_c_baseline","imiss_d_baseline","imiss_f_baseline","imiss_g_baseline","imiss_h_baseline","imiss_j_baseline","imiss_m_baseline","imiss_p_baseline","imiss_q_baseline","imiss_r_baseline","imiss_s_baseline","imiss_t_baseline","amcitizen_2016","amshamed_2016","belikeus_2016","fatalism2_baseline","persfinretro_2016","econtrend_2016","futuretrend_2016","persfinretro_baseline","econtrend_baseline","prouddem_2016","proudhis_2016","proudgrp_2016","race_fate_2016","polinterest_baseline"
require(parallel)
require(readr)
require(dplyr)
require(plotly)
require(tidyr)

# all character to lower case letter
voter2 <- as.data.frame(apply(voter2,2,function(x) return(tolower(x))),
                        stringsAsFactors = F)

# find keywords likely involving ordinal data
keywords <- c("agree", "strongly", "very", "somewhat",
              "much", "more", "less", "same", "better", "worse") 

find_them <- function(vec, keywords) {
    l <- grep(paste(keywords, collapse=" | "), 
                 vec, ignore.case = T)
    if(length(l) > 0){
        result <- unique(vec[l])
        return(result)
    }
}
re0 <- apply(voter2, 2, function(x) find_them(x, keywords))
re0[sapply(re0, is.null)] <- NULL # remove null results

# manual check them and select
loc <- which(colnames(voter2) %in% names(re0))
list0 <- mclapply(loc, function(i, data) {unique(data[,i])}, data = voter2)
# list0 is printed in github as "var_with_ordinal_data.txt"

# pattern0 for all with very important
# which covers majority of the ordinal data
pattern0 <- sapply(list0, function(x){
    sum(grepl("very important",x, ignore.case = T))
})
loc0 <- which(pattern0 > 0) # anchor for loc
# sapply(list0[loc0], function(x) length(x[[1]]))

voter2[loc[loc0]] <- apply(voter2[loc[loc0]],2,function(x){
    x <- ifelse(x == "very important", 2, x)
    x <- ifelse(x == "somewhat important" | x == "fairly important",
                1, x)
    x <- ifelse(x == "not very important", -1, x)
    x <- ifelse(x == "unimportant" | x == "not important at all", -2, x)
    x <- ifelse(x == "don't know", NA, x)
})

# pattern1 for all with "agree"
pattern1 <- sapply(list0, function(x){
    sum(grepl("agree",x, ignore.case = T))
})
loc1 <- which(pattern1 > 0) # anchor for loc
voter2[loc[loc1]] <- apply(voter2[loc[loc1]],2,function(x){
    x <- ifelse(x == "agree strongly", 2, x)
    x <- ifelse(x == "agree somewhat" | x == "agree", 1, x)
    x <- ifelse(x == "disagree somewhat" | x == "disagree", -1, x)
    x <- ifelse(x == "disagree strongly", -2, x)
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

voter2[c(40,41,43,186,187)] <-
    apply(voter2[c(40,41,43,186,187)],2,function(x){
        x[grep("better.*", x)] <- 1
        x[grep(".*same.*", x)] <- 0
        x[grep("worse.*", x)] <- -1
        x <- ifelse(x == "don't know", NA, x)
        x <- ifelse(x == "not sure", NA, x)
})
voter2[c(117,118,119)] <-
    apply(voter2[c(117,118,119)],2,function(x){
        x[grep("very.*", x)] <- 2
        x[grep("somewhat.*", x)] <- 1
        x[grep("not very.*", x)] <- -1
        x[grep("not.*at all.*", x)] <- -2
        x <- ifelse(x == "don't know", NA, x)
        x <- ifelse(x == "not sure", NA, x)
})
# col 153 race_fate_2016
x <- voter2[,153]
x <- ifelse(x == "a lot", 2, x)
x <- ifelse(x == "some", 1, x)
x[grep("not very.*", x)] <- -1
x <- ifelse(x == "none", -2, x)
x <- ifelse(x == "don't know", NA, x)
x <- ifelse(x == "not sure", NA, x)
x -> voter2[,153]
# col 275 polinterest_baseline
x <- voter2[,275]
x <- ifelse(x == "very much interested", 1, x)
x <- ifelse(x == "somewhat interested", 0, x)
x <- ifelse(x == "not much interested", -1, x)
x <- ifelse(x == "not sure", NA, x)
x -> voter2[,275]
             
# set new mark column, and fill NA with neutral
voter <- voter2
nm <- colnames(voter2)[c(loc[c(loc0, loc1)],
                         40,41,43,186,187,117,118,119,153,275)]
for (i in 1:59) {
    new_name <- paste0(nm[i], "_mark")
    voter2[[new_name]] <- ifelse(is.na(voter2[[nm[i]]]), 0, 1) # new mark column
    voter2[[nm[i]]] <- ifelse(is.na(voter2[[nm[i]]]), 0, voter2[[nm[i]]]) # fill NA with neutral value
}
