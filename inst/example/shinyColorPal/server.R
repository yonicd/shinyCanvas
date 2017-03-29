shinyServer(function(input, output, session) {
  
  network <- reactiveValues()
  
  output$distPlot <- renderPlot({
    df<-samp()
    colnames(df)=c('R','G')
    sampOut<-df
    x<-cbind(sampOut,rep(input$B,nrow(sampOut)))
    plot(df,ylim=c(0,1),xlim=c(0,1),col=rgb(x))
  })
  
  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    if(!is.null(netNodes)) network$nodes <- jsonlite::fromJSON(netNodes)
  })
  
  
  samp<-eventReactive({network$nodes},{
    rhull(600, network$nodes)
  })
  
  output$d3=renderFluidSpline({
    df=data.frame(R=c(0,0,1,1),G=c(0,1,1,0))
    fluidSpline(df,
                opts = list(xlim=c(0,1),
                            ylim=c(0,1),
                            interpolate='cardinal-closed'
                            )
                )
  })

})