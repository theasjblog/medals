library(imager)
library(stringr)

# create race folders
# copy markdown
# copy json
# do images

maxImgSize <- config::get('maxImgSize')
img_size_large <- config::get('img_size_large')
size_tolerance <- 0.05
#folders
# root <- "/Users/adrianstevejoseph/Library/CloudStorage/GoogleDrive-josephadrian83@gmail.com/My Drive/race_data_raw"
# root <- "race_data_raw"
# root <- '/Users/adrianstevejoseph/Library/Mobile Documents/com~apple~CloudDocs/Sport/race_data_raw'
root <- "/Volumes/ASJ_backup/drive_others/Sport/race_data_raw"
allDirs <- list.dirs(root, full.names = TRUE)
allDirs <- allDirs[allDirs != root]
allDirs <- allDirs[!stringr::str_detect(allDirs, '/img')]

if(!dir.exists('race_data')){
  dir.create('race_data')
}
for(i in allDirs){
  idxThisImg <- which(allDirs == i)
  cat(paste0('Working on race "',
             basename(i),
             '" (',
             idxThisImg,
             ' of ',
             length(allDirs),
             ')\n'))
  newPath <- paste0('race_data',
                    stringr::str_split(i, 'race_data_raw')[[1]][2])

  if(!dir.exists(newPath)){
    dir.create(newPath)
  }
  if(file.exists(file.path(i, 'report.md'))){
    file.copy(file.path(i, 'report.md'),
              file.path(newPath, 'report.md'),
              overwrite = TRUE)
  }

  if(file.exists(file.path(i, 'data.json'))){
    file.copy(file.path(i, 'data.json'),
              file.path(newPath, 'data.json'),
              overwrite = TRUE)
  }

  if(!dir.exists(file.path(newPath, 'img'))){
    dir.create(file.path(newPath, 'img'))
  }

  if(!dir.exists(file.path(newPath, 'img_modal'))){
    dir.create(file.path(newPath, 'img_modal'))
  }

  allImg_source <- list.files(file.path(i, 'img'), full.names = TRUE)

  for(ii in allImg_source){
    thisImg_target <- file.path(newPath,
                                'img',
                                tolower(basename(ii)))

    tryCatch({
      if(file.exists(thisImg_target)){
        a <- imager::load.image(thisImg_target)
        wi <- dim(a)[1]
        if(wi >= maxImgSize*(1+size_tolerance) | wi <= maxImgSize*(1-size_tolerance)){
          a <- imager::load.image(ii)
          wi <- dim(a)[1]
          if(wi >= maxImgSize ){
            resize_by <- wi/maxImgSize
            a <- resize(a,
                        round(width(a)/resize_by),
                        round(height(a)/resize_by))
            imager::save.image(a, thisImg_target)
          } else {
            file.copy(ii, thisImg_target, overwrite = TRUE)
          }
        }
      } else {
        a <- imager::load.image(ii)
        wi <- dim(a)[1]
        if(wi >= maxImgSize ){
          resize_by <- wi/maxImgSize
          a <- resize(a,
                      round(width(a)/resize_by),
                      round(height(a)/resize_by))
          imager::save.image(a, thisImg_target)
        } else {
          file.copy(ii, thisImg_target, overwrite = TRUE)
        }
      }
    }, error = function(e){invisible(NULL)})


    thisImg_target <- file.path(newPath,
                                'img_modal',
                                tolower(basename(ii)))

    tryCatch({
      if(file.exists(thisImg_target)){
        a <- imager::load.image(thisImg_target)
        wi <- dim(a)[1]
        if(wi >= img_size_large*(1+size_tolerance) | wi <= img_size_large*(1-size_tolerance)){
          a <- imager::load.image(ii)
          wi <- dim(a)[1]
          if(wi >= img_size_large ){
            resize_by <- wi/img_size_large
            a <- resize(a,
                        round(width(a)/resize_by),
                        round(height(a)/resize_by))
            imager::save.image(a, thisImg_target)
          } else {
            file.copy(ii, thisImg_target, overwrite = TRUE)
          }
        }
      } else {
        a <- imager::load.image(ii)
        wi <- dim(a)[1]
        if(wi >= img_size_large ){
          resize_by <- wi/img_size_large
          a <- resize(a,
                      round(width(a)/resize_by),
                      round(height(a)/resize_by))
          imager::save.image(a, thisImg_target)
        } else {
          file.copy(ii, thisImg_target, overwrite = TRUE)
        }
      }
    }, error = function(e){invisible(NULL)})
  }

  if(dir.exists(file.path(newPath, 'img_modal'))){
    imgModal <- list.files(file.path(newPath, 'img_modal'))
    if(length(imgModal)>0){
      # web site

      web_temp <- readLines(file.path('inst', 'template_newDir', 'web_page.qmd'))
      if(!file.exists(file.path(i, 'report.md'))){
        # TODO: we should also remove reports that are empty
        web_temp <- web_temp[stringr::str_detect(string = web_temp,
                                                 pattern = "\\{\\{< include report.md >\\}\\}",
                                                 negate = TRUE)]
      }
      web_temp <- c(web_temp,
                    '::: {layout-ncol=4}')
      for(thisImg in imgModal){
        web_temp <- c(web_temp,
                           paste0('![](img_modal/',
                                  thisImg,
                                  '){ width="100" group="hi" }'))
        web_temp <- c(web_temp, '')
      }
      web_temp <- c(web_temp,
                    '',
                         ":::")

      writeLines(web_temp, file.path(newPath, 'web_page.qmd'))
    }
  }
}

cat('\n\nCHECK FOLDERS\n')
# check folders
allDirs <- list.dirs(file.path("race_data"), full.names = TRUE)
allDirs <- allDirs[allDirs != file.path("race_data")]
allDirs <- allDirs[!stringr::str_detect(allDirs, '/img')]
errors <- data.frame(dir_name = allDirs,
                     wrong_name = FALSE,
                     missing_data_json = FALSE,
                     missing_report_md = FALSE,
                     missing_imges = FALSE,
                     discrepancies_n_images = FALSE)

for(k in 1:length(allDirs)){
  i <- allDirs[k]
  files <- list.files(i)
  if(any(!files %in% c('img', 'img_modal', 'data.json', 'report.md'))){
    errors$wrong_name[k] <- TRUE
  }
  if(!'data.json' %in% files){
    errors$missing_data_json[k] <- TRUE
  }
  if(!'report.md' %in% files){
    errors$missing_report_md[k] <- TRUE
  }

  dirIn <- list.dirs(i)
  if(!all(c('img', 'img_modal') %in% basename(dirIn))){
    errors$missing_images[k] <- TRUE
  } else {
    imgList <- list.files(file.path(i, 'img'))
    imgModal <- list.files(file.path(i, 'img_modal'))
    if(any(sort(imgList) != sort(imgModal))){
      errors$discrepancies_n_images[k] <- TRUE
    }
  }
}
