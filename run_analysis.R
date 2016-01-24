#!/usr/bin/env Rscript

# run_analysis.R: [TODO description]

# load required libraries
library(data.table)
library(dplyr)

# download the dataset if it doesn't already exist
data.archive = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data.directory = "UCI HAR Dataset"
if (!file.exists(data.directory)) {
    download.file(data.archive, destfile="data.zip", method="curl")
    unzip("data.zip")
    unlink("data.zip")
}

#
# 1. Merge the training and the test sets to create one data set.
#
oldwd <- getwd()
setwd(data.directory)

# read the list of all feature labels.
feature.labels <- fread('features.txt')$V2
feature.names <- make.names(feature.labels, unique=TRUE)

# read a single dataset given a directory
read_dataset <- function(directory) {
    # the subject who performed the activity
    subject <- fread(paste0(directory, "/subject_", directory, ".txt"),
                     col.names=c("subject"))
    # the activity labels for each row
    activity <- fread(paste0(directory, "/y_", directory, ".txt"),
                      col.names=c("activity"))
    # the data
    X <- fread(paste0(directory, "/X_", directory, ".txt"),
               col.names=feature.names)
    # combine the three tables by column
    cbind(subject, activity, X)
}

# read the training and test datasets
d <- do.call("rbind", lapply(c("test", "train"), read_dataset))

# make it into a dplyr style table
d <- tbl_df(d)
# change the subject and activity to factors
d <- mutate(d, subject=factor(subject), activity=factor(activity))

#
# 2. Extract only the measurements on the mean and standard deviation
#    for each measurement.
#
d <- select(d, subject, activity, matches("mean|std", ignore.case=TRUE))

#
# 3. Use descriptive activity names to name the activities in the data set
#
# read the list of all activity labels
activity.labels <- fread('activity_labels.txt')
levels(d$activity) <- activity.labels$V2

#
# 4. Appropriately label the data set with descriptive variable names.
#
names(d)

# remove redundant 'Body'
names(d) <- gsub('BodyBody', 'Body', names(d))
# expand some names
names(d) <- gsub('Acc', '.accelerometer', names(d))
names(d) <- gsub('Gyro', '.gyroscope', names(d))
names(d) <- gsub('Freq', '.frequency', names(d))
names(d) <- gsub('Mean', '.mean', names(d))
names(d) <- gsub('Mag', '.magnitude', names(d))
names(d) <- gsub('tBody', 'time.body.', names(d))
names(d) <- gsub('fBody', 'frequency.body.', names(d))
names(d) <- gsub('tGravity', 'time.gravity', names(d))
names(d) <- gsub('Jerk', '.jerk.', names(d))
# remove duplicate and trailing '.'
names(d) <- gsub('\\.+', '.', names(d))
names(d) <- gsub('\\.$', '', names(d))

#names(d)

#
# 5. From the data set in step 4, create a second, independent tidy data set
#    with the average of each variable for each activity and each subject.
#
d.summary <- d %>% group_by(subject, activity) %>% summarise_each(funs(mean))

# go back to the original working directory and write the tidy data file
setwd(oldwd)
write.table(d.summary, file="dataset.csv", row.name=FALSE)

