#This script is a requirement for the Getting and Cleaning Data Course Project
#This R script was written by Peter Van Laarhoven, petriedish@gmail.com
#The script was written and tested in RStudio Version 1.0.143 using R version 3.4.1 in Windows 10

library(dplyr)
library(RCurl)
library(tidyr)

#Data downloaded from:
dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	#This script will work in R for Windows and may behave differently in other environments.
	download.file(dataUrl, "ucidataset.zip", mode = "wb", method = "libcurl")
		unzip("ucidataset.zip")
			#Changing directory to the folder containing the unzipped data set.
			setwd("./UCI HAR Dataset")

#Each file from the "test" dataset will be loaded separately and combined into a single object.
subject_test <- read.csv("./test/subject_test.txt", header = FALSE)
x_test <- read.csv("./test/X_test.txt", sep = "", header = FALSE)
y_test <- read.csv("./test/Y_test.txt", sep = "", header = FALSE)
test <- cbind(subject_test, y_test, x_test)

#Each file from the "train" dataset will be loaded separately and combined into a single object.
subject_train <- read.csv("./train/subject_train.txt", header = FALSE)
x_train <- read.csv("./train/X_train.txt", sep = "", header = FALSE)
y_train <- read.csv("./train/Y_train.txt", sep = "", header = FALSE)
train <- cbind(subject_train, y_train, x_train)

#The "test" and "train" objects will be combined into a single object.
raw_data <- rbind(train, test)
#The column headers will be changed to remove duplicate header names to make downstream naming operations easier.
names(raw_data) <- paste("V", 1:ncol(raw_data), sep="")
#The data frame is converted to a format used by dplyr
raw_data <- tbl_df(raw_data)

#The variable labels are stored in the "features.text" file in a messy form that will be replaced after the number of variables has been reduced in future steps.
#There are commas in the variable names and one variable per line so an unused separator may be substituted for the separator.
variables1 <- read.csv("features.txt", sep = "?", header = FALSE) 
#The first two variables are not in the variables file and must be added manually
variables2 <- matrix(c("subject", "test"), nrow = 2, ncol = 1) 
variables1 <- rbind(variables2, variables1)
#The file contains leading numbers that will be removed in this step
variables1 <- gsub("^[0-9]{1,3} ", "", variables1$V1)
#The "variables" object will be used to add the initial column headers to the "raw_data" object
names(raw_data) <- variables1

#The "test" variable is in coded form and will be given descriptive activity names from the file "activity_labels.txt".  A pipeline is used to simplify the code.  
raw_data$test <- gsub("1", "walking", raw_data$test) %>% gsub("2", "walking_upstairs", .) %>% gsub("3", "walking_downstairs", .) %>% gsub("4", "sitting", .) %>% gsub("5", "standing", .) %>% gsub("6", "laying", .)
#Some of the variables that are not used in this analysis have identical names and will be removed to enable pattern matching to work in the next step
raw_data <- raw_data[ , !duplicated(colnames(raw_data))] 
#The data will be arranged first by subject, then by test. 
ordered_data <- arrange(raw_data, subject, test)


#The first two columns are selected manually then the variables that contain "mean(" or "std(" will be selected using regular expression matching 
tidy_data <- select(ordered_data, subject, test, matches("mean\\(|std\\(")) 

#The messy and confusing variable names will be replaced with descriptive names using the "gsub" command.  These descriptions were decoded from the "features_info.txt" and "README.txt" files included in the data set. 
names1 <- names(tidy_data)
names1 <- gsub("tBodyAcc-", "linear_body_acceleration_", names1) %>% gsub("tGravityAcc-", "linear_acceleration_due_to_gravity_", .) %>% gsub("tBodyAccJerk-", "linear_body_acceleration_jerk_", .) %>% gsub("tBodyGyro-", "angular_body_velocity_", .) %>% gsub("tBodyGyroJerk-", "angular_body_velocity_jerk_", .) %>% gsub("tBodyAccMag-", "magnitude_of_linear_body_acceleration_", .) %>% gsub("tGravityAccMag-", "magnitude_of_linear_acceleration_due_to_gravity_", .) %>% gsub("tBodyAccJerkMag-", "magnitude_of_linear_body_acceleration_jerk_", .) %>% gsub("tBodyGyroMag-", "magnitude_of_angular_body_velocity_", .) %>% gsub("tBodyGyroJerkMag-", "magnitude_of_angular_body_velocity_jerk_", .) %>% gsub("fBodyAcc-", "fourier_transformed_linear_body_acceleration_", .) 
names1 <- gsub("fBodyAccJerk-", "fourier_transformed_linear_body_acceleration_jerk_", names1) %>% gsub("fBodyGyro-", "fourier_transformed_angular_body_velocity_", .) %>% gsub("fBodyAccMag-", "fourier_transformed_magnitude_of_linear_body_acceleration_", .) %>% gsub("fBodyBodyAccJerkMag-", "fourier_transformed_magnitude_of_linear_body_acceleration_jerk_", .) %>% gsub("fBodyBodyGyroMag-", "fourier_transformed_magnitude_of_angular_body_velocity_", .) %>% gsub("fBodyBodyGyroJerkMag-", "fourier_transformed_magnitude_of_angular_body_velocity_jerk_", .) %>% gsub("mean\\(\\)-", "mean_", .) %>% gsub("std\\(\\)-", "standard_deviation_", .) %>% gsub("mean\\(\\)$", "mean", .) %>% gsub("std\\(\\)$", "standard_deviation", .) %>% gsub("X", "on_the_x_axis", .) %>% gsub("Y", "on_the_y_axis", .) %>% gsub("Z", "on_the_z_axis", .) 

#The "names1" object will be used to replace the messy variable names with the descriptive versions for each column of data.
names(tidy_data) <- names1


#The "tidy_data" object contains all of the elements up to step 4 of the assignment.  This object will be used to create the averages dataset to satisfy step 5.
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#The tidy data set will be grouped by subject and activity for analysis 
by_subject_test <- group_by(tidy_data, subject, test)
tidy_means <- summarize_all(by_subject_test, funs(mean))
write.table(tidy_means, "./tidy_means.txt", sep = " ")











