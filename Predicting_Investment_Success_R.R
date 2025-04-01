library(ggplot2)
library(readxl)
library(rpart)
library(rpart.plot)
library(caret)
library(pROC)
library(dplyr)
library(corrplot)

#Import Data
investment<-na.omit(read.csv("investment_transactions.csv"))
# read in data
investment <- na.omit(read.csv("investment_transactions.csv"))


names(investment)


# Rename columns in investment dataframe
colnames(investment)[colnames(investment) == "horizon..days."] <- "horizon_days"
colnames(investment)[colnames(investment) == "expected_return..yearly."] <- "expected_return_yearly"
# Verify updated column names
names(investment)
investment$X<-NULL
str(investment)
names(investment)
investment$date_BUY_fix<-NULL       
investment$date_SELL_fix<-NULL

#investment<-investment[1:10000,]

names(investment)

# Basic summary statistics
summary(investment)

# Distribution of categorical variables
barplot(table(investment$sector))
barplot(table(investment$investment))
table(investment$company)

# Distribution of numerical variables
hist(investment$horizon_days, main = "Distribution of Horizon Days", xlab = "Horizon Days")
hist(investment$amount, main = "Distribution of Investment Amount", xlab = "Amount")
hist(investment$price_BUY, main = "Distribution of Buy Price", xlab = "Price")
hist(investment$price_SELL, main = "Distribution of Sell Price", xlab = "Price")
hist(investment$Volatility_Buy,main = "Distribution of Volatility (Buy)",xlab = "Volatility (Buy)")
hist(investment$Volatility_sell,main = "Distribution of Volatility (Sell)", xlab = "Volatility (Sell)")
hist(investment$Sharpe.Ratio, main = "Distribution of Sharpe Ratio",xlab = "Sharpe Ratio")
hist(investment$expected_return_yearly, main = "Distribution of Expected Yearly Return", xlab = "Expected Return")
hist(investment$inflation, main = "Distribution of Inflation", xlab = "Inflation")
hist(investment$nominal_return, main = "Distribution of Nominal Return", xlab = "Nominal Return")
hist(investment$ESG_ranking, main = "Distribution of ESG Ranking", xlab = "ESG Ranking")
hist(investment$PE_ratio, main = "Distribution of PE Ratio", xlab = "PE Ratio")
hist(investment$EPS_ratio, main = "Distribution of EPS Ratio", xlab = "EPS Ratio")
hist(investment$PS_ratio, main = "Distribution of PS Ratio", xlab = "PS Ratio")
hist(investment$PB_ratio, main = "Distribution of PB Ratio", xlab = "PB Ratio")
hist(investment$NetProfitMargin_ratio, main = "Distribution of Net Profit Margin Ratio", xlab = "Net Profit Margin Ratio")
hist(investment$current_ratio, main = "Distribution of Current Ratio", xlab = "Current Ratio")
hist(investment$roa_ratio, main = "Distribution of ROA Ratio", xlab = "ROA Ratio")
hist(investment$roe_ratio, main = "Distribution of ROE Ratio", xlab = "ROE Ratio")



#EDA - Exploratory Data Analysis

#Sectors and their investment (bad/Good) comparision

# Create a table of sector vs investment
sector_investment_table <- table(investment$sector, investment$investment)
# Define custom colors for different sectors
sector_colors <- c("red", "blue", "green", "orange","yellow")  # Specify colors as needed
# Create bar plot with custom colors
barplot(sector_investment_table, col = sector_colors, legend = FALSE)
legend("topright", legend = rownames(sector_investment_table), fill = sector_colors,
       x = "topright", y = NULL)


#Expected Yearly returns for each Sector 

# Create a barplot
ggplot(investment, aes(x = sector, y = expected_return_yearly, fill = sector)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Investment Sector vs Expected Yearly Return",
       x = "Investment Sector",
       y = "Expected Yearly Return") +
  scale_fill_discrete(name = "Sector") +
  theme_minimal()



# Create Scatterplot of Nominal Returns by Sector with different colors for different sectors
ggplot(investment, aes(x = nominal_return, y = sector, color = sector)) +
  geom_point() +
  labs(title = "Scatterplot of Nominal Returns by Sector",
       x = "Nominal Return",
       y = "Sector") +
  scale_color_discrete(name = "Sector")  # Add a legend for sector colors




