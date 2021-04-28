library(dplyr)
library(data.table) #fread dcast 
library(arules) #關聯分析包
library(arulesViz) 
##格式整理####
data <- fread(file="D:\\relation.csv",header=TRUE)
name <- fread(file="D:\\node.csv",header=TRUE,encoding="UTF-8")
data$Source <- as.numeric(data$Source)
data$Target <- as.numeric(data$Target)
name$Id <- as.numeric(name$Id)
names(name)[names(name)=="Id"]="Source"
data <- left_join(data,name,by="Source")
names(name)[names(name)=="Source"]="Target"
data <- left_join(data,name,by="Target")
data$Label.x[is.na(data$Label.x)] <- ""
data$Label.y[is.na(data$Label.y)] <- ""
關聯格式 <- data[-c(1),c(3:4)] %>% 
            subset(Label.y!=""&Label.x!="")# 少1萬

trans <- as(關聯格式, "transactions")

##挖規則####
rule1 <- apriori(trans,parameter = list(support = 0.001,confidence = 0.6,
                                       minlen=1,maxlen=3))
# support = 兩邊品項同時出現在單筆帳單數/總帳單數
# confidence = 買左邊品項下，購買右邊品項的機率
# lift = 向購買左邊品項的人推薦右邊品項/向所有人推薦右邊品項
summary(rule1)
outcome <- data.frame(lhs = labels(lhs(rule1)),rhs = labels(rhs(rule1)),rule1@quality)

#加指標(卡方 & coverage)
加指標 <- data.frame(interestMeasure(rule1, measure = c("coverage", "chiSquared"), significance=T, data))
# coverage = 左邊品項占比
# 卡方 <0.05 拒絕 r^2=0
結論 <- cbind(outcome,加指標)
colnames(結論) <- c("LHS", "RHS","support","confidence","lift","count","coverage","Chi-square") 

##寫成網址####
library(htmlwidgets)
p=inspectDT(rule1, width="100%") #網頁版面配置
saveWidget(p,"D:\\weibo_rules.html", selfcontained = TRUE, libdir = NULL,
           background = "white")

