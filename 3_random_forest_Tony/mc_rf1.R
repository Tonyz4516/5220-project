trControl <- trainControl(method = "cv",	
                          number = 5,	
                          search = "grid",	
                          verboseIter = TRUE)

# start = Sys.time()
# set.seed(12345)
# tuneGrid <- expand.grid(.mtry = c(seq(10,120,10)))	
# rf_mtry <- train(presvote16post_2016~.,
#     data = voter_train,
#     method = "rf",	
#     metric = "Accuracy",	
#     tuneGrid = tuneGrid,	
#     trControl = trControl,	
#     importance = TRUE,	
#     nodesize = 14,	
#     ntree = 300)	
# # measure time of train
# print(Sys.time() - start)	
# 
# print(rf_mtry)	
# 	
# 	
# search for the best maxnode
	
start = Sys.time()	
store_maxnode <- list()	
tuneGrid <- expand.grid(.mtry = 110) # best mtry

testmaxnode <- function(maxnode) {	
    set.seed(1234)	
    rf_maxnode <- train(presvote16post_2016~.,	
        data = voter_train,	
        method = "rf",	
        metric = "Accuracy",	
        tuneGrid = tuneGrid,	
        trControl = trControl,	
        importance = TRUE,	
        nodesize = 14,	
        maxnodes = maxnodes,	
        ntree = 300)	
    current_iteration <- toString(maxnodes)	
    store_maxnode[[current_iteration]] <- rf_maxnode	
}

results_mtry <- resamples(store_maxnode)

sink("mcrm_results.txt")
print(Sys.time() - start)	

summary(results_mtry)
sink()
# # 	
# # 	
# # search for best ntree	
# # 	
# # 	
# start = Sys.time()	
# store_maxtrees <- list()	
# for (ntree in c(250, 300, 350, 400, 450, 500, 550, 600, 800, 1000, 2000)) {	
#     set.seed(5678)	
#     rf_maxtrees <- train(presvote16post_2016~.,	
#         data = voter_train,	
#         method = "rf",	
#         metric = "Accuracy",	
#         tuneGrid = tuneGrid,	
#         trControl = trControl,	
#         importance = TRUE,	
#         nodesize = 14,	
#         maxnodes = 15,	
#         ntree = ntree)	
#     key <- toString(ntree)	
#     store_maxtrees[[key]] <- rf_maxtrees	
# }	
# results_tree <- resamples(store_maxtrees)	
# print(Sys.time() - start)	
# # 	
# # 	
# # 	
# summary(results_tree)	
# # 	
# # 	
# # ### fit with best parameter	
# # 	
# # 	
# fit_rf <- train(presvote16post_2016~.,	
#                 data = voter_train,	
#                 method = "rf",	
#                 metric = "Accuracy",	
#                 tuneGrid = tuneGrid,	
#                 trControl = trControl,	
#                 importance = TRUE,	
#                 nodesize = 14,	
#                 ntree = 800,	
#                 maxnodes = 24)	
# # 	
# # 	
# # ### Evaluate the model	
# # 	
# # 	
# prediction <-predict(fit_rf, voter_test)	
# confusionMatrix(prediction, voter_test$presvote16post_2016)	
# # 	
# # 	
# # variable importance	
# # 	
# # 	
# varImp(fit_rf)	
# # 	
# # 	
# # ## problems and fix	
# # 	
# # The model has good fit, however, the most important variables determined by the model are "Do you have favorable or unfavorable opinions regarding Trump?" It make sense why the it is the most important variable, but it is not helpful for us to understand links between people's political opinion and their votes.	
# # 	
# # Thus, we decided to drop all variables directly involving ask do you favor Trump or Clinton, and refit the model.	
# # 	
# # 	
# vars_involve_choose <- c("pp_repprim16_2016",	
#                          "pp_demprim16_2016",	
#                          "fav_trump_2016",	
#                          "fav_hrc_2016",	
#                          "Sanders_Trump_2016",	
#                          "Clinton_Cruz_2016",	
#                          "Sanders_Rubio_2016",	
#                          "Clinton_Rubio_2016")	
# col <- which(colnames(voter_train) %in% vars_involve_choose)	
# voter_train1 <- voter_train[,-col]	
# voter_test1 <- voter_test[,-col]	
# # 	
# # 	
# # re-train	
# # 	
# # 	
# start = Sys.time()	
# fit_rf1 <- train(presvote16post_2016~.,	
#                 data = voter_train1,	
#                 method = "rf",	
#                 metric = "Accuracy",	
#                 tuneGrid = tuneGrid,	
#                 trControl = trControl,	
#                 importance = TRUE,	
#                 nodesize = 14,	
#                 ntree = 800,	
#                 maxnodes = 24)	
# print(Sys.time() - start)	
# # 	
# # 	
# # 	
# prediction <- predict(fit_rf1, voter_test1)	
# confusionMatrix(prediction, voter_test1$presvote16post_2016)	
# # 	
# # 	
# # 	
# varImp(fit_rf1)
