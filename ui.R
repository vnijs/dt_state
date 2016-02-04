shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      includeScript("www/js/jquery-ui.custom.min.js"),
      uiOutput("ui_view_vars"),
      tags$a(id = "refresh", href = "#", class = "action-button",
             list(icon("refresh"), "Clear state"),
             onclick = "window.location.reload();")
    ),
    mainPanel(
        tabPanel("View", DT::dataTableOutput("dataviewer"),
                 verbatimTextOutput("tbl_col_search")
                 #, verbatimTextOutput("tbl_global_search")
                 #, verbatimTextOutput("tbl_state")
      )
    )
  )
))
