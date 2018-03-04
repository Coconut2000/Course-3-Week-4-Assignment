# Download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Unzip and read the data
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Labels the data set with descriptive variable names.
# Creates a second, independent tidy data set with 
# Calculates the average of each variable for each activity and each subject.

library(dplyr)
# Download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
# Unzip the data
unzip(zipfile="./data/Dataset.zip",exdir="./data")
# read train data
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
Subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# read test data
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
Subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# read data description
variable_names <- read.table("./data/UCI HAR Dataset/features.txt")

# read activity labels
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

# Merges the training and the test sets to create one data set.
X_total <- rbind(X_train, X_test)
Y_total <- rbind(Y_train, Y_test)
Subject_total <- rbind(Subject_train, Subject_test)

# Extracts only the measurements on the mean and standard deviation for each measurement.
selected_var <- variable_names[grep("mean\\(\\)|std\\(\\)",variable_names[,2]),]
X_total <- X_total[,selected_var[,1]]

# Uses descriptive activity names to name the activities in the data set
colnames(Y_total) <- "activity"
Y_total$activitylabel <- factor(Y_total$activity, labels = as.character(activity_labels[,2]))
activitylabel <- Y_total[,-1]

# Labels the data set with descriptive variable names.
colnames(X_total) <- variable_names[selected_var[,1],2]
names(X_total)<-gsub("^t", "time", names(X_total))
names(X_total)<-gsub("^f", "frequency", names(X_total))
names(X_total)<-gsub("Acc", "Accelerometer", names(X_total))
names(X_total)<-gsub("Gyro", "Gyroscope", names(X_total))
names(X_total)<-gsub("Mag", "Magnitude", names(X_total))
names(X_total)<-gsub("BodyBody", "Body", names(X_total))

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
colnames(Subject_total) <- "subject"

total <- cbind(X_total, activitylabel, Subject_total)
levels(total$activitylabel) <- tolower(levels(total$activitylabel))
tidy_data <- total %>% group_by(activitylabel, subject) %>% summarize_all(funs(mean))
write.table(tidy_data, file = "tidydata.txt", row.names = FALSE, col.names = TRUE)

 