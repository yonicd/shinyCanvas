library(stats4)
library(shinyCanvas)
library(shiny)


server <- function(input, output) {

  network <- reactiveValues()

  df<-reactive({
    data.frame(x=seq(-5,5,.3),prob=dnorm(seq(-5,5,.3), mean =0, sd = 1))
  })
  
  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    if(!is.null(netNodes)) network$nodes <- jsonlite::fromJSON(netNodes)
    
    pathNodes=input$d3_update$.pathData
    if(!is.null(pathNodes)) network$path <- jsonlite::fromJSON(pathNodes)
  })

  observeEvent(network$nodes,{
    output$pointsOut<-renderTable({
      dat=network$nodes
      colnames(dat)=names(df())
      dat.df=data.frame(Id=1:nrow(dat),dat)
      dat.df
    })    
  })

  # observeEvent(network$path,{
  #   output$pathOut<-renderTable({
  #     dat=as.data.frame(network$path)
  #     colnames(dat)=names(df())
  #     dat=data.frame(Id=1:nrow(dat),dat)
  #     dat
  #   })    
  # })
  
  output$d3 <- renderCanvas({
    canvas(obj = df(),
           animate = TRUE,
           interpolate='basis',
           duration=5000,
           xlim = c(-5.2,5.2),
           ylim=c(0,.5)
           )
  })

  samp<-eventReactive(input$btn,{
    dat=as.data.frame(network$path)
    colnames(dat)=names(df())
    sort(sample(dat$x,size = 1000,replace = T,prob = dat$prob))
  })
  
  newEstDF<-eventReactive(input$btn,{
    x<-samp()
    LL <- function(mu, sigma) {
      R = suppressWarnings(dnorm(x, mu, sigma))
      -sum(log(R))
    }    
    
    out=mle(LL, start = list(mu = 0, sigma=1))
    data.frame(signif(t(out@coef),2))
  })
  
  pts<-eventReactive(input$btn,{
    points(network$path,col='red',pch=20,cex=1)
  })
  
  output$plotCompare<-renderPlot({
    curve(dnorm(x, mean =0, sd = 1),
          from=-4, to=4, col="blue",
          xlab="X", ylab="Probability Density",
          ylim=c(0,0.5),
          main=sprintf('Initial N(0,1) \n Sample N(%s,%s)',newEstDF()$mu,newEstDF()$sigma))
    par(new = TRUE)
    curve(dnorm(x, mean =newEstDF()$mu, sd = newEstDF()$sigma),
          from=-4, to=4, col="red",xlab='',ylab='',
          ylim=c(0,0.5))
    pts()
    
    
  })

  output$scatterPlot<-renderPlot({
    plot(samp())
  })
  
}

ui <- fluidPage(
  column(7,
         canvasOutput(outputId="d3"),
         actionButton(inputId = 'btn',label = 'Estimate Parameters'),
         plotOutput('plotCompare')
  ),
  column(3,
         p('Plot Points'),
         tableOutput('pointsOut')
         )
  # column(3,
  #        p('Path Sample'),
  #        tableOutput('pathOut')
  #        )
)

shinyApp(ui = ui, server = server)
