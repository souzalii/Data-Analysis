

##########scripts for ann

# Firstly, if we so desire, let us clean up our workspace.
rm(list = ls())
# package loading
if (!require("pacman")) install.packages("pacman")
pacman::p_load("dplyr", "caret", "nnet", "neuralnet", "NeuralNetTools", "MASS")

############data loading
bmw<- read.csv("Data/bmw.csv")
bmw <- na.omit(bmw)
glimpse(bmw)
###################
# Create factors for transmission, fueltype, and model

bmw$transmission<-as.factor(bmw$transmission)
bmw$fuelType<-as.factor(bmw$fuelType)
bmw$model<-as.factor(bmw$model)

################################################################################
### Model
##data selection
bmw1 <- bmw %>% filter(model == " X1")

bmw1$transmission<-as.numeric(bmw1$transmission)
bmw1$fuelType<-as.numeric(bmw1$fuelType)

# normalise[0, 1] using the code below.
normalise_func <- function(x) { (x - min(x)) / (max(x) - min(x))}
bmw1 <- bmw1 %>% mutate(across(where(is.numeric),
                               normalise_func))

glimpse(bmw1)

##Data partition bmw3 and bmw3(train-test :20-80)
#Random seeds
set.seed(23027571)
#random select dependent variable
training.samples <- bmw1$price %>%
  createDataPartition(p = 0.8, list = FALSE)
#Splite data based on random select dependent variable 
bmw1_train <- bmw1[training.samples, ]
bmw1_test <- bmw1[-training.samples, ]
#Remove random selected dependent variable
rm(training.samples)

# model using 'caret' and 'nnet' in default setting and turning
bmw1_net <- train(price ~ year + transmission + mileage + fuelType + tax + mpg + engineSize, bmw1_train, 
                     method = 'nnet', linout = TRUE, trace = FALSE)

#some information from our training
print(bmw1_net)

#predict over the test set
bmw1_pred <- predict(bmw1_net, bmw1_test)

#DataFrame showing a standard plot of predicted vs actual.
bmw1_pa <- cbind(as.data.frame(bmw1_pred), bmw1_test$price)
colnames(bmw1_pa) <- c("Predicted", "Actual")

#actual graph of the predictions (with a 45 degree line 
# that indicates prediction = actual).
plot(x = bmw1_pa$Predicted, y = bmw1_pa$Actual) + abline(0, 1)

#the actual plot of the neural network.
plotnet(bmw1_net)

##########################################################
#Hyperparameter tuning



# combiunation of candidates
train_grid <- expand.grid(size = c(1,3,5,7,9), decay = c(0, 1e-4, 1e-3, 1e-2, 1e-1))
nrow(train_grid)

##repeated 10-fold cross-validation for resampling
fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 10)


# the smallest root mean square error (RMSE).
bmw1_tune_net <- train(price ~ year + transmission + mileage + fuelType + tax + mpg + engineSize,
                       data = bmw1_train, 
                       method = 'nnet', 
                       linout = TRUE, 
                       trace = FALSE, 
                       tuneGrid = train_grid,
                       trControl = fitControl, )


print(bmw1_tune_net)
plotnet(bmw1_tune_net)
plot(bmw1_tune_net)


################################################################################
# #########final model
# from above graph, although 7 Neurons in hiden lyer may give the best (RMSE),
#the decrease rate in RSEM is reduced sharply, in order to avoid over-fit problem,
#we choose size = 5. Similar idea is applied to weight decay. and we choose decay = 1e-01
# The final values used for the model were size = 5 and decay = 1e-0.

fix_grid <- expand.grid(size = c(7), decay = c(1e-03))


fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 10)



bmw1_final_net <- train(price ~ year + transmission + mileage + fuelType + tax + mpg + engineSize,
                       data = bmw1_train, 
                       method = 'nnet', 
                       linout = TRUE, 
                       trace = FALSE, 
                       tuneGrid = fix_grid,
                       trControl = fitControl, )

print(bmw1_final_net)

bmw1_final_pred <- predict(bmw1_final_net, bmw1_test)

bmw1_final_pa <- cbind(as.data.frame(bmw1_final_pred), bmw1_test$price)
colnames(bmw1_final_pa) <- c("Predicted", "Actual")

plot(x = bmw1_final_pa$Predicted, y = bmw1_final_pa$Actual) + abline(0, 1)

plotnet(bmw1_final_net)

