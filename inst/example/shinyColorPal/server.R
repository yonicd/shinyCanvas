shinyServer(function(input, output, session) {
  
  network <- reactiveValues()
  
  output$THREE<-renderUI({
    x<-c('Red','Green','Blue')
    xLbl<-x[which(!c('R','G','B')%in%c(input$xAxis,input$yAxis))]
    sliderInput("slide", paste(xLbl,"Level"), min = 0, max = 1, value = 0.5)
  })
  
  output$distPlot <- renderPlot({
    df<-samp()
    colnames(df)=c(input$xAxis,input$yAxis)
    sampOut<-df
    x<-cbind(sampOut,rep(input$slide,nrow(sampOut)))
    xInd<-c('R','G','B')[which(!c('R','G','B')%in%c(input$xAxis,input$yAxis))]
    x<-x[,match(c('R','G','B'),c(input$xAxis,input$yAxis,xInd))]
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
    df=data.frame(R=c(0.2,0.5,0.8),G=c(0.5,0.8,0.2))
    names(df)=c(input$xAxis,input$yAxis)
    fluidSpline(df,
                opts = list(xlim=c(0,1),
                            ylim=c(0,1),
                            interpolate='cardinal-closed'
                            )
                )
  })

})