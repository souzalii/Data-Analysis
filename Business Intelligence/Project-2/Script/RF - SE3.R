######

### script for team ass random forest.

# Clear environment
rm(list = ls()) 
# Clear plots
dev.off()  # But only if there IS a plot

# Clear console
cat("\014")  # ctrl+L

getwd()


## Install pacman ("package manager") if needed
if (!require("pacman")) install.packages("pacman")

## load packages (including pacman) with pacman
pacman::p_load(pacman, tidyverse, rpart, rpart.plot, caret, psych, mlbench, ranger, vip)


################################################################
#Data preparation

bmw<- read.csv("Data/bmw.csv")

glimpse(bmw)
###################
# Create factors for transmission, fueltype, and model

bmw$transmission<-as.factor(bmw$transmission)
bmw$fuelType<-as.factor(bmw$fuelType)
bmw$model<-as.factor(bmw$model)

glimpse(bmw)

###########################################################################
# Summaries

#obtain descriptive statistics of munerical and factor types of data

bmw_num <- bmw %>% select_if(is.numeric)
bmw_fac <- bmw %>% select_if(is.factor)
#descriptive statistics of numerical data
describe(bmw_num)
#descriptive statistics of factor data (count, basically)
bmw_fac %>% select(1) %>% table() %>% sort() %>% addmargins()
bmw_fac %>% select(2) %>% table() %>% sort() %>% addmargins()
bmw_fac %>% select(3) %>% table() %>% sort() %>% addmargins()

#COULD HAVE MORE PIVOT TABLE SHOWN HERE BY GROUP_BY() OR AGGREGATE()

################################################################################
### Model
##data selection
bmw3 <- bmw %>% filter(model == " 3 Series")

normalise_func <- function(x) { (x - min(x)) / (max(x) - min(x))}
bmw3 <- bmw3 %>% mutate(across(where(is.numeric),
                               normalise_func))



##Data partition bmw3 and bmw3(train-test :20-80)
#Random seeds
set.seed(23027571)
#random select dependent variable
training.samples <- bmw3$price %>%
  createDataPartition(p = 0.8, list = FALSE)
#Splite data based on random select dependent variable 
bmw3_train <- bmw3[training.samples, ]
bmw3_test <- bmw3[-training.samples, ]
#Remove random selected dependent variable
rm(training.samples)


###auto select mtry 5 times
modelrf1<-train(price ~ year + transmission + mileage + fuelType + tax + mpg + engineSize,
               data=bmw3_train,
               method="ranger",
               importance='impurity',
               tuneLength = 5) #tunelength = 1 means that we are fixing the number of attributes sqrt of total (mtry=3)


print(modelrf1)

plot(modelrf1) 
#from the graph, the best mtry = 6
###select minimum node size of leaf nodes
##repeated 10-fold cross-validation for resampling
fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 10)

##under the condition of best mtry, select minimum node size of leaf node
##from 5 to 30, 5 as step
rfGrid <-  expand.grid(mtry = 5,
                       splitrule="variance",
                       min.node.size = c(5,10,15,20,25,30))

nrow(rfGrid)

set.seed(23027571)
modelrf2 <- train(price ~ year + transmission + mileage + fuelType + tax + mpg + engineSize, 
                  data = bmw3_train, 
                  method = "ranger", 
                  importance='impurity',
                  trControl = fitControl, 
                  tuneGrid = rfGrid)

print(modelrf2)
plot(modelrf2)
#the small the minimum node size is, the better the model are. 
# the graph almost linear, so we set min.node.size as 1

##bulid final model

rfGrid <-  expand.grid(mtry = 6,
                       splitrule="variance",
                       min.node.size = 1)


modelRF <- train(price ~ year + transmission + mileage + fuelType + tax + mpg + engineSize, 
                  data = bmw3_train, 
                  method = "ranger", 
                  importance='impurity', 
                  tuneGrid = rfGrid)

print(modelRF)

#### Create a prediction 
# Generate predicted classes using the model object
predbmw3 <- predict(object = modelRF,  
                           newdata = bmw3_test)

#Calculate RMSE
postResample(pred = predbmw3, obs = bmw3_test$price)

#predict compare to actual
modelRF_pa <- cbind(as.data.frame(predbmw3), bmw3_test$price)
colnames(modelRF_pa) <- c("Predicted", "Actual")

plot(x = modelRF_pa$Predicted, y = modelRF_pa$Actual) + abline(0, 1)


###Importance of variable
v1 <- vip(modelRF)

grid.arrange(v1)

