
extensionToUpper <- function(path) {
    lF <- list.files(path=path, pattern="\\.[a-z]{3,}$", full.names=TRUE)
    splitFileName <- strsplit(lF, "\\.")
    extToUp <- lapply(splitFileName, function(x) {
        x[length(x)] <- toupper(x[length(x)])
        x
    })
    newNm <- sapply(extToUp, function(x) paste0(x, collapse="."))
    test <- apply(cbind(lF, newNm), 1, function(x) file.rename(x[1], x[2]))
    invisible(all(test))
}

changeSeparator <- function(path, from="_", to="-") {
    lF <- list.files(path=path,
                     pattern=paste(".+", from, "[0-9]+a?\\.[A-Z]{3,}$", sep=""),
                     full.names=TRUE)
    newNm <- gsub(paste("(.+/)(.+)", from, "([0-9]+a?\\.[A-Z]{3,}$)", sep=""),
                  paste("\\1\\2", to, "\\3", sep=""), lF)

    test
}

checkPhotoFolder <- function(path, quiet=FALSE) {
    lF <- list.files(path=path, pattern="\\.JPG$")
    if (!quiet) message("There were ", length(lF), " images in ", path, ".")
    if (length(lF) < 1) {
        stop("No images found in the folder. Check that the file extensions",
             " are JPG (uppercase). Use the function extensionToUpper() to fix",
             " it.")
    }
    photoName <- strsplit(lF, "-")
    prefixes <- sapply(photoName, function(x) x[1])
    uniqPref <- unique(prefixes)
    if (!quiet) message("There is ", length(uniqPref), " prefix (problem if not 1)")
    if (length(uniqPref) != 1) {
        stop("The prefix listed for the photo file name is not ",
             "formatted correctly")
    }
    numbers <- sapply(photoName, function(x) x[2])
    lNums <- grep("\\b[0-9]{5}a?\\b", numbers)
    if (!quiet) message("There are ", length(lNums), " correctly numbered photo.")
    if (!quiet) message("There are ", length(lF), " photos in your folder.")
    if (length(lNums) != length(lF)) {
        stop("The number of correctly numbered pictures is not the ",
             "same as the total number of pictures. Some must be ",
             "named incorrectly")
    }
    if (!quiet) message("All good! You can now run the iDigBio appliance",
                        " to generate the CSV file.")
    invisible(TRUE)
}

checkPhotoInfoFile <- function(file, quiet=FALSE) {
    ## correct file name
    noPath <- gsub(".+/(.+)$", "\\1", file)
    fnm <- unlist(strsplit(noPath, "-"))
    stopifnot(length(fnm) == 2)
    prefix <- fnm[1]
    conditions <- logical(6)
    if (!quiet) message("Photo prefix for this dataset is: ", prefix)
    if (fnm[2] == "photoInfo.csv") {
        conditions[1] <- TRUE
    }
    else {
        stop(paste("The file should be named dXXXX-photoInfo.csv,",
                   "it doesn't look like it is."))
    }

    ## check headers
    photoInfo <- read.csv(file=file, stringsAsFactors=FALSE)
    neededHeaders <- c("photo_number", "photo_quality", "phylum")
    if (all(neededHeaders %in% names(photoInfo))) {
        conditions[2] <- TRUE
    }
    else {
        stop("Issue with the headers, they should include: ",
             paste0(neededHeaders, collapse=", "), ".")
    }
    optionalHeaders <- c("previous_number", "UFID")
    if (any(optionalHeaders %in% names(photoInfo))) {
        conditions[3] <- TRUE
    }
    else {
        stop("At least one of the headers needs to be: ",
             paste0(optionalHeaders, collapse=", "), ".")
    }

    ## check photo file names
    photoName <- strsplit(photoInfo$photo_number, "-")
    prefixes <- sapply(photoName, function(x) x[1])
    uniqPref <- unique(prefixes)
    if (!quiet) message("There is ", length(uniqPref), " prefix (problem if not 1)")
    if (length(uniqPref) == 1) {
        conditions[4] <- TRUE
    }
    else {
        stop("The prefix listed for the photo file name is not ",
             "formatted correctly")
    }    
    if (!quiet) message("The photo prefix is ", uniqPref, ". Problem if not: ", prefix)
    if (uniqPref == prefix) {
        conditions[5] <- TRUE
    }
    else {
        stop("The photo prefix should match your photoInfo file name.")
    }
    numbers <- sapply(photoName, function(x) x[2])
    lNums <- grep("\\b[0-9]{5}\\b", numbers)
    if (!quiet) message("There are ", length(lNums), " correctly numbered photo.")
    if (!quiet) message("There are ", nrow(photoInfo), " photos in your dataset.")
    if (length(lNums) == nrow(photoInfo)) {
        conditions[6] <- TRUE        
    }
    else {
        stop("The number of correctly numbered pictures is not the ",
             "same as the total number of pictures. Some must be ",
             "named incorrectly")
    }
    if (sum(conditions) == length(conditions)) {
        if (!quiet) message("It looks good.")
        invisible(TRUE)
    }
    else {
        if (!quiet) message("Something is wrong.")
        FALSE
    }
}


matchGUID <- function(toMatch, photoDB, ufDB, guid, file, useFieldNumber=FALSE) {
    ## get the photo number
    getPhotoNb <- function(x) {
        fNm <- unlist(strsplit(x, "/"))
        fNm <- fNm[length(fNm)]
        fNm <- gsub("a?\\.[a-zA-Z]{3,}$", "", fNm)
        fNm
    }
    prefixFile <- unlist(strsplit(file, "-"))[1]
    selectedFile <- paste(prefixFile, "-selected.csv", sep="")   
    photoNm <- sapply(toMatch$"idigbio:OriginalFileName", getPhotoNb)
    toKeep <-  photoNm[photoNm %in% photoDB$photo_number]
    if (length(toKeep) == 0)
        stop("Something is wrong. It doesn't look there is any match",
             " between your photo file names and the ones provided in",
             " the photoDB.")
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
    if (all(is.na(tmpGUID))) {
        stop("These records don't seem to exist in the iDigBio occurence database.")
    }
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
