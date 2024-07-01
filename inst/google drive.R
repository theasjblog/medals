install.packages("googledrive")
library(googledrive)

# Authenticate Google account
drive_auth()

# Define the folder ID and local directory
folder_id <- "race_data_raw"
local_dir <- file.path('testDrive')

# List files in the Google Drive folder
files <- drive_ls(as_id(folder_id))
files <- drive_ls(folder_id, recursive = FALSE) %>%
  filter(stringr::str_detect(name, '.zip'))

# Create the local directory if it does not exist
if (!dir.exists(local_dir)) {
  dir.create(local_dir)
}

# Download each file in the folder
lapply(files$id, function(file_id) {
  drive_download(as_id(file_id), path = file.path(local_dir, files$name[files$id == file_id]), overwrite = TRUE)
})

###############
allImgs <- list.files('race_data_raw', full.names = TRUE, recursive = TRUE)
allImgs <- allImgs[tolower(tools::file_ext(allImgs)) %in% c('png', 'jpg', 'jpeg')]
for(i in allImgs){
  file.rename(i,
              file.path(dirname(i),
                        tolower(basename(i))))
}
