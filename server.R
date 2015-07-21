library(shiny)
library(DT)

dat <- data.frame(
         factor = as.factor(rep(c("A","B"),5)),
         num = 1:10,
         char = letters[1:10],
         stringsAsFactors = FALSE
       )

## store state in global environment for now
if (!exists("r_state")) r_state <- list()

r_state$dataviewer_search_columns <- list("","2...8","")

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
    isolate({
      r_state$dataviewer_search_columns <<- input$dataviewer_search_columns
      # print("r_state col search")
      # print(r_state$dataviewer_search_columns)
    })
  })

  ## doesn't seem needed if staveState = TRUE
  # observeEvent(input$dataviewer_search, {
  #   isolate({
  #     r_state$dataviewer_search <<- input$dataviewer_search
  #     print("r_state global search")
  #     print(r_state$dataviewer_search)
  #   })
  # })

  observeEvent(input$dataviewer_state, {
    isolate({
      r_state$dataviewer_state <<- input$dataviewer_state
      print("r_state state")
      print(r_state$dataviewer_state)
    })
  })

  observeEvent(input$refresh, {
    r_state <<- list()
  })

	output$dataviewer <- DT::renderDataTable({
	  if (is.null(input$view_vars)) return()

		DT::datatable(dat[,input$view_vars],
		  filter = list(position = "top"), rownames = FALSE,
	    options = list(
	      stateSave = TRUE,   ## maintains state but does not show column filter settings
	      searchCols = lapply(r_state$dataviewer_search_columns, mknl),
	      # search = list(search = r_state$dataviewer_search),
	      order = r_state$dataviewer_state$order,
	      processing = FALSE
	    )
	  )
	})

	## yihui example
	# search = list(search = 'Ma'), order = list(list(2, 'asc'), list(1, 'desc'))

  output$tbl_col_search <- renderPrint(input$dataviewer_search_columns)
  output$tbl_global_search <- renderPrint(input$dataviewer_search)
  output$tbl_state <- renderPrint(str(input$dataviewer_state))
})