# Create scatterplot
ggplot(investment, aes(x = expected_return_yearly, y = sector, color = sector)) +
  geom_point() +
  labs(title = "Scatterplot of expected_return_yearly by Sector",
       x = "Expected Yearly Return",
       y = "Sector") +
  scale_color_discrete(name = "Sector")


#Correlation Matrix
investment.eda<-investment
# Convert target variable to numeric representation (e.g., using label encoding)
investment.eda$investment <- as.numeric(as.factor(investment.eda$investment))

# Calculate correlation between numerical predictors and numeric target variable
correlation <- cor(investment.eda[, c("horizon_days", "amount", "price_BUY", "price_SELL", 
                                      "Volatility_Buy", "Volatility_sell", "Sharpe.Ratio",
                                      "expected_return_yearly", "inflation", "nominal_return",
                                      "PE_ratio", "EPS_ratio", "PS_ratio", "PB_ratio",
                                      "NetProfitMargin_ratio", "current_ratio",
                                      "roa_ratio", "roe_ratio")], investment.eda$investment)
correlation

# Convert correlation to dataframe
correlation <- data.frame(Variable = rownames(correlation), Correlation = correlation)

# Sort the dataframe by correlation values
correlation <- correlation[order(abs(correlation$Correlation), decreasing = TRUE), ]

# Create a bar plot of Investment vs all other variables 

ggplot(correlation, aes(x = Variable, y = Correlation)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Correlation of all the Variables against Investment",
       x = "Variable", y = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# Create correlation matrix

correlation_matrix <- cor(select(investment, horizon_days, amount, price_BUY, price_SELL,Volatility_Buy,Volatility_sell
                                 ,Sharpe.Ratio, expected_return_yearly,
                                 inflation, nominal_return, ESG_ranking, PE_ratio, EPS_ratio, PS_ratio,
                                 PB_ratio, NetProfitMargin_ratio, current_ratio, roa_ratio, roe_ratio))

# Plot correlation heat matrix
investment.corr <- investment[, !(names(investment) %in% c("company", "sector", "investment"))]
corrplot(correlation_matrix, method = "color", type = "upper", tl.col = "black", tl.srt = 75)



str(investment)
names(investment)




# Decision Trees, Logistic Regression and Linear Regression


# Create test and valid dataframes
unique(investment$company)
test <- investment[seq(1, nrow(investment), 2), ]
valid <- investment[seq(2, nrow(investment), 2), ]


#Decision Tree
decision_tree<-rpart(investment~.,data = test,method = "class")

# Create the decision tree plot
prp(decision_tree, extra = 1, varlen = 20)

#Predict function
predict.train<-predict(decision_tree,test,type = "class")
predict.validation<-predict(decision_tree,valid,type = "class")

# Accuracy check for training and validation using decision tree
confusionMatrix(predict.train,as.factor(test$investment))
confusionMatrix(predict.train,as.factor(valid$investment))
str(investment)

#Example usage of predict_investment function using Decision Tree
new_data1 <- data.frame(
  company = "BBY",
  sector = "RETAIL",
  horizon_days = 5,
  amount = 1500,
  price_BUY = 50.125,
  price_SELL = 48.975,
  Volatility_Buy = 0.421,
  Volatility_sell = 0.415,
  Sharpe.Ratio = 0.355,
  expected_return_yearly = 0.001,
  inflation = 2.1,
  nominal_return = -0.035,
  investment = 1,
  ESG_ranking = 10,
  PE_ratio = 15.2,
  EPS_ratio = 3.5,
  PS_ratio = 0.42,
  PB_ratio = 2.8,
  NetProfitMargin_ratio = 2.9,
  current_ratio = 1.6,
  roa_ratio = 10.5,
  roe_ratio = 18.3
)

predicted_investment <- predict(decision_tree, new_data1, type = "class")
print(predicted_investment)


# Create a max Decision tree using rpart
deeper_decision_tree <- rpart(investment ~ ., data = test, cp = 0, minsplit = 10, method = "class", maxdepth = 30)

#Predict for deeper decision tree
deeper.ct.train.predict<-predict(deeper_decision_tree,test,type = "class")
deeper.ct.valid.predict<-predict(deeper_decision_tree,valid,type = "class")

#Plot the tree
prp(deeper_decision_tree, extra = 1, varlen = 25)
names(investment)

#Accuracy for deeper decision tree
confusionMatrix(deeper.ct.train.predict,as.factor(test$investment))
confusionMatrix(deeper.ct.valid.predict,as.factor(valid$investment))

#Predict using the new data frame for deeper decision tree
new_data1 <- data.frame(
  company = "BBY",
  sector = "RETAIL",
  horizon_days = 5,
  amount = 1500,
  price_BUY = 50.125,
  price_SELL = 48.975,
  Volatility_Buy = 0.421,
  Volatility_sell = 0.415,
  Sharpe.Ratio = 0.355,
  expected_return_yearly = 0.001,
  inflation = 0.1,
  nominal_return = 1,
  investment = 1,
  ESG_ranking = 10,
  PE_ratio = 15.2,
  EPS_ratio = 3.5,
  PS_ratio = 0.42,
  PB_ratio = 2.8,
  NetProfitMargin_ratio = 2.9,
  current_ratio = 1.6,
  roa_ratio = 10.5,
  roe_ratio = 18.3
)

predicted_investment <- predict(deeper_decision_tree, new_data1, type = "class")
print(predicted_investment)


#Logistic Regression


#Create test and Validation dataframes 
test1<-test
valid1<-valid
test1$investment <- ifelse(test1$investment == "GOOD", 1, 0)
valid1$investment <- ifelse(valid1$investment == "GOOD", 1, 0)

#Create the logistic regression Model

logit.investment <- glm(investment ~ ., data = test1, family = "binomial")
summary(logit.investment)
#Predict functions
logit.predict.train <- predict(logit.investment,test1,type = "response")
logit.predict.validation <-predict(logit.investment,valid1,type = "response")


logit.predict.train <- as.factor(ifelse(logit.predict.train >= 0.5, 1, 0)) # Convert predicted values to binary factor
logit.predict.validation <- as.factor(ifelse(logit.predict.validation >= 0.5, 1, 0)) # Convert predicted values to binary factor

#Accuracy for the Logistic Regression Model
confusionMatrix(logit.predict.train, as.factor(test1$investment))
confusionMatrix(logit.predict.validation, as.factor(valid1$investment))

predicted_investment <- predict(logit.investment, new_data1)
predicted_investment <- ifelse(predicted_investment >= 0.5, "GOOD", "BAD")
print(predicted_investment)




#linear regression 

# Predict the expected yearly return

investment2<-investment
str(investment2)


# Find unique values for "sector", "company", and "investment"
unique_sector <- unique(investment2$sector)
unique_company <- unique(investment2$company)
unique_investment <- unique(investment2$investment)


unique_sector
unique_company
unique_investment

# Convert "sector", "company", and "investment" to factors
investment2$sector <- factor(investment2$sector)
investment2$company <- factor(investment2$company)
investment2$investment <- factor(investment2$investment)

# Convert factors to numerical values
investment2$sector <- as.numeric(investment2$sector)
investment2$company <- as.numeric(investment2$company)
investment2$investment <- as.numeric(investment2$investment)

investment2$sector
investment2$company
investment2$investment



#The above conversion will assign numerical values 
#to the categories based on their order in the factor levels.

#Create the model

expected_yearly_return<-lm(expected_return_yearly~.,data = investment2)
expected_yearly_return
investment2[1,]

# Create a new dataframe with values for prediction
new_data3 <- data.frame(company = 5,
                       sector = 4,
                       horizon_days = 2,
                       amount = 100,
                       price_BUY = 55.5518,
                       price_SELL = 53.48391,
                       Volatility_Buy = 0.3836656,
                       Volatility_sell = 0.385748,
                       Sharpe.Ratio = 0.3836656,
                       inflation = 1.96,
                       horizon_days = 3,
                       nominal_return = -0.03722454,
                       investment = 1,  # Assuming "BAD" as 1 and "GOOD" as 2 based on unique_investment values
                       ESG_ranking = 1,
                       PE_ratio = 12.58,
                       EPS_ratio = 3.73,
                       PS_ratio = 0.38,
                       PB_ratio = 3.19,
                       NetProfitMargin_ratio = 3.01,
                       current_ratio = 1.49,
                       roa_ratio = 8.69,
                       roe_ratio = 26.69)

# Get predicted value using the predict() function
predicted_value <- predict(expected_yearly_return, newdata = new_data3)

# Print the predicted value
print(predicted_value)













































































