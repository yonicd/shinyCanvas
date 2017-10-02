shinyServer(function(input, output, session) {
  
  network <- reactiveValues()
  
  output$THREE<-renderUI({
    x<-c('Red','Green','Blue')
    xLbl<-x[which(!c('R','G','B')%in%c(input$xAxis,input$yAxis))]
    sliderInput("slide", paste(xLbl,"Level"), min = 0, max = 1, value = 0.5)
  })
  
  observeEvent(input$d3_update,{
  output$distPlot <- renderPlot({
    # sampOut<-samp()
    # x<-cbind(sampOut,rep(input$slide,nrow(sampOut)))
    # xInd<-c('R','G','B')[which(!c('R','G','B')%in%c(input$xAxis,input$yAxis))]
    # x<-x[,match(c('R','G','B'),c(input$xAxis,input$yAxis,xInd))]
    # rx=sort(rgb(x))
    # s <- seq(nrow(data)-1)
    # plot(x=data$x,y=data$y,type='n',ylim=c(0.9,1.1))
    # segments(x0=data$x[s],y0=data$y[s],x1=data$x[s+1],y1=data$y[s+1],col=rx[s],lwd=5)
    
    df<-samp()
    colnames(df)=c(input$xAxis,input$yAxis)
    sampOut<-df
    x<-cbind(sampOut,rep(input$slide,nrow(sampOut)))
    xInd<-c('R','G','B')[which(!c('R','G','B')%in%c(input$xAxis,input$yAxis))]
    x<-x[,match(c('R','G','B'),c(input$xAxis,input$yAxis,xInd))]
    plot(df,ylim=c(0,1),xlim=c(0,1),col=rgb(x),pch=20)
  })
  })
  
  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    if(!is.null(netNodes)) network$nodes <- jsonlite::fromJSON(netNodes)
  })
  
  
  samp<-eventReactive({network$nodes},{
    rhull(1000, as.matrix(concaveman(as.data.frame(network$nodes))))
  })
  
  output$d3=renderCanvas({
    df=data.frame(R=c(0.2,0.5,0.8),G=c(0.5,0.6,0.2))
    names(df)=c(input$xAxis,input$yAxis)
    canvas(df,
                opts = list(xlim=c(0,1),
                            ylim=c(0,1),
                            interpolate='linear-closed'
                            )
                )
  })

})