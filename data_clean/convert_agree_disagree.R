# convert agree / disagree cols to numeric
# source("data_clean.R")
voter2

# find keywords likely involving ordinal data
keywords <- c("Agree", "Strongly", "Very", "Somewhat",
              "Much", "more", "less", "same", "better", "worse") 

find_them <- function(vec) {
    l <- grep(paste(keywords, collapse=" | "), 
                 vec, ignore.case = T)
    result <- levels(factor(vec[l]))
    if(length(result) != 0) return(result)
}
re <- unique(unlist(apply(voter2, 2, find_them)))

# manual check them and select
