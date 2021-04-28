library(forecast)#AUTO-ARIMA
library(tseries) #adf kpss test
library(dplyr)# mutate %>% 
data <- read.csv(file="D:\\Tesla.csv.CSV",header=TRUE,sep=",")
data$Date <- as.Date(data$Date, format="%m/%d/%Y")
data <- mutate(data,西元年=substr(Date,start=1,stop=4))
data <- mutate(data,月=substr(Date,start=6,stop=7))
data <- mutate(data,日=substr(Date,start=9,stop=10))
data <- mutate(data,新日期=paste(西元年,月,日,sep=""))
data$新日期 <- as.numeric(data$新日期)

歷史資料 <- subset(data,data$新日期>=20150000&data$新日期<=20170300)
#預測20170301~0317
對照組 <- subset(data,data$新日期>=20170301) 

時序格式 <- ts(歷史資料$Close, frequency=30)
拆解 <- decompose(時序格式) #type add(季節不隨時間增加) mult(隨時間增加)
plot(拆解)

#to 穩定
adf.test(時序格式)
lamda轉換 <- BoxCox(時序格式,lambda = "auto")
BoxCox.lambda(時序格式)
adf.test(lamda轉換)
差分 <- diff(時序格式, differences = 1)
#差分且轉換 <- diff(BoxCox(時序格式,lambda = "auto"),differences = 1)
adf.test(差分)  #< 穩定，我們有足夠的證據推翻不穩定的假設

#建模
auto.arima(時序格式,stepwise = F,d=1,trace = T,stationary = T,ic=c("aic")) #小好
fit <- arima(時序格式,order=c(2,1,0), include.mean = FALSE)


#檢視
tsdisplay(residuals(fit), lag.max=50, main='殘差大全')
shapiro.test(fit$residuals) #殘差>a 常態
Box.test(fit$residuals, lag=30, type="Ljung-Box") 
#p>a沒足夠證據說明1~30階殘差是非零自相關(相關係數!=0)>>1~24階獨立

#5.預測誤差與檢討空間
p<-forecast(fit,13,lambda = 1)
p
plot(p)
預測 <- as.data.frame(p)
評估 <- cbind(預測,對照組)
評估 <- 評估 %>% 
  mutate(mae=abs(Close-評估$`Point Forecast`)) %>% 
  mutate(mape=abs(Close-評估$`Point Forecast`)/評估$`Point Forecast`)
mean(評估$mape)
