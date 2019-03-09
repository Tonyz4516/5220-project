require(readr)
require(dplyr)
require(plotly)
require(tidyr)

# import data
file <- "sml_assignment/project/VOTER_Survey_December16_Release1.csv"
voter <- read_csv(file)
# col 15 is output variable: who did you voted for

# some summary analysis
sum1 <- voter %>%
    group_by(inputstate_2016, presvote16post_2016) %>%
    summarise(count = length(case_identifier)) %>%
    spread(presvote16post_2016, count)

sum1 <- sum1 %>%
    apply(2, function(x) ifelse(is.na(x), 0, x)) %>%
    as.data.frame

sum1[,-1] <- apply(sum1[,-1], 2, as.numeric)
    
sum2 <- sum1 %>%
    mutate(Others = `Evan McMullin` + `Gary Johnson` + 
               `Jill Stein` + Other) %>%
    select(inputstate_2016, `Donald Trump`, `Hillary Clinton`, Others) %>%
    mutate(total = `Donald Trump` + `Hillary Clinton` + Others)

# calculate proportion
for (i in 2:4) sum2[,i] <- sum2[,i]/sum2[,5]

p <- plot_ly(sum2, x = ~inputstate_2016, y = ~`Donald Trump`,
             type = 'bar', name = 'Donald Trump',
             marker = list(color = 'red')) %>%
    add_trace(y = ~`Hillary Clinton`, name = 'Hillary Clinton',
              marker = list(color = 'blue')) %>%
    add_trace(y = ~Others, name = 'Other',
              marker = list(color = 'green')) %>%
    layout(xaxis = list(title = "", tickangle = -45),
           yaxis = list(title = ""),
           margin = list(b = 100),
           barmode = 'stack')
