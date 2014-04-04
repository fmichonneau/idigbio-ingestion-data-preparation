setwd("~/Documents/iDigBio/PhotoImport")
ufdb <- read.csv(file="allUF.csv", stringsAsFactors=FALSE)

## guid <- read.table(file="occurrence.txt", row.names=NULL, skip=0, sep="\t", quote="",
##                    comment.char="", stringsAsFactors=FALSE, nrows=533080, colClasses="character")
## colnames(guid) <- guid[1, ]
## guid <- guid[-1, ]
## save(guid, file="guid.RData")

## load("guid.RData")
## ufdb$catalogNumber <- paste(ufdb$UFID, ufdb$PhylumID, sep="-")
## guidm <- merge(guid, ufdb[, c("PreviousNumber", "catalogNumber")], by="catalogNumber")
## save(guidm, file="guidm.RData")

load("guidm.RData")

guidFull <- read.csv(file="occurrence.txt", row.names=NULL,
                     header=FALSE, nrows=535366, stringsAsFactors=FALSE)
guid <- guidFull[, c(1, 17)]
names(guid) <- c("idigbio-guid", "ufid")

test <- read.csv(file="dNIN09-import.csv", stringsAsFactors=FALSE,
                 check.names=FALSE)
photoDB <- read.csv(file="~/Documents/Impatiens/matchPictures/dNIN09.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)

matchGUID <- function(toMatch, photoDB, ufDB, guid, file="dNIN09-matched.csv") {
    ## get the photo number
    getPhotoNb <- function(x) {
        fNm <- unlist(strsplit(x, "/"))
        fNm <- fNm[length(fNm)]
        fNm <- gsub("\\.[a-zA-Z]{3,}$", "", fNm)
        fNm
    }
    photoNm <- sapply(toMatch$"idigbio:OriginalFileName", getPhotoNb)
    tmpFieldNb <- photoDB[match(photoNm, photoDB$"Photo number"), "previous_number"]
    tmpUFID <- ufDB[match(tmpFieldNb, ufDB$PreviousNumber), c("UFID", "PhylumID")]
    tmpUFID <- paste(tmpUFID$UFID, tmpUFID$PhylumID, sep="-")
    tmpGUID <- guid[match(tmpUFID, guid$ufid), "idigbio-guid"]
    tmpRes <- cbind(toMatch, "idigbio:SpecimenRecordUUID"=tmpGUID)
    if (any(is.na(tmpRes$"idigbio:SpecimenRecordUUID"))) {
        nNA <- sum(is.na(tmpRes$"idigbio:SpecimenRecordUUID"))
        warning(nNA, " record(s) did not match: ",
                cat(tmpFieldNb[is.na(tmpRes$"idigbio:SpecimenRecordUUID")]))
        tmpRes <- tmpRes[!is.na(tmpRes$"idigbio:SpecimenRecordUUID"), ]
    }    
    write.csv(tmpRes, row.names=FALSE, file=file)
    TRUE
}

matchGUID(test, photoDB, ufdb, guid, file="dNIN09-matched.csv")
setwd("~/Documents/iDigBio")
ufdb <- read.csv(file="PhotoImport/allUF.csv", stringsAsFactors=FALSE)
load("guidm.RData")
guidFull <- read.csv(file="PhotoImport/occurrence.txt", row.names=NULL,
                     header=FALSE, nrows=535366, stringsAsFactors=FALSE)
guid <- guidFull[, c(1, 17)]
names(guid) <- c("idigbio-guid", "ufid")

checkPhotoInfoFile <- function(file) {
    ## correct file name
    noPath <- gsub(".+/(.+)$", "\\1", file)
    fnm <- unlist(strsplit(noPath, "-"))
    stopifnot(length(fnm) == 2)
    prefix <- fnm[1]
    message("Photo prefix for this dataset is: ", prefix)
    stopifnot(fnm[2] == "photoInfo.csv")

    ## check headers
    photoInfo <- read.csv(file=file, stringsAsFactors=FALSE)
    stopifnot(all(c("photo_number", "photo_quality", "phylum") %in% names(photoInfo)))
    stopifnot(any(c("previous_number", "UFID") %in% names(photoInfo)))

    ## check photo file names
    photoName <- strsplit(photoInfo$photo_number, "-")
    prefixes <- sapply(photoName, function(x) x[1])
    uniqPref <- unique(prefixes)
    message("There is ", length(uniqPref), " prefix (problem if not 1)")
    stopifnot(length(uniqPref) == 1)
    message("The photo prefix is ", uniqPref, ". Problem if not: ", prefix)
    stopifnot(uniqPref == prefix)
    numbers <- sapply(photoName, function(x) x[2])
    lNums <- grep("\\b[0-9]{5}\\b", numbers)
    message("There are ", length(lNums), " correctly numbered photo.")
    message("There are ", nrow(photoInfo), " photos in your dataset.")
    message("These two numbers should be the same.")
    stopifnot(length(lNums) == nrow(photoInfo))
    TRUE      
}

matchGUID <- function(toMatch, photoDB, ufDB, guid, file, useFieldNumber=FALSE) {
    ## get the photo number
    getPhotoNb <- function(x) {
        fNm <- unlist(strsplit(x, "/"))
        fNm <- fNm[length(fNm)]
        fNm <- gsub("\\.[a-zA-Z]{3,}$", "", fNm)
        fNm
    }
    prefixFile <- unlist(strsplit(file, "-"))[1]
    selectedFile <- paste(prefixFile, "-selected.csv", sep="")   
    photoNm <- sapply(toMatch$"idigbio:OriginalFileName", getPhotoNb)
    toKeep <-  photoNm[photoNm %in% photoDB$photo_number]
    toMatchSub <- toMatch[photoNm %in% photoDB$photo_number, ]
    if (nrow(toMatch) != nrow(toMatchSub)) {
        write.csv(toMatchSub, file=selectedFile, row.names=FALSE)
        warning(nrow(toMatch) - nrow(toMatchSub), " images were not included",
                " in photoDB. The selected subset used was written to ",
                selectedFile)
    }
    if (useFieldNumber) {
        ## TODO: need to clean up the names
        tmpFieldNb <- photoDB[match(photoNm, photoDB$"Photo number"), "previous_number"]
        tmpUFID <- ufDB[match(tmpFieldNb, ufDB$PreviousNumber), c("UFID", "PhylumID")]
    }
    else {
        matchPic <- match(toKeep, photoDB$photo_number)
        tmpUFID <- photoDB[matchPic, ]
    }
    phyUFID <- paste(tmpUFID$UFID, tmpUFID$phylum, sep="-")
    tmpGUID <- guid[match(phyUFID, guid$ufid), "idigbio-guid"]
    tmpRes <- cbind(toMatchSub, "idigbio:SpecimenRecordUUID"=tmpGUID)
    if (any(is.na(tmpRes$"idigbio:SpecimenRecordUUID"))) {
        notMatchedFile <- paste(prefixFile, "-notMatched.csv", sep="")
        nNA <- sum(is.na(tmpRes$"idigbio:SpecimenRecordUUID"))
        write.csv(tmpUFID[is.na(tmpRes$"idigbio:SpecimenRecordUUID"), ],
                  file=notMatchedFile, row.names=FALSE)
        warning(nNA, " record(s) did not match. They are written to ",
                notMatchedFile)
        tmpRes <- tmpRes[!is.na(tmpRes$"idigbio:SpecimenRecordUUID"), ]
    }
    write.csv(tmpRes, row.names=FALSE, file=file)
    message("")
    TRUE
}

toMatch <- read.csv(file="PhotoImport/GUOK/dGUOK10-toBeMatched.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- read.csv(file="PhotoImport/GUOK/dGUOK10-photoInfo.csv",
                    stringsAsFactors=FALSE, check.names=FALSE)
photoDB <- subset(photoDB, photo_quality == 1 & nzchar(UFID))

matchGUID(toMatch, photoDB, ufDB, guid, file="dGUOK10-matched.csv")
