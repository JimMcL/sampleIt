# R functions to query the samples database.
# The database contains information about specimens and their photos.
# 
# The database is queried using an HTTP interface.
# The host defaults to localhost, but can be specified by setting the global variable SI_HOST.
#
# See the file sampleItMaps.R for some mapping functionality.

# Returns the name of the host for database queries.
# If SI_HOST is set, returns it, otherwise returns 'localhost'.
SIChooseHost <- function() {
  if (exists('SI_HOST'))
    SI_HOST
  else
    'localhost'
}

# Returns a URL by pasting arguments on the end of 'http://SI_HOST/'
SIUrl <- function(...) {
  u <- sprintf("http://%s/%s", SIChooseHost(), paste0(...))
  #cat(paste0(u, '\n'))
  u
}

# Returns data from the database
SIQuery <- function(...) {
  tryCatch(
    read.csv(SIUrl(...), stringsAsFactors = F, strip.white=TRUE),
    error = function(e) stop(sprintf("SIQuery failed with arguments (%s): %s", paste(..., sep = ", "), e))
  )
}

# Returns photo metadata from the database. Any arguments are used to construct the URL
SIQueryPhotos <- function(...) {
  SIQuery('photos.csv?', ...)
}

# Returns specimen metadata from the database. Any arguments are used to construct the URL
SIQuerySpecimens <- function(...) {
  SIQuery('specimens.csv?', ...)
}

# Given a set of specimen IDs, returns their specimen records
SIQuerySpecimensByIds <- function(ids) {
  SIQuerySpecimens(sprintf("id=[%s]", paste(ids, collapse=',')))
}

# Returns specimen metadata corresponding to a set of photos
SIQuerySpecimensForPhotos <- function(photos) {
  specimenIds <- unique(photos[photos$imageabletype == 'Specimen',]$imageableid)
  SIQuerySpecimensByIds(specimenIds)
}

### TODO make this work
# Returns a data frame containing details of all photos in the database which satisfy the passed in query.
# The photo image files are downloaded to a local cache, and the file name is stored in the column "file".
#
# ... - arguments passed to SIQueryPhotos
# tempfileFnFn - optional function which returns a function passed to JDownload as the tempfileFnFn argument. Called with 1 argument, the photos data frame.
# strictOnly - if TRUE (the default), only strict outlines are returned (only meaningful for outlines)
# NOTE: only returns strict outlines
## SIGetPhotoData <- function(..., dir = JCacheDir, tempfileFnFn = NULL, strictOnly = FALSE, debug = FALSE) {
  
##   # Get the list of matching photos
##   photos <- SIQueryPhotos(...)

##   # Allow caller to specify how to name downloaded files
##   tempfileFn <- NULL
##   if (!is.null(tempfileFnFn))
##     tempfileFn <- tempfileFnFn(photos)
  
##   # Download the photos
##   file <- JDownload(photos$url, verbose = F, cacheDir = dir, tempfileFn = tempfileFn, debug = debug)
  
##   ## Read specimen info for each photo, and add to each photo
##   specimens <- SIQuerySpecimensForPhotos(photos)
##   # Some entries in the dbs have multiple specimens, which we don't care about, so eliminate them
##   specimens <- unique(specimens)
##   # Match specimens to photos
##   fac <- specimens[match(photos$imageableid, specimens$id),]
##   # Determine mimic type before removing description column
##   mt <- mimicType(fac)
##   # Remove columns with duplicate names in both photos and specimens
##   fac <- fac[,!colnames(fac) %in% c('id', 'description')]

##   ## Build photos data frame containing info about photos and specimens
##   cbind(photos, 
##         file, 
##         type = mt, 
##         label = sprintf("%s, %s", photos$imageableid, photos$id), 
##         individualId = individualIds(photos, sOrL, mt),
##         speciesId = speciesIds(fac, sOrL, mt),
##         typeId = typeIds(sOrL, mt),
##         fac,
##         stringsAsFactors = F)
## }

# Returns a data frame containing details of all photos in the database with the specified viewing angle.
# The photo image files are downloaded to a local cache, and the file name is stored in the column "file".
# angle - 'dorsal' or 'lateral'
SIGetOutlines <- function(angle) {
  SIGetPhotoData("ptype=Outline&imageable_type=Specimen&view_angle=", angle, strictOnly = TRUE)
}

# Returns the specimen collection date time.
SIRecordedDateTime <- function(specimens) {
  date <- paste(specimens$year, specimens$month, specimens$day, sep = "-")
 strptime(paste(date, specimens$time), format = "%Y-%m-%d %H:%M")
}
