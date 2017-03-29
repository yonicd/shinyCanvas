shinyServer(function(input, output, session) {
  
  network <- reactiveValues()
  
  output$d3=renderFluidSpline({
    fluidSpline(data.frame(x=c(200),y=c(400)),
                opts = list(xlim=c(200,1000),
                            ylim=c(200,1000),
                            interpolate='basis-closed'))
  })
  
  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    if(!is.null(netNodes)) network$nodes <- jsonlite::fromJSON(netNodes)
  })
  
  
    output$distPlot <- renderPlot({
      hist(rnorm(input$obs), col = 'darkgray', border = 'white')
    }, 
    width=exprToFunction(network$nodes[1]), 
    height=exprToFunction(network$nodes[2])
    )

  
  })