idigbio-ingestion-data-preparation
==================================

Scripts used to check the validity and consistency of the data before being imported by the iDigBio photo ingestion tool

# Workflow and standards

1. Clean up the spreadsheet that contains photo information (this file should be
   named with the prefix of the photos, e.g., `dFMOK11-photoInfo.csv`).
   * Save the original file with the `-orig.csv` suffix (e.g., `dFMOK11-orig.csv`).
   * Check the names of the headers at least: `photo_number`,`photo_quality`, `phylum`, `previous_number` and/or `UFID`
   * Make sure that the photo names match the names of the files (not including extension, e.g., `dFMOK11-00001`).
   * subset the data to only include photos rated __1__
1. make sure that the photo names have correct file name (e.g., `dFMOK11-03891.JPG`):
   * correct prefix, ideally: d+ExpeditionCode+Year (Year is optional but strongly recommended)
   * number of Digits (all should have 5 digits)
   * extension in UPPERCASE
1. Generate the input CSV file using the iDigBio appliance
   * Select GUID = "{GUID prefix}{FileName}"
   * GUID prefix should always be: `urn:catalog:flmnh:invertebrate zoology:images:` (note the space between `invertebrate` and `zoology`, the `s` at the end of `images`, and the final `:`).
   * In CSV save path, include the name of the file. Use the same prefix as for the photos, followed by `-toBeMatched.csv` (e.g., `dFMOK11-toBeMatched.csv`) 
