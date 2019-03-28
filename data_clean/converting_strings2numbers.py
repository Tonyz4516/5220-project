import pandas as pd
import re

Data2=pd.read_csv("step_2_voter.csv")

#We are first performing this code on 'ft_muslim_2016' as an example. 

#Step 1 - removing extra spaces and symbol "-" between numbers and text

for i in range(8000):
    if Data2['ft_muslim_2016'].isna()[i] == False and len(Data2['ft_muslim_2016'][i]) > 2 and Data2['ft_muslim_2016'][i] != "don't know":
        Data2.set_value(i,'ft_muslim_2016',Data2['ft_muslim_2016'][i].replace(" - ", ""))
        
#We have to do this again specifically for "25 -unfavorable feeling" because it's typed slightly differently than the others. It's typed as "25 -unfavorable feeling" instead of "50 - no feeling at all"; so one less space to the right of the symbol "-"
        
for i in range(8000):
    if Data2['ft_muslim_2016'][i] == "25 -unfavorable feeling":
        Data2.set_value(i,'ft_muslim_2016',"25unfavorablefeeling")
        
#Step 2 – removing text
        
for i in range(8000):
    if Data2['ft_muslim_2016'].isna()[i] == False and len(Data2['ft_muslim_2016'][i]) > 2 and Data2['ft_muslim_2016'][i] != "don't know":
        match = re.match(r"([0-9]+)([a-z]+)", Data2['ft_muslim_2016'][i])
        if match:
            Data2.set_value(i,'ft_muslim_2016',match.groups()[0])
            
#Step 3 – transforming strings of numbers into float
            
for i in range(8000):
    if Data2['ft_muslim_2016'].isna()[i] == False and Data2['ft_muslim_2016'][i] != "don't know":
        Data2.set_value(i,'ft_muslim_2016',float(Data2['ft_muslim_2016'][i]))
        
#Done!

#Now, repeat this for 'ft_black_2016', 'ft_asian_2016', 'ft_hisp_2016'...
