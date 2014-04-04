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
