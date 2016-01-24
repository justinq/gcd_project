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
