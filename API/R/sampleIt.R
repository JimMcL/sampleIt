# Functions to query the samples database.
# The database contains information about specimens and their photos.
# 
# The database is queried using an HTTP interface.
# The host defaults to localhost, but can be specified by setting the global variable MORPHO_HOST.
#
library(ggmap)


# Returns the name of the host for database queries.
# If SI_HOST is set, returns it, otherwise returns 'localhost'.
SIChooseHost <- function() {
  if (exists('SI_HOST'))
    SI_HOST
  else
    'localhost'
}

# Returns a URL by pasting arguments on the end of 'http://MORPHO_HOST/'
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

# Returns specimen metadata corresponding to a set of photos
SIQuerySpecimensForPhotos <- function(photos) {
  specimenIds <- unique(photos[photos$imageabletype == 'Specimen',]$imageableid)
  SIQuerySpecimens(sprintf("id=[%s]", paste(specimenIds, collapse=',')))
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

#######################################################################
# Mapping functions

### TODO make this work
## # Plots a map of the specimens' collection sites
## SIMapSpecimenSites <- function(specimens, xlimFrac = 0.05, ylimFrac = 0.05, showLegend = FALSE) {
##   sites <- specimens[specimens$type == MTP_SPIDER,c('scientificName', 'decimalLatitude', 'decimalLongitude')]
##   xlim <- extendrange(sites$decimalLongitude, f = xlimFrac)
##   ylim <- extendrange(sites$decimalLatitude, f = ylimFrac)
##   MapSpeciesOcc(sites, columnNames = c("scientificName", "decimalLongitude", "decimalLatitude"), xlim = xlim, ylim = ylim, scaleFactor = 5, showLegend = showLegend)
##   map.cities(minpop = 50000)
## }

# Plots a google map of the specimens' collection sites
GMapSpecimenSites <- function(specimens, xlimFrac = 0.5, ylimFrac = 0.5, showLegend = FALSE) {

  cols <- c('decimalLatitude', 'decimalLongitude')
  sites <- ddply(specimens, cols, nrow)
  names(sites) <- c(cols, 'Count')
  
  xlim <- extendrange(sites$decimalLongitude, f = xlimFrac)
  ylim <- extendrange(sites$decimalLatitude, f = ylimFrac)
  m <- get_map(c(xlim[1], ylim[1], xlim[2], ylim[2]))

  # Explicitly print so that it works when plotting to a device  
  print(ggmap(m) + 
          geom_point(data = sites, aes(x = decimalLongitude, y = decimalLatitude, size = Count), 
                     color = 'black', fill= 'red', pch = 21, alpha = 0.5) + 
          scale_size_continuous(range = c(5, 20)) +
          theme(plot.margin = unit(c(0, 0, 0, 0), "cm")))
}


