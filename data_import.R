setwd("~/Documents/iDigBio/PhotoImport")
source("~/Documents/iDigBio/idigbio-ingestion-data-preparation/data_functions.R")
ufdb <- read.csv(file="allUF.csv", stringsAsFactors=FALSE)
load("guidm.RData")
guidFull <- read.csv(file="occurrence.txt", row.names=NULL,
                     header=FALSE, nrows=535366, stringsAsFactors=FALSE)
guid <- guidFull[, c(1, 17)]
names(guid) <- c("idigbio-guid", "ufid")

### ------ for dNORS (Northern Red Sea)

###    *********  Not yet finished *********
###    missing iDigBio GUID for these specimens
checkPhotoFolder(path="~/Photos/tmp/dNORS_2013_1s")
checkPhotoInfoFile(file="dNORS/dNORS-photoInfo.csv")

toMatch <- read.csv(file="dNORS/dNORS-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="dNORS/dNORS-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)

matchGUID(toMatch, photoDB, ufDB, guid, file="dNORS-matched.csv")

### ------ for dSTM (St Martin)

extensionToUpper("~/Photos/tmp/dSTM")
changeSeparator("~/Photos/tmp/dSTM")
checkPhotoFolder(path="~/Photos/tmp/dSTM/")

checkPhotoInfoFile(file="dSTM/dSTM-photoInfo.csv")

toMatch <- read.csv(file="dSTM/dSTM-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="dSTM/dSTM-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)

matchGUID(toMatch, photoDB, ufDB, guid, file="dSTM-matched.csv")

### ------ for dMOO12 (Moorea 2012)

extensionToUpper("~/Photos/tmp/dMOO12")
changeSeparator("~/Photos/tmp/dMOO12")
checkPhotoFolder(path="~/Photos/tmp/dMOO12")

checkPhotoInfoFile(file="dMOO12/dMOO12-photoInfo.csv")

toMatch <- read.csv(file="dMOO12/dMOO12-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="dMOO12/dMOO12-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- subset(photoDB, subset=photo_quality == "1")

matchGUID(toMatch, photoDB, ufDB, guid, file="dMOO12-matched.csv")

### ----- for dMOO10 (Moorea 2010)

extensionToUpper("~/Photos/tmp/dMOO10")
checkPhotoFolder(path="~/Photos/tmp/dMOO10")

checkPhotoInfoFile(file="dMOO10/dMOO10-photoInfo.csv")

toMatch <- read.csv(file="dMOO10/dMOO10-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="dMOO10/dMOO10-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- subset(photoDB, subset= photo_quality == "1")

matchGUID(toMatch, photoDB, ufDB, guid, file="dMOO10-matched.csv")
