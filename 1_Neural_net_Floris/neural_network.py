## importing required packages
import pandas as pd
import numpy as np
from sklearn.neural_network import MLPClassifier
import matplotlib.pyplot as plt
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import RandomizedSearchCV
from matplotlib import cm
import seaborn

## reading data

Data=pd.read_csv('version_2.csv') # training after deleting variables that still contain text
Test_Set=pd.read_csv('test_set_version1.csv')

#deleting other columns for votes other than Trump; so our response variable will have 1 for Trump; 0 for others

def clean2(input_df):
    df = input_df.copy()
    del df['presvote16post_2016.did.not.vote.for.president']
    del df['presvote16post_2016.evan.mcmullin']
    del df['presvote16post_2016.gary.johnson']
    del df['presvote16post_2016.jill.stein']
    del df['presvote16post_2016.other']
    del df['presvote16post_2016.hillary.clinton']
   
    return df
  
cleaned2=clean2(Data)

# fill in NA values with mean values

def fill_na(input_df): 
    df=input_df.copy()
    df = df.fillna(df.mean())
    
    return df
  
Data4=fill_na(cleaned2)


# deleting useless variables

def clean5(input_df): 
    df = input_df.copy()
    del df['Unnamed: 0']
    del df['Unnamed: 0.1']
    del df['Unnamed: 0.1.1']
    del df['Unnamed: 0.1.1.1']
    del df['weight']
   
    return df
  
 Data_final=clean5(Data4)

# Now, finally we have the final version of training set, which is # Data_final

# Normalizing "feeling themometer" inputs

Data_final.iloc[:,34:49] *= 0.01 # "feeling thermometer" inputs in 2016
Data_final.iloc[:,120:129] *= 0.01 # "feeling thermometer" inputs in 2011
Data_final.iloc[:,145:146] *= 0.001 # normalizing this "birthyear" variable!!
Data_final.iloc[:,146:147] *= 0.1 # normalizing "hourscomputing" variable!!

#Now, it's ready to use!

# cleaning test set

def clean_test_set(input_df): #deleting other columns for votes other than Trump; so our response variable will have 1 for Trump; 0 for others
    df = input_df.copy()
    del df['presvote16post_2016.did.not.vote.for.president']
    del df['presvote16post_2016.evan.mcmullin']
    del df['presvote16post_2016.gary.johnson']
    del df['presvote16post_2016.jill.stein']
    del df['presvote16post_2016.other']
    del df['presvote16post_2016.hillary.clinton']
   
    
    return df

clean_test2=clean_test_set(Test_Set)

clean_test3=fill_na(clean_test2)

def clean5_test_set(input_df):
    df = input_df.copy()
    del df['Unnamed: 0']
    del df['Unnamed: 0.1']
    del df['Unnamed: 0.1.1']
    del df['weight']
   
    return df

FINAL_TEST=clean5_test_set(clean_test3)

# Normalizaing "feeling themometer" inputs

FINAL_TEST.iloc[:,34:49] *= 0.01 # "feeling thermometer" inputs in 2016
FINAL_TEST.iloc[:,120:129] *= 0.01 # "feeling thermometer" inputs in 2011
FINAL_TEST.iloc[:,145:146] *= 0.001 # normalizing this "birthyear" variable!!
FINAL_TEST.iloc[:,146:147] *= 0.1 # normalizing "hourscomputing" variable!!

#Now, it's ready to use!

def clean6(input_df):
    df = input_df.copy()
    del df['presvote16post_2016.donald.trump']
   
    return df

FINAL_TEST_without_Trump_variable=clean6(FINAL_TEST)
Data_final_without_Trump_variable=clean6(Data_final)

for i in range(len(Data_final['presvote16post_2016.donald.trump'])):
    if Data_final['presvote16post_2016.donald.trump'][i] != 0 and Data_final['presvote16post_2016.donald.trump'][i] != 1:
        Data_final.set_value(i,'presvote16post_2016.donald.trump',0)


for i in range(len(FINAL_TEST['presvote16post_2016.donald.trump'])):
    if FINAL_TEST['presvote16post_2016.donald.trump'][i] != 0 and FINAL_TEST['presvote16post_2016.donald.trump'][i] != 1:
        FINAL_TEST.set_value(i,'presvote16post_2016.donald.trump',0)
     
## modelling

Fit=MLPClassifier(activation='logistic',solver='sgd', alpha=0.1,hidden_layer_sizes=(50, 50, 50),max_iter=1000)

