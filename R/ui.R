ui <- fluidPage(theme = shinythemes::shinytheme("paper"),{

  tabsetPanel(id = "tabs",

              tabPanel("All races",
                       # shinythemes::themeSelector(),
                       fluidRow(
                         tags$style(
                           type = 'text/css',
                           '.modal-dialog { width: fit-content !important; height: fit-content !important; }'
                         ),
                         column(12,
                                DT::DTOutput('selectRaceTable'),
                                uiOutput('includemd_ui')
                         ),
                           column(4,
                                  uiOutput('details_ui')
                           ),
                           column(8,
                                  uiOutput('slickr_ui')
                           )
                       )
              ),
              tabPanel("Trends",
                       fluidRow(
                         column(12,
                                DT::DTOutput('trends_table'),
                                plotly::plotlyOutput('trends_plot')
                         )
                       )
              )
  )





  # tagList(
  #   DTOutput('selectRaceTable'),
  #   DTOutput('details'),
  #   slickROutput("slickr", width="600px"),
  #   DTOutput('trends_table'),
  #   plotOutput('trends_plot')
  # )
})
