library(shiny)
library(DT)

dat <- iris

## store state in global environment for now
if (!exists("r_state")) r_state <- list()

## is this used? Only from a clean start
r_state$dataviewer_search_columns <- list("","2.5...4","","","[\"setosa\"]")

shinyServer(function(input, output, session) {
	output$ui_view_vars <- renderUI({
	  vars <- colnames(dat)

	  ## using selectizeInput with drag_drop and DT
	  selectizeInput("view_vars", "Select variables to show:", choices  = vars,
	                 selected = vars, multiple = TRUE,
	                 options = list(plugins = list('remove_button', 'drag_drop')))
	})

 	## make nested list
	mknl <- function(x) list(search = x)

  observeEvent(input$dataviewer_search_columns, {
    r_state$dataviewer_search_columns <<- input$dataviewer_search_columns
  })

  observeEvent(input$dataviewer_state, {
    r_state$dataviewer_state <<- input$dataviewer_state
  })

  observeEvent(input$refresh, {
    r_state <<- list()
  })

	output$dataviewer <- DT::renderDataTable({
	  req(input$view_vars)

    search <- r_state$dataviewer_state$search$search
    if (is.null(search)) search <- ""

		DT::datatable(iris[,input$view_vars],
		  filter = list(position = "top", clear = TRUE),
		  rownames = FALSE,
		  selection = "none",
	    options = list(
	      stateSave = TRUE,
	      searchCols = lapply(r_state$dataviewer_search_columns, mknl),
        search = list(search = search, regex = TRUE),
        order = {if (is.null(r_state$dataviewer_state$order)) list()
          else r_state$dataviewer_state$order},
	      processing = FALSE
	    ),
		  callback = DT::JS("$(window).unload(function() { table.state.clear(); })")
		)
  })

  output$tbl_col_search <- renderPrint(input$dataviewer_search_columns)
  # output$tbl_global_search <- renderPrint(input$dataviewer_search)
  # output$tbl_state <- renderPrint(str(input$dataviewer_state))
})
