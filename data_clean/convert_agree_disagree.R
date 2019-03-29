# convert agree / disagree cols to numeric
# source("data_clean.R")
require(parallel)
require(readr)
require(dplyr)
require(plotly)
require(tidyr)
require(openxlsx)

# all character to lower case letter
voter2 <- as.data.frame(apply(voter2,2,function(x) return(tolower(x))),
                        stringsAsFactors = F)

# import manually identified ordinal colnames
variables <- read.xlsx("variable_identification.xlsx")
ordinal_colnames <-
    variables$X1[which(grepl(3, variables$category) +
                           grepl("ordinal", variables$category) >0)]

# find keywords likely involving ordinal data
keywords <- c("agree", "strongly", "very", "somewhat",
              "much", "more", "less", "same", "better", "worse")

ordinal <- rep(0, ncol(voter2))
for (i in 1:ncol(voter2)) {
    u_vec <- unique(voter2[,i])
    for (word in keywords) {
        l <- grep(word, u_vec)
        if (length(l) > 0) break
    }
    # all variables matching keywords above will be 1 in ordinal
    ordinal[i] <- if_else(length(l) > 0, 1, 0)
}

# manual check them and select
loc <- which(ordinal == 1)
ordinal_col_from_keywords <- colnames(voter2)[loc]
# list0 <- lapply(loc, function(i, data) {unique(data[,i])}, data = voter2)

loc_finder <- function(pattern, data = voter2) {
    patterns <- apply(data, 2, function(x){
        sum(grepl(pattern, unique(x), ignore.case = T))
    })
    return(which(patterns > 0))
}

# pattern0 for all with very important
# which covers majority of the ordinal data
loc0 <- loc_finder("very important")
voter2[loc0] <- apply(voter2[loc0],2,function(x){
    x <- ifelse(x == "extremely important", 3, x)
    x <- ifelse(x == "very important", 2, x)
    x <- ifelse(x == "somewhat important" | x == "fairly important" |
                    x == "moderately important",
                1, x)
    x <- ifelse(x == "not very important" |
                    x == "not too important" |
                    x == "a little important", -1, x)
    x <- ifelse(x == "unimportant" | x == "not important at all" |
                    x == "not at all important", -2, x)
    x <- ifelse(x == "don't know", NA, x)
})

