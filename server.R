library(shiny)
library(DT)

dat <- iris

## store state in global environment for now
if (!exists("r_state")) r_state <- list()

## is this used? Only from a clean start
r_state$dataviewer_search_columns <- list("","2.5...4","","","")

shinyServer(function(input, output, session) {
	output$ui_view_vars <- renderUI({
	  vars <- colnames(dat)

	  ## using selectizeInput with drag_drop and DT
	  selectizeInput("view_vars", "Select variables to show:", choices  = vars,
	                 selected = vars, multiple = TRUE,
	                 options = list(plugins = list('remove_button', 'drag_drop')))
	})


	getdata <- reactive({
	  if (input$apply_filter)
	    dat[1:10,]
	  else
	    dat
	})

 	## make nested list
	mknl <- function(x) list(search = x)

  observeEvent(input$dataviewer_search_columns, {
    isolate({
      r_state$dataviewer_search_columns <<- input$dataviewer_search_columns
    })
  })

  observeEvent(input$dataviewer_state, {
    isolate({
      r_state$dataviewer_state <<- input$dataviewer_state
    })
  })

  observeEvent(input$pivotr_search_columns, {
    isolate({
      r_state$pivotr_search_columns <<- input$pivotr_search_columns
    })
  })

  observeEvent(input$pivotr_state, {
    isolate({
      r_state$pivotr_state <<- input$pivotr_state
    })
  })


  observeEvent(input$refresh, {
    r_state <<- list()
  })

	output$dataviewer <- DT::renderDataTable({
	  if (is.null(input$view_vars)) return()

    search <- r_state$dataviewer_state$search$search
    if (is.null(search)) search <- ""

		DT::datatable(getdata()[,input$view_vars],
		  filter = list(position = "top", clear = TRUE), rownames = FALSE,
	    options = list(
	      stateSave = TRUE,   ## maintains state but does not show column filter settings
	      searchCols = lapply(r_state$dataviewer_search_columns, mknl),
        search = list(search = search),
	      order = r_state$dataviewer_state$order,
	      processing = FALSE
	    )
      ## using callback as suggested in https://github.com/rstudio/DT/issues/146
		  # , callback = JS("$('a#refresh').on('click', function() { table.state.clear(); });")
      ## alternative callback that simplifies setting initial values
		  , callback = DT::JS("$(window).unload(function() { table.state.clear(); })")
		)
  })

  output$tbl_col_search <- renderPrint(input$dataviewer_search_columns)
  output$tbl_global_search <- renderPrint(input$dataviewer_search)
  output$tbl_state <- renderPrint(str(input$dataviewer_state))
})
