vec <- rep(NA, ncol(voter))
for (i in 1:ncol(voter)){
    vec[i] <- sum(is.na(voter[,i])) / nrow(voter[,i])
}
hist(vec)

count <- 0
voter2 <- voter[,which(vec < 0.5)]
for (i in 1:nrow(voter)){
    if (sum(is.na(voter2[i,])) == 0) {count <- count +1}
}
count
