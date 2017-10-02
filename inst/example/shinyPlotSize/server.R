shinyServer(function(input, output, session) {
  
  network <- shiny::reactiveValues()
  
  output$d3=shinyCanvas::renderCanvas({
    shinyCanvas::canvas(data.frame(x=c(200),y=c(400)),
                opts = list(xlim=c(200,1000),
                            ylim=c(200,1000),
                            interpolate='basis-closed',
                            x_angle=90))
  })
  
  shiny::observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    if(!is.null(netNodes)) network$nodes <- jsonlite::fromJSON(netNodes)
    
    output$distPlot <- shiny::renderPlot({
      hist(stats::rnorm(input$obs), col = 'darkgray', border = 'white')
    }, 
     width=shiny::exprToFunction(network$nodes[1]), 
     height=shiny::exprToFunction(network$nodes[2])
    )

  })

  
  })