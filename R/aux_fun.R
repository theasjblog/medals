get_trends_data <- function(allRaces, trends, idx){
  toPlot <- allRaces %>%
    filter(type == trends$type[idx]) %>%
    filter(distance == trends$distance[idx])

  a <- lapply(toPlot$race_dir, function(d){
    tmp <- jsonlite::fromJSON(file.path(d, 'data.json'))
    df <- data.frame(time = tmp$time) %>%
      bind_cols(tmp$breakdown)
    for(i in 1:ncol(df)){
      df[1, i] <- convert_to_min(df[1, i])
    }
    df$date <- tmp$date
    return(df)
  }) %>%
    bind_rows()

  a <- a %>%
    pivot_longer(cols = colnames(a)[colnames(a) != 'date']) %>%
    mutate(date = as.Date(date),
           value = as.numeric(value))

  return(a)
}

convert_to_min <- function(time_str){
  sp <- unlist(stringr::str_split(time_str, ' '))
  for(i in 1:length(sp)){
    if(stringr::str_detect(sp[i], 'h')){
      sp[i] <- substr(sp[i], 1, nchar(sp[i])-1)
      sp[i] <- as.numeric(sp[i])*60
    }
    if(stringr::str_detect(sp[i], 'm')){
      sp[i] <- substr(sp[i], 1, nchar(sp[i])-1)
      sp[i] <- as.numeric(sp[i])
    }
    if(stringr::str_detect(sp[i], 's')){
      sp[i] <- substr(sp[i], 1, nchar(sp[i])-1)
      sp[i] <- as.numeric(sp[i])/60
    }
  }
  tot_min <- round(sum(as.numeric(sp)), 1)
  return(tot_min)
}


get_trend_plot <- function(df){
  ggplot(df) +
    aes(x = date, y = value, colour = name, group = name) +
    geom_line(linewidth = 2L) +
    scale_color_hue(direction = 1) +
    labs(
      x = "Date",
      y = "Time [min]",
      title = "Performance Trend",
      color = "Activity"
    ) +
    theme_minimal() +
    theme(
      axis.text.y = element_text(size = 15L),
      axis.text.x = element_text(size = 15L),
      legend.text = element_text(size = 16L),
      legend.title = element_text(face = "bold",
                                  size = 14L)
    )

}
