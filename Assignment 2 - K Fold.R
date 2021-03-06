# STEP - 1 START #

install.packages("titanic")
install.packages("rpart.plot")
install.packages("randomForest")
install.packages("DAAG")
library(titanic)
library(rpart.plot)
library(gmodels)
library(Hmisc)
library(pROC)
library(ResourceSelection)
library(car)
library(caret)
library(dplyr)
library(InformationValue)
library(rpart)
library(randomForest)
library("DAAG")

cat("\014") # Clearing the screen

getwd()
setwd("C:/08072017/AMMA 2017/Data/Assignment_2_Monica") #This working directory is the folder where all the bank data is stored

titanic_train_2<-read.csv('train.csv')
titanic_train<-titanic_train_2
titanic_train_3 <- read.csv('train.csv')

#titanic test
titanic_test_const <-read.csv('test-3.csv')

#splitting titanic train into 70,30
set.seed(1234) # for reproducibility
titanic_train$rand <- runif(nrow(titanic_train))
titanic_train_start <- titanic_train[titanic_train$rand <= 0.7,]
titanic_test_start <- titanic_train[titanic_train$rand > 0.7,]


# number of survived vs number of dead
CrossTable(titanic_train$Survived)

# removing NA row entries
#titanic_train <- titanic_train_start
titanic_train <- titanic_train[!apply(titanic_train[,c("Pclass", "Sex", "SibSp", "Parch", "Fare", "Age")], 1, anyNA),]
titanic_train_NA_allcols <- titanic_train_2[!apply(titanic_train_2[,c("Pclass", "Sex", "SibSp", "Parch", "Fare", "Age")], 1, anyNA),]
nrow(titanic_train_2)

# replacing NA by mean
mean_age = mean(titanic_train_2$Age)
titanic_train_mean_monica <- titanic_train_start
titanic_train_mean_monica2 <- titanic_train_start
titanic_train_mean_monica$Age[is.na(titanic_train_mean_monica$Age)] = mean(titanic_train_mean_monica$Age, na.rm = TRUE)
titanic_train_mean_monica2$Age[is.na(titanic_train_mean_monica2$Age)] = mean(titanic_train_mean_monica2$Age, na.rm = TRUE)

# STEP - 1 END #

# STEP - 2 START #

########## Build model from mean imputed into the data set ##########

full.model.titanic.mean <- glm(formula = Survived ~ Pclass + Sex + SibSp + Parch + Fare + Age,
                               data=titanic_train_mean_monica, family = binomial) #family = binomial implies that the type of regression is logistic

#lm
fit.train.mean <- lm(formula = Survived ~ Pclass + Sex + SibSp + Parch + Fare + Age,
                     data=titanic_train_mean_monica2) #family = binomial implies that the type of regression is logistic
summary(fit.train.mean)

#vif - remove those variables which have high vif >5
vif(fit.train.mean) 

#removing insignificant variables
titanic_train_mean_monica$Parch<-NULL
full.model.titanic.mean <- glm(formula = Survived ~ Pclass + Sex + SibSp + Fare + Age,
                               data=titanic_train_mean_monica, family = binomial) #family = binomial implies that the type of regression is logistic
summary(full.model.titanic.mean)

titanic_train_mean_monica$Fare<-NULL
full.model.titanic.mean <- glm(formula = Survived ~ Pclass + Sex + SibSp + Age,
                               data=titanic_train_mean_monica, family = binomial) #family = binomial implies that the type of regression is logistic
summary(full.model.titanic.mean)


#Testing performance on Train set

titanic_train_mean_monica$prob = predict(full.model.titanic.mean, type=c("response"))
titanic_train_mean_monica$Survived.pred = ifelse(titanic_train_mean_monica$prob>=.5,'pred_yes','pred_no')
table(titanic_train_mean_monica$Survived.pred,titanic_train_mean_monica$Survived)

#Testing performance on test set
nrow(titanic_test)
nrow(titanic_test2_mean_monica)
titanic_test2_mean_monica <- titanic_test_start

#imputation by replacing NAs by means in the test set
titanic_test2_mean_monica$Age[is.na(titanic_test2_mean_monica$Age)] = mean(titanic_test2_mean_monica$Age, na.rm = TRUE)

titanic_test2_mean_monica$prob = predict(full.model.titanic.mean, newdata=titanic_test2_mean_monica, type=c("response"))
titanic_test2_mean_monica$Survived.pred = ifelse(titanic_test2_mean_monica$prob>=.5,'pred_yes','pred_no')
table(titanic_test2_mean_monica$Survived.pred,titanic_test2_mean_monica$Survived)

########## END - Model with mean included instead of NA #########

# STEP - 2 END #

# STEP - 3 START #

### Testing for Jack n Rose's survival ###
df.jackrose <- read.csv('Book1.csv')
df.jackrose$prob = predict(full.model.titanic.mean, newdata=df.jackrose, type=c("response"))
df.jackrose$Survived.pred = ifelse(df.jackrose$prob>=.5,'pred_yes','pred_no')
head(df.jackrose)

# Jack dies, Rose survives

### END - Testing on Jack n Rose ###

# STEP - 3 END #

# STEP - 4 START #

## START  K-fold cross validation ##

# Defining the K Fold CV function here
Kfold_func <- function(dataset,formula,family,k)
{
  object <- glm(formula=formula, data=dataset, family = family)
  CVbinary(object, nfolds= k, print.details=TRUE)
}

#Defining the function to calculate Mean Squared Error here
MeanSquareError_func <- function(dataset,formula)
{
  LM_Object <- lm(formula=formula, data=dataset)
  LM_Object_sum <-summary(LM_Object)
  MSE <- mean(LM_Object_sum$residuals^2)
  print("Mean squared error")
  print(MSE)
}

#Performing KFold CV on Training set by calling the KFOLD CV function here
Kfoldobj <- Kfold_func(titanic_train_mean_monica,Survived ~ Pclass + Sex + SibSp + Age,binomial,10)

#Calling the Mean Squared Error function on the training set here
MSE_Train <-MeanSquareError_func(titanic_train_mean_monica,Survived ~ Pclass + Sex + SibSp + Age)

#confusion matrix on training set
table(titanic_train_mean_monica$Survived,round(Kfoldobj$cvhat))
print("Estimate of Accuracy")
print(Kfoldobj$acc.cv)

#Performing KFold CV on test set by calling the KFOLD CV function here
Kfoldobj.test <- Kfold_func(titanic_test2_mean_monica,Survived ~ Pclass + Sex + SibSp + Age,binomial,10)

#Calling the Mean Squared Error function on the test set here
MSE_Test <-MeanSquareError_func(titanic_test2_mean_monica,Survived ~ Pclass + Sex + SibSp + Age)

#Confusion matrix on test set
table(titanic_test2_mean_monica$Survived,round(Kfoldobj.test$cvhat))
print("Estimate of Accuracy")
print(Kfoldobj.test$acc.cv)

## END K-FOLD CROSS VALIDATION ##

# STEP - 4 END #