Fit.fit(Data_final_without_Trump_variable.iloc[:,0:len(list(Data_final_without_Trump_variable.columns))],Data_final['presvote16post_2016.donald.trump']) 

Predicted_on_test_set = Fit.predict(FINAL_TEST_without_Trump_variable.iloc[:,0:len(list(FINAL_TEST_without_Trump_variable.columns))])
print(max(Predicted_on_test_set))
print(min(Predicted_on_test_set))

misclassifications = 0
for i in range(len(Predicted_on_test_set)):
    if FINAL_TEST.iloc[i:i+1,263:264].values-Predicted_on_test_set[i] == 1 or FINAL_TEST.iloc[i:i+1,263:264].values-Predicted_on_test_set[i] == -1: 
        misclassifications += 1
print("number of misclassifications:", misclassifications)
print("percentage of misclassifications on test set is", misclassifications/len(Predicted_on_test_set))

predicted_probabilities=Fit.predict_proba(FINAL_TEST_without_Trump_variable.iloc[:,0:len(list(FINAL_TEST_without_Trump_variable.columns))])

TP=0
FP=0
FN=0
TN=0
for i in range(len(Predicted_on_test_set)):
    if FINAL_TEST.iloc[i:i+1,263:264].values == 1 and Predicted_on_test_set[i] == 1: 
        TP += 1
    elif FINAL_TEST.iloc[i:i+1,263:264].values == 0 and Predicted_on_test_set[i] == 1:
        FP += 1
    elif FINAL_TEST.iloc[i:i+1,263:264].values == 1 and Predicted_on_test_set[i] == 0:
        FN += 1
    else:
        TN += 1

print("True positives:", TP)
print("False positives:", FP)
print("False negatives:", FN)
print("True negatives:", TN)
print("Accuracy:", (TP+TN)/(TP+TN+FP+FN))
print("Sensitivity/recall:", (TP/(TP+FN)))
print("Precision:", TP/(TP+FP))


array = [[TP/1600,FP/1600],
         [FN/1600,TN/1600]]        
df_cm = pd.DataFrame(array, ("Predicted - Trump","Predicted - Others"),
                  ("Actual - Trump","Actual - Others"))
fig=plt.figure(figsize = (20,17))
sn.set(font_scale=5) #for label size
sn.heatmap(df_cm,annot=True,annot_kws={"size": 80},fmt='1g') # font size
fig.savefig('confusion_matrix_run_1.jpg') # confusion matrix

Predicted_on_train_set = Fit.predict(Data_final_without_Trump_variable.iloc[:,0:len(list(Data_final.columns))]) 
print(max(Predicted_on_train_set))
print(min(Predicted_on_train_set))

misclassifications = 0
for i in range(len(Predicted_on_train_set)):
    if Data_final.iloc[i:i+1,263:264].values-Predicted_on_train_set[i] == 1 or Data_final.iloc[i:i+1,263:264].values-Predicted_on_train_set[i] == -1: 
        misclassifications += 1
print("number of misclassifications:", misclassifications)
print("percentage of misclassifications on training set is", misclassifications/len(Predicted_on_train_set))

#removing highly relevant political opinionated variables

def clean7(input_df):
    df=input_df.copy()
    del df['fav_trump_2016']
    del df['Sanders_Trump_2016.bernie.sanders..democratic.']
    del df['Sanders_Trump_2016.don.t.know']
    del df['Sanders_Trump_2016.donald.trump..republican.']
    #del df['Clinton_Cruz_2016.don.t.know']
    #del df['Clinton_Cruz_2016.hillary.clinton..democratic.']
    #del df['Clinton_Cruz_2016.ted.cruz..republican.']
    #del df['Clinton_Rubio_2016.don.t.know']
    #del df['Clinton_Rubio_2016.hillary.clinton..democratic.']
    #del df['Clinton_Rubio_2016.marco.rubio..republican.']
    del df['fav_hrc_2016']
    
    return df

FINAL_TEST_without_Trump_variable_and_deleting_Trump_Clinton_fav=clean7(FINAL_TEST_without_Trump_variable)
Data_final_without_Trump_variable_and_deleting_Trump_Clinton_fav=clean7(Data_final_without_Trump_variable)

