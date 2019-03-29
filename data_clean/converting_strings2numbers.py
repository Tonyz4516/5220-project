import pandas as pd
import re

Data2=pd.read_csv("step_2_voter.csv")

#We are performing this code on all the "feeling themometer" variables.

All_variables=[Data2['ft_black_2016'],Data2['ft_white_2016'],Data2['ft_hisp_2016'],Data2['ft_asian_2016'],Data2['ft_muslim_2016'],Data2['ft_jew_2016'],Data2['ft_christ_2016'],Data2['ft_fem_2016'],Data2['ft_immig_2016'],Data2['ft_blm_2016'],Data2['ft_wallst_2016'],Data2['ft_gays_2016'],Data2['ft_unions_2016'],Data2['ft_police_2016'],Data2['ft_altright_2016']]
Variables_names=['ft_black_2016','ft_white_2016','ft_hisp_2016','ft_asian_2016','ft_muslim_2016','ft_jew_2016','ft_christ_2016','ft_fem_2016','ft_immig_2016','ft_blm_2016','ft_wallst_2016','ft_gays_2016','ft_unions_2016','ft_police_2016','ft_altright_2016']

#Step 1 - removing extra spaces and symbol "-" between numbers and text

for j in range(15):
    for i in range(8000):
        if All_variables[j].isna()[i] == False and len(All_variables[j][i]) > 2 and All_variables[j][i] != "don't know":
            Data2.set_value(i,Variables_names[j],All_variables[j][i].replace(" - ", ""))
        
#We have to do this again specifically for "25 -unfavorable feeling" because it's typed slightly differently than the others. It's typed as "25 -unfavorable feeling" instead of "50 - no feeling at all"; so one less space to the right of the symbol "-"

    for i in range(8000):
        if All_variables[j][i] == "25 -unfavorable feeling":
            Data2.set_value(i,Variables_names[j],"25unfavorablefeeling")
        
#Step 2 – removing text

    for i in range(8000):
        if All_variables[j].isna()[i] == False and len(All_variables[j][i]) > 2 and All_variables[j][i] != "don't know":
            match = re.match(r"([0-9]+)([a-z]+)", All_variables[j][i])
            if match:
                Data2.set_value(i,Variables_names[j],match.groups()[0])
            
#Step 3 – transforming strings of numbers into float

    for i in range(8000):
        if All_variables[j].isna()[i] == False and All_variables[j][i] != "don't know":
            Data2.set_value(i,Variables_names[j],float(All_variables[j][i]))

#Done!
Data2.to_csv("step2_voter.csv", index=False)
