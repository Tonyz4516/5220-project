# require library
require(readr)
require(dplyr)
require(plotly)
require(tidyr)

# import data
file <- "../../Downloads/voter_data/VOTER_Survey_December16_Release1.csv"
voter <- read_csv(file, na = c("", "NA", "__NA__"))

# read in drop list by Floris
rms <- readLines("../../Documents/GitHub/5220-project/data_clean/delete_variable_identified_by_floris.txt")
drop_var <- sub(".*del df\\['", "", rms)
drop_var <- sub("'\\].*", "", drop_var)
drop_col <- which(colnames(voter) %in% drop_var)

# function returns proportion of NA or don't know given a vector
pNAorDontKnow <- function(vec){
    na <- sum(is.na(vec))
    dontKnow <- sum(vec == "Don't know", na.rm = T)
    return((na + dontKnow) / length(vec))
}

# drop row with more than 25% NA plus Don't know
# row_w_25_NA <- which(apply(voter, 1, pNAorDontKnow) >= 0.25)
# voter1 <- voter[-row_w_25_NA,] # 475 row removed
voter1 <- voter

# drop col with more than 50% of NA plus "Don't know"
col_w_50_NA <- which(apply(voter, 2, pNAorDontKnow) >= 0.5)
drop <- unique(c(drop_col, col_w_50_NA))
voter2 <- voter1[,-drop]

# missing map

library(reshape2)
library(ggplot2)

ggplot_missing <- function(x){
    x %>% 
        is.na %>%
        melt %>%
        ggplot(data = .,
               aes(x = Var2,
                   y = Var1)) +
        geom_raster(aes(fill = value)) +
        scale_fill_grey(name = "",
                        labels = c("Present","Missing")) +
        theme_minimal() + 
        theme(axis.text.x  = element_text(angle=45, vjust=0.5)) + 
        labs(x = "Variables in Dataset",
             y = "Rows / observations")
}

ggplot_missing(voter2)
