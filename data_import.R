setwd("~/Documents/iDigBio/PhotoImport")
ufdb <- read.csv(file="allUF.csv", stringsAsFactors=FALSE)
load("guidm.RData")
guidFull <- read.csv(file="occurrence.txt", row.names=NULL,
                     header=FALSE, nrows=535366, stringsAsFactors=FALSE)
guid <- guidFull[, c(1, 17)]
names(guid) <- c("idigbio-guid", "ufid")


checkPhotoFolder(path="dNORS/dNORS-photoInfo.csv")

checkPhotoInfoFile(file="dNORS/dNORS-photoInfo.csv")

toMatch <- read.csv(file="dNORS/dNORS-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="dNORS/dNORS-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)

matchGUID(toMatch, photoDB, ufDB, guid, file="dNORS-matched.csv")

