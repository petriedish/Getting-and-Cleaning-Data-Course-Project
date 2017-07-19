This is an explanation of the script submitted for the Getting and Cleaning Data Course Project
This project was authored by Peter Van Laarhoven, petriedish@gmail.com
The script was written and tested in RStudio Version 1.0.143 using R version 3.4.1 in Windows 10

1. The three library dependencies were loaded: dplyr, RCurl, and tidyr.

2. The dataset was downloaded from: "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" and unzipped.

3. The directory was moved up one level to the "UCI HAR Dataset" folder.

4. Each file from the "test" dataset was loaded separately and combined into a single object using cbind.
This was done for the "train" dataset as well. 

5. The "test" and "train" objects were combined into a single "raw_data" object with rbind.

6. The column headers were changed to remove duplicate header names to make downstream naming operations easier.

7. The data frame was converted to a format used by dplyr using tbl_df.

8. The variable labels that are stored in the "features.text" file in a messy form were loaded into the object "variables1".

9. The leading numbers in "variables1" were removed using gsub and regular expression matching.  

10. The "subject" and "test" labels were appended to the beginnning of "variables1".

11. The "variables" object was used to add the initial column headers to the "raw_data" object.

12. The "test" variable was initially in coded form and was given descriptive activity names from the file "activity_labels.txt" using gsub.  A pipeline was used to simplify the code.  

13. Some of the variables that will not be used in this analysis have identical names and were removed using !duplicated to enable pattern matching to work in a later step.

14. A new object, "ordered_data" was created by using dplyr::arrange on "raw_data", arrangement was performed first by the column "subject", then by "test".

15. A new object, "tidy_data" was created dplyr::select.  The first two columns were selected manually, then any variables that contain "mean(" or "std(" were selected using regular expression matching. 

16.  To replace the messy and confusing variable names in "tidy_data", a new object was created by assigning the names() attribute from "tidy_data" to a new object, "names1".   The gsub command was used to replace the non-descriptive header names with descriptive names using regular expression matching.  These descriptions were decoded from the "features_info.txt" and "README.txt" files included in the data set. 

17.  The "names1" object was assigned to the headers of "tidy_data".  The "tidy_data" object contains all of the elements up to step 4 of the assignment as described here:

	"You should create one R script called run_analysis.R that does the following.
		1. Merges the training and the test sets to create one data set.
		2. Extracts only the measurements on the mean and standard deviation for each measurement.
		3. Uses descriptive activity names to name the activities in the data set
		4. Appropriately labels the data set with descriptive variable names."

  The data is tidy because each column contains a different observation, and each row contains the data from a single time-point.

  
		"5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject."
		
18. This step was accomplished by using tidyr::group_by to group the "tidy_data" object by both subject and activity.

19.  Summarize_all was used to compute the mean of each data group in "tidy_means" and the result was assigned to object "tidy_means"

20.  "tidy_means" was written to a text file named "tidy_means.txt" using the write_table function.

21.  The file may be read in R by using the command: tidy_means <- read.table("tidy_means.txt") followed by: view(tidy_means)
