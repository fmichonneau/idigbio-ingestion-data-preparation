setwd("~/Documents/iDigBio/PhotoImport")
source("~/Documents/iDigBio/idigbio-ingestion-data-preparation/data_functions.R")
ufdb <- read.csv(file="allUF.csv", stringsAsFactors=FALSE)
load("guidm.RData")

nlines <- unlist(strsplit(system("wc -l occurrence.txt", intern=TRUE), "\\s"))[1]
guidFull <- read.csv(file="occurrence.txt", row.names=NULL,
                     header=TRUE, nrows=as.numeric(nlines), stringsAsFactors=FALSE)
guid <- guidFull[, c("id", "dwc.catalogNumber")]
names(guid) <- c("idigbio-guid", "ufid")

## library(RMySQL)
## con <- dbConnect(MySQL(), user="root", password="root",
##                  host="localhost", client.flag=CLIENT_MULTI_RESULTS,
##                  dbname="UFDB_iDigBio")
## guidQuery<- paste("SELECT `idigbio:uuid`,`dwc:catalogNumber`",
##                   "FROM occurrence",
##                   "WHERE `dwc:catalogNumber` REGEXP '.{1,}';")
## guid <- dbGetQuery(con, statement=guidQuery)





### ------ for dNORS (Northern Red Sea)

checkPhotoFolder(path="~/Photos/tmp/dNORS_2013_1s")
checkPhotoInfoFile(file="dNORS/dNORS-photoInfo.csv")

toMatch <- read.csv(file="dNORS/dNORS-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="dNORS/dNORS-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)

matchGUID(toMatch, photoDB, ufDB, guid, file="dNORS-matched.csv")

### ------ for dSTM (St Martin)

### Uploaded successfully on 2014-05-27

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

### ------ for dMOO08 (Moorea 2009)

extensionToUpper("~/Photos/tmp/dMOO08")
changeSeparator("~/Photos/tmp/dMOO08")
checkPhotoFolder("~/Photos/tmp/dMOO08")

### ------ for NIN09 (redo)

checkPhotoFolder(path="~/Photos/1")

checkPhotoInfoFile("Ningaloo/dNIN09-photoInfo.csv")

toMatch <- read.csv(file="Ningaloo/dNIN09-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="Ningaloo/dNIN09-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
matchGUID(toMatch, photoDB, ufdb, guid, file="dNIN09-matched.csv")


### ------ for dMOO06 (Moorea 2006)
### ------ done on 2015-03-24

extensionToUpper("~/hdd/tmp-images-for-iDigBio/Moorea_2006_select/JPGS/")
changeSeparator("~/hdd/tmp-images-for-iDigBio/Moorea_2006_select/JPGS/")
checkPhotoFolder("~/hdd/tmp-images-for-iDigBio/Moorea_2006_select/JPGS/")

toMatch <- read.csv(file = "dMOO06/dMOO06-toBeMatched.csv",
                    stringsAsFactors =  FALSE, check.names = FALSE)
photoDB <- read.csv(file = "dMOO06/dMOO06-photoInfo.csv",
                    stringsAsFactors = FALSE, check.names = FALSE)
matchGUID(toMatch, photoDB, ufdb, guid, file = "dMOO06/dMOO06-matched.csv")

### ------ for FHL
### ------ done on 2015-03-24
### note this combines FHL2007 2009 and 2011

extensionToUpper("~/hdd/tmp-images-for-iDigBio/FHL")
changeSeparator("~/hdd/tmp-images-for-iDigBio/FHL")
checkPhotoFolder("~/hdd/tmp-images-for-iDigBio/FHL")

toMatch <- read.csv(file = "FHL/dFHL-toBeMatched.csv", stringsAsFactors = FALSE,
                    check.names = FALSE)
photoDB <- read.csv(file = "FHL/dFHL-photoInfo.csv",  stringsAsFactors = FALSE,
                    check.names = FALSE)
matchGUID(toMatch,  photoDB,  ufdb,  guid, file = "FHL/dFHL-matched.csv")

### ------ for GUOK
### ------ done on 2015-08-26
### reimport to figure out mismatches
### only 1 difference, sent email to Alex to see what is the best way of fixing it

toMatch <- read.csv(file = "GUOK/dGUOK10-selected_20150206.csv", stringsAsFactors = FALSE,
                    check.names = FALSE)
photoDB <- read.csv(file = "GUOK/dGUOK10-photoInfo_20150206.csv", stringsAsFactors = FALSE,
                    check.names = FALSE)
matchGUID(toMatch, photoDB, ufdb, guid, file = "GUOK/dGUOK10-matched_20150826.csv")
