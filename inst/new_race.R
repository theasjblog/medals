create_new_folder <- function(race_name = 'RACE NAME',
                              race_date = as.character(Sys.Date()),
                              race_type = 'RACE TYPE',
                              race_distance = '1m',
                              race_link = '',
                              race_time = '',
                              race_overall = '',
                              race_category = '',
                              target_folder = 'race_data_raw'){

  R.utils::copyDirectory(file.path('inst', 'template_newDir'),
                         file.path(target_folder, paste0(race_date,
                                                         '_',
                                                         toupper(gsub(' ', '_', race_name)))))

  race_data <- jsonlite::fromJSON(file.path('inst', 'template_newDir', 'data.json'))
  race_data$race <- toupper(race_name)
  race_data$date <- race_date
  race_data$type <- race_type
  race_data$distance <- race_distance
  race_data$position_overall <- race_overall
  race_data$position_category <- race_category
  race_data$details <- race_link
  race_data$time <- race_time

  dest_path <- file.path(target_folder,
                         paste0(race_date,
                                '_',
                                toupper(gsub(' ', '_', race_name))))

  jsonlite::write_json(race_data,
                       path = file.path(dest_path,
                                        'data.json'),
                       auto_unbox = TRUE,
                       pretty = TRUE)
  mark_temp <- readLines(file.path('inst', 'template_newDir', 'report.md'))
  mark_temp <- gsub('RACE_NAME', stringr::str_to_title(race_name), mark_temp)
  mark_temp <- gsub('RACE_DATE', race_date, mark_temp)
  writeLines(mark_temp, file.path(dest_path, 'report.md'))
}


# create_new_folder(race_name = 'RACE NAME',
#                   race_date = as.character(Sys.Date()),
#                   race_type = 'RACE TYPE',
#                   race_distance = '1m',
#                   race_link = '',
#                   race_time = '',
#                   race_overall = '',
#                   race_category = '',
#                   target_folder = 'race_data_raw')
