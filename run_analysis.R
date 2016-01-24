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

