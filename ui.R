shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      includeScript("www/js/jquery-ui.custom.min.js"),
      uiOutput("ui_view_vars"),
      checkboxInput("apply_filter", "Apply filter", FALSE),
      tags$a(id = "refresh", href = "#", class = "action-button",
             list(icon("refresh"), "Refresh"),
             onclick = "window.location.reload();")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("View", DT::dataTableOutput("dataviewer"),
                 verbatimTextOutput("tbl_col_search"),
                 verbatimTextOutput("tbl_global_search"),
                 verbatimTextOutput("tbl_state")),
        tabPanel("Pivot", DT::dataTableOutput("pivotr"))
      )
    )
  )
))
