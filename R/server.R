server <- function(input, output, session){

  output$selectRaceTable <- renderDT({
    DT::datatable(allRaces %>%
                    select(c('race', 'type', 'distance', 'time', 'date')),
                  rownames = FALSE,
                  filter = 'top',
                  selection = 'single',
                  options = list(
                    paging =TRUE,
                    pageLength =  10
                  ))
  })


  output$details_ui <- renderUI({
    req(input$selectRaceTable_rows_selected)
    wellPanel(DT::DTOutput('details'))
  })

  output$slickr_ui <- renderUI({
    req(input$selectRaceTable_rows_selected)

    allImg <- list.files(file.path(allRaces$race_dir[input$selectRaceTable_rows_selected],
                                   'img'), full.names = TRUE)
    allImg <- allImg[tools::file_ext(allImg) %in% c('png', 'jpg', 'jpeg')]

    validate(need(length(allImg) > 0,
                  ''))
    slickR::slickROutput("slickr", width=paste0(config::get('maxImgSize'),"px"))
  })



  output$includemd_ui <- renderUI({
    req(input$selectRaceTable_rows_selected)
    mdpath <- file.path(
      allRaces$race_dir[input$selectRaceTable_rows_selected],
      'report.md'
    )
    if(file.exists(mdpath)){
      wellPanel(includeMarkdown(mdpath))
    }
  })

  output$trends_table <- renderDT({
    DT::datatable(trends,
                  rownames = FALSE,
                  selection = 'single')
  })


  output$details <- renderDT({
    req(input$selectRaceTable_rows_selected)
    tmp <- jsonlite::fromJSON(
      file.path(
        allRaces$race_dir[input$selectRaceTable_rows_selected],
        'data.json'
      )
    )
    breakdown <- tmp$breakdown
    tmp$breakdown <- NULL
    tmp <- as.data.frame(tmp) %>%
      dplyr::bind_cols(breakdown)

    details <- unlist(tmp$details)
    if(!is.null(details)){
      details <- paste0('<a href="',
                        details, '">Link to activity file</a>')
      details_names <- paste0('details_', seq(1, length(details)))
    } else {
      details_names <- NULL
    }

    tmp$details <- NULL


    df <- as.data.frame(t(tmp)) %>%
      dplyr::bind_rows(data.frame(V1 = details))

    df <- data.frame('  ' = c(colnames(tmp), details_names),
                     ' ' = df,
                     check.names = FALSE)
    colnames(df) <- NULL


    datatable(df,
              rownames = FALSE,
              selection = 'single',
              escape = FALSE,
              options = list(
                paging =TRUE,
                pageLength =  20
              ))
  })

  output$slickr <- renderSlickR({
    req(input$selectRaceTable_rows_selected)
    allImg <- list.files(file.path(allRaces$race_dir[input$selectRaceTable_rows_selected],
                                   'img'), full.names = TRUE)
    allImg <- allImg[tools::file_ext(allImg) %in% c('png', 'jpg', 'jpeg')]

    slickR(allImg)
  })

  observeEvent(input$slickr_current,{
    req(input$selectRaceTable_rows_selected)
    imgIdx <- input$slickr_current$.relative_clicked
    if(length(imgIdx) == 1){
      allImg <- list.files(file.path(allRaces$race_dir[input$selectRaceTable_rows_selected],
                                     'img'), full.names = TRUE)
      allImg <- allImg[tools::file_ext(allImg) %in% c('png', 'jpg', 'jpeg')]

      selectedImg <- allImg[imgIdx]
      selectedImg <- gsub('/img/', '/img_modal/', selectedImg)

      showModal(modalDialog(
        title = "",
        renderImage({
          list(src = selectedImg,
               contentType = 'image/png',
               width = config::get('img_size_large'),
               # height = 300,
               alt = "This is alternate text")
        },
        deleteFile = FALSE),
        easyClose = TRUE,
        footer = NULL
      ))
    }
  })


  output$trends_plot <- renderPlotly({
    req(input$trends_table_rows_selected)
    df <- get_trends_data(allRaces, trends, input$trends_table_rows_selected)
    p <- get_trend_plot(df)

    plotly::ggplotly(p)
  })
}