Fit=MLPClassifier(activation='logistic',solver='sgd', alpha=0.1,hidden_layer_sizes=(50, 50, 50),max_iter=1500)
Fit.fit(Data_final_without_Trump_variable_and_deleting_Trump_Clinton_fav.iloc[:,0:len(list(Data_final_without_Trump_variable_and_deleting_Trump_Clinton_fav.columns))],Data_final['presvote16post_2016.donald.trump'])

Predicted_on_test_set = Fit.predict(FINAL_TEST_without_Trump_variable_and_deleting_Trump_Clinton_fav.iloc[:,0:len(list(FINAL_TEST_without_Trump_variable_and_deleting_Trump_Clinton_fav.columns))])
print(max(Predicted_on_test_set))
print(min(Predicted_on_test_set))

misclassifications = 0
for i in range(len(Predicted_on_test_set)):
    if FINAL_TEST.iloc[i:i+1,263:264].values-Predicted_on_test_set[i] == 1 or FINAL_TEST.iloc[i:i+1,263:264].values-Predicted_on_test_set[i] == -1: 
        misclassifications += 1
print("number of misclassifications:", misclassifications)
print("percentage of misclassifications on test set is", misclassifications/len(Predicted_on_test_set))

TP_deleting_Trump_Clinton_fav=0
FP_deleting_Trump_Clinton_fav=0
FN_deleting_Trump_Clinton_fav=0
TN_deleting_Trump_Clinton_fav=0
for i in range(len(Predicted_on_test_set)):
    if FINAL_TEST.iloc[i:i+1,263:264].values == 1 and Predicted_on_test_set[i] == 1: 
        TP_deleting_Trump_Clinton_fav += 1
    elif FINAL_TEST.iloc[i:i+1,263:264].values == 0 and Predicted_on_test_set[i] == 1:
        FP_deleting_Trump_Clinton_fav += 1
    elif FINAL_TEST.iloc[i:i+1,263:264].values == 1 and Predicted_on_test_set[i] == 0:
        FN_deleting_Trump_Clinton_fav += 1
    else:
        TN_deleting_Trump_Clinton_fav += 1

print("True positives:", TP_deleting_Trump_Clinton_fav)
print("False positives:", FP_deleting_Trump_Clinton_fav)
print("False negatives:", FN_deleting_Trump_Clinton_fav)
print("True negatives:", TN_deleting_Trump_Clinton_fav)
print("Accuracy:", (TP_deleting_Trump_Clinton_fav+TN_deleting_Trump_Clinton_fav)/(TP_deleting_Trump_Clinton_fav+TN_deleting_Trump_Clinton_fav+FP_deleting_Trump_Clinton_fav+FN_deleting_Trump_Clinton_fav))
print("Sensitivity:", (TP_deleting_Trump_Clinton_fav/(TP_deleting_Trump_Clinton_fav+FN_deleting_Trump_Clinton_fav)))

array = [[TP_deleting_Trump_Clinton_fav/1600,FP_deleting_Trump_Clinton_fav/1600],
         [FN_deleting_Trump_Clinton_fav/1600,TN_deleting_Trump_Clinton_fav/1600]]        
df_cm = pd.DataFrame(array, ("Predicted - Trump","Predicted - Others"),
                  ("Actual - Trump","Actual - Others"))
fig=plt.figure(figsize = (20,17))
sn.set(font_scale=5) #for label size
sn.heatmap(df_cm,annot=True,annot_kws={"size": 80},fmt='1g') # font size
fig.savefig('confusion_matrix_run_2.jpg')

predicted_probabilities_deleting_Trump_Clinton_fav=Fit.predict_proba(FINAL_TEST_without_Trump_variable_and_deleting_Trump_Clinton_fav.iloc[:,0:len(list(FINAL_TEST_without_Trump_variable_and_deleting_Trump_Clinton_fav.columns))])

x = predicted_probabilities[:,1:2]

cm = plt.cm.get_cmap("seismic")
fig=plt.figure(figsize=(20,10))
ax = fig.add_subplot(1,1,1)
_, bins, patches = ax.hist(x,color="r")
bin_centers = 0.5*(bins[:-1]+bins[1:])
col = bin_centers - min(bin_centers)
col /= max(col)

for c, p in zip(col, patches):
    plt.setp(p, "facecolor", cm(c))
    
plt.yticks(fontsize =27)
plt.xticks(fontsize =25)
plt.xlabel('Class1 - Trump', fontsize=30)
plt.ylabel('Frequency', fontsize=30)
plt.show()
fig.savefig('class1-Trump.jpg')
