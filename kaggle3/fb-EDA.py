# -*- coding: utf-8 -*-
"""
Created on Fri Apr  2 13:19:16 2021

@author: denny
"""

import pandas as pd
import numpy as np
#%%
'讀資料&觀察'
data = pd.read_csv('D:/pseudo_facebook.csv', encoding='utf-8')#讀取NULL轉NA
data.head(5)
data['age'].describe()
#%%
'補值'
data.isna().sum()
data['gender']=data['gender'].fillna((data['gender'].mode())) #眾數
data['tenure']=data['tenure'].fillna((data['tenure'].mean())) #平均值
#%%
'特徵工程-相關係數'
import seaborn as sns 
df = data.iloc[:,6:15]
cor = df.corr()
sns.heatmap(cor) 

'年齡EDA'
sns.kdeplot(data['age'], shade=True) 
age=data[["age"]] #變data.frame
print(round(len(age[(age["age"]<=25)&(age["age"]>=18)])*100/len(age),2), "%")
age.plot(kind="hist")

'性別EDA'
gender=data[["gender"]]
print(len(gender[gender["gender"]=="male"])/len(gender))
print(len(gender[gender["gender"]=="female"])/len(gender))
labels="Male","Female"
sizes=[len(gender[gender["gender"]=="male"])/len(gender)*100,len(gender[gender["gender"]=="female"])/len(gender)*100]
explode=(0,0)
fig1, ax1 = plt.subplots(figsize=(8,8))
ax1.pie(sizes, explode=explode, labels=labels, autopct='%1.1f%%',
        shadow=True, startangle=90)

'互動性EDA'
gf=data[["likes","age","gender"]]
gf.loc[gf['age'] <= 20, 'age_group'] = '20歲以下' 
gf.loc[(gf['age']>20) & (gf['age']<=30), 'age_group'] = '21~30歲' 
gf.loc[(gf['age']>30) & (gf['age']<=40), 'age_group'] = '31~40歲' 
gf.loc[gf['age'] > 40, 'age_group'] = '41歲以上'
gf = gf.loc[gf['likes']>0]
pd.DataFrame(gf.groupby(["gender","age_group"])["likes"].mean())
