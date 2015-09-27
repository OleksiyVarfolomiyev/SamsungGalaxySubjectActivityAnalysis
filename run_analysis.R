# Author Alex (Oleksiy) Varfolomiyev

# setwd to the source file dir
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# Read Data

#if(!exists("feat")) {
  
  feat = read.table('./features.txt', header = F, stringsAsFactors=F) 

  actType = read.table('./activity_labels.txt', header = F, stringsAsFactors=F) 

  trainSubj = read.table('./train/subject_train.txt', header = F, dec=".", stringsAsFactors=F)
  trainX = read.table('./train/x_train.txt', header = F, dec=".", stringsAsFactors=F)
  trainY = read.table('./train/y_train.txt', header = F, dec=".", stringsAsFactors=F)
  
  testSubj = read.table('./test/subject_test.txt', header = F, dec=".", stringsAsFactors=F)
  testX = read.table('./test/x_test.txt', header = F, dec=".", stringsAsFactors=F)
  testY = read.table('./test/y_test.txt', header = F, dec=".", stringsAsFactors=F)

# combine train and test data and name the columns
trainDat = cbind(trainY, trainSubj, trainX)
colnames(trainDat) <- c("actID", "subjID", as.character(feat$V2))

testDat = cbind(testY, testSubj, testX);
colnames(testDat) <- c( "actID", "subjID", as.character(feat$V2))

colnames(actType) <- c( "actID", "activity")

## 1. Merge the training and the test sets to create one data set
dat <- rbind(trainDat, testDat)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
featDesired <- grepl( "mean|std", colnames(dat) ) | grepl( "subjID", colnames(dat) ) | grepl( "actID", colnames(dat) )
datDesired <- dat[ , featDesired]

## 3. Uses descriptive activity names to name the activities in the data set
data <- merge( actType, datDesired, by = 'actID', all.y = T)
#}
## 4. Appropriately labels the data set with descriptive variable names. 
names(data) <- gsub("\\(", "", names(data))
names(data) <- gsub("\\)", "", names(data))
names(data) <- gsub("-", "", names(data))
names(data) <- gsub("mean", "Mean", names(data), ignore.case = F)
names(data) <- gsub("std", "Std", names(data), ignore.case = F)
names(data) <- gsub("Acc", "Accelerator", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "freq", names(data))
names(data) <- gsub("bodybody", "Body", names(data), ignore.case = T)


## 5. Create a second, independent tidy data set with the average of each variable
#    for each activity and each subject
library(plyr)

dataAverages = ddply(data, .(subjID, activity),  numcolwise(mean))

write.table(dataAverages, "tidy_data_averages.txt", row.name = FALSE)