# pattern1 for all with "strongly something"
loc1 <- loc_finder("strongly [[:lower:]]*")
voter2[loc1] <- apply(voter2[loc1],2,function(x){
    x[grep("strongly dis[[:lower:]]*", x)] <- -2
    x[grep("somewhat dis[[:lower:]]*", x)] <- -1
    x[grep("^dis[[:lower:]]*", x)] <- -1
    x[grep("strongly [[:lower:]]*", x)] <- 2
    x[grep("somewhat [[:lower:]]*", x)] <- 1
    x[grep("^ag[[:lower:]]*", x)] <- 1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc2 <- loc_finder("agree strongly")
voter2[loc2] <- apply(voter2[loc2],2,function(x){
    x <- ifelse(x == "agree strongly", 2, x)
    x <- ifelse(x == "agree somewhat" | x == "agree", 1, x)
    x <- ifelse(x == "disagree somewhat" | x == "disagree", -1, x)
    x <- ifelse(x == "disagree strongly", -2, x)
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc3 <- loc_finder("unfavorable")
voter2[loc3] <- apply(voter2[loc3],2,function(x){
    x[grep("very un[[:lower:]]*", x)] <- -2
    x[grep("somewhat un[[:lower:]]*", x)] <- -1
    x[grep("very f[[:lower:]]*", x)] <- 2
    x[grep("somewhat f[[:lower:]]*", x)] <- 1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc4 <- loc_finder("confident")
voter2[loc4] <- apply(voter2[loc4],2,function(x){
    x[grep("not at all [[:lower:]]*", x)] <- -2
    x[grep("not too [[:lower:]]*", x)] <- -1
    x[grep("very [[:lower:]]*", x)] <- 2
    x[grep("somewhat [[:lower:]]*", x)] <- 1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc5 <- loc_finder("better off")
voter2[loc5] <- apply(voter2[loc5],2,function(x){
    x[grep("worse off", x)] <- -1
    x[grep("same", x)] <- 0
    x[grep("better off", x)] <- 1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc6 <- loc_finder("^about the same$")
voter2[loc6] <- apply(voter2[loc6],2,function(x){
    x[grep("much less", x)] <- -2
    x[grep("somewhat less", x)] <- -1
    x[grep("much more", x)] <- 2
    x[grep("somewhat more", x)] <- 1
    x[grep("about the same", x)] <- 0
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc7 <- loc_finder("^not very proud$")
voter2[loc7] <- apply(voter2[loc7],2,function(x){
    x[grep("not proud at all", x)] <- -2
    x[grep("not very proud", x)] <- -1
    x[grep("very proud", x)] <- 2
    x[grep("somewhat proud", x)] <- 1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc8 <- loc_finder("seldom")
voter2[loc8] <- apply(voter2[loc8],2,function(x){
    x[grep("more than once a week", x)] <- 5
    x[grep("once a week", x)] <- 4
    x[grep("once or twice a month", x)] <- 3
    x[grep("a few times a year", x)] <- 2
    x[grep("seldom", x)] <- 1
    x[grep("never", x)] <- 0
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc9 <- loc_finder("not very much")
voter2[loc9] <- apply(voter2[loc9],2,function(x){
    x[grep("a lot", x)] <- 2
    x[grep("some", x)] <- 1
    x[grep("not very much", x)] <- -1
    x[grep("none", x)] <- -2
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc10 <- loc_finder("better than r's")
voter2[loc10] <- apply(voter2[loc10],2,function(x){
    x[grep("better than r's", x)] <- 1
    x[grep("about the same as r's", x)] <- 0
    x[grep("worse than r's", x)] <- -1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc11 <- loc_finder("should be more evenly distributed")
voter2[loc11] <- apply(voter2[loc11],2,function(x){
    x[grep("should be more evenly distributed", x)] <- 1
    x[grep("distribution is fair", x)] <- 0
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc12 <- loc_finder("holding steady")
voter2[loc12] <- apply(voter2[loc12],2,function(x){
    x[grep("generally becoming more widespread and accepted", x)] <- 1
    x[grep("holding steady", x)] <- 0
    x[grep("generally becoming rarer and less accepted", x)] <- -1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc13 <- loc_finder("as respected as in the past")
voter2[loc13] <- apply(voter2[loc13],2,function(x){
    x[grep("more respected", x)] <- 1
    x[grep("as respected as in the past", x)] <- 0
    x[grep("less respected", x)] <- -1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc14 <- loc_finder("slightly easier")
voter2[loc14] <- apply(voter2[loc14],2,function(x){
    x[grep("much easier", x)] <- 2
    x[grep("slightly easier", x)] <- 1
    x[grep("no change", x)] <- 0
    x[grep("slightly harder", x)] <- -1
    x[grep("much harder", x)] <- -2
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc15 <- loc_finder("kept the same")
voter2[loc15] <- apply(voter2[loc15],2,function(x){
    x[grep("expanded", x)] <- 1
    x[grep("kept the same", x)] <- 0
    x[grep("repealed", x)] <- -1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc16 <- loc_finder("about the right amount")
voter2[loc16] <- apply(voter2[loc16],2,function(x){
    x[grep("too much", x)] <- 1
    x[grep("about the right amount", x)] <- 0
    x[grep("too little", x)] <- -1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc17 <- loc_finder("men and women have equal opportunities")
voter2[loc17] <- apply(voter2[loc17],2,function(x){
    x[grep("women have more opportunities than men", x)] <- 1
    x[grep("men and women have equal opportunities", x)] <- 0
    x[grep("men have more opportunities than women", x)] <- -1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

loc18 <- loc_finder("treat both groups the same")
voter2[loc18] <- apply(voter2[loc18],2,function(x){
    x[grep("favor blacks over whites", x)] <- 1
    x[grep("treat both groups the same", x)] <- 0
    x[grep("favor whites over blacks", x)] <- -1
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
})

# now compare with the manual list
filtered <- c(loc0,loc1,loc2,loc3,loc4,loc5,loc6,loc7,loc8,loc9,
             loc10,loc11,loc12,loc13,loc14,loc15,
             loc16,loc17,loc18)

additional_ordinal <- which(colnames(voter2) %in% ordinal_colnames)
additional_ordinal <- additional_ordinal[!additional_ordinal %in% filtered]

loc19 <- additional_ordinal
voter2[loc19] <- apply(voter2[loc19],2,function(x){
    x <- ifelse(x == "don't know", NA, x)
    x <- ifelse(x == "not sure", NA, x)
    
    x[grep("just about always", x)] <- 2
    x[grep("most of the time", x)] <- 1
    x[grep("some of the time", x)] <- 0
    
    x[grep("mostly make a contribution", x)] <- 1
    x[grep("neither", x)] <- 0
    x[grep("mostly a drain", x)] <- -1
    
    x[grep("^legal in all cases$", x)] <- 1
    x[grep("legal/illegal in some cases", x)] <- 0
    x[grep("illegal in all cases", x)] <- -1
    
    x[grep("too often", x)] <- 1
    x[grep("about right", x)] <- 0
    x[grep("not often enough", x)] <- -1
    
    x[grep("definitely is not happening", x)] <- -2
    x[grep("probably is not happening", x)] <- -1
    x[grep("probably is happening", x)] <- 1
    x[grep("definitely is happening", x)] <- 2
    
    x[grep("very liberal", x)] <- 2
    x[grep("moderate", x)] <- 0
    x[grep("very conservative", x)] <- -2
    x[grep("liberal", x)] <- 1
    x[grep("conservative", x)] <- -1
    
    x[grep("^very .*", x)] <- 2
    x[grep("somewhat .*", x)] <- 1
    x[grep("not .*", x)] <- 0
    
    x[grep("a lot", x)] <- 3
    x[grep("some", x)] <- 2
    x[grep("a little", x)] <- 1
    x[grep("nothing", x)] <- 0
    
    x[grep("like a lot", x)] <- 1
    x[grep("like somewhat", x)] <- 0
    x[grep("dislike", x)] <- -1
    
    x[grep("more than 6 hours per day", x)] <- 3
    x[grep("3-6 hours per day", x)] <- 2
    x[grep("1-2 hours per day", x)] <- 1
    x[grep("less than one hour per day", x)] <- 0
})

write.csv(voter2, "step1_voter.csv")
