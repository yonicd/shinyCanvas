  require(fluidSpline)
  require(survival)
  require(broom)
  
  server <- function(input, output) {
  
  network <- reactiveValues()

  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    if(!is.null(netNodes)) network$nodes <- jsonlite::fromJSON(netNodes)
     pathNodes=input$d3_update$.pathData
     if(!is.null(pathNodes)) network$path <- jsonlite::fromJSON(pathNodes)
  })
  
  observeEvent(network$nodes,{
    output$pointsOut<-renderTable({
      dat=network$nodes
      colnames(dat)=names(ys.df())
      dat.df=data.frame(Id=1:nrow(dat),dat)
      dat.df
    })    
  })
  
  observeEvent(network$path,{
    output$pathOut<-renderTable({
      dat=as.data.frame(network$path)
      colnames(dat)=names(ys.df())
      dat=data.frame(Id=1:nrow(dat),dat)
      dat
    })
  })

  ys.df<-reactive({
    data.frame(time=c(55,187,216,240,244,335,361,373,375,386,500),
                      surv=c(0.95,0.90,0.85,0.80,0.75,0.70,0.65,0.60,0.55,0.50,0.50))
  })
    
  output$d3 <- renderFluidSpline({

    
    isolate({fluidSpline(obj = ys.df(),animate = T,ylim=c(0,1.1),
                         animate.opts = list(duration=500,pathRadius=10),
                         cW = 400,cH = 400)})
  })
  
  failures <-reactive({
    network$nodes[,1]
    })
  
  y<-reactive({
    Surv(c(failures(), rep(500, 10)), c(rep(1, length(failures())), rep(0, 10)))
  })

  ## Estimate parameters for Weibull distribution.
  yw<-reactive({
    survreg(y() ~ 1, dist="weibull")
    })

  output$KMplot<-renderPlot({
    ## Generate a Weibull probability plot.
    plot(failures(), -log(1-ppoints(failures(), a=0.3)),
         log="xy", pch=19, col="red",
         xlab="Hours", ylab="Cumulative Hazard",
         main='Weibull probability plot')
  })

  output$ywEst<-renderTable({
    tidy(yw())
  })

  output$ywFit<-renderTable({
    glance(yw())
  })

  ywWei<-reactive({
    ## Maximum likelihood estimates:
    ## For the Weibull model, survreg fits log(T) = log(eta) +
    ## (1/beta)*log(E), where E has an exponential distribution with mean 1
    ## eta = Characteristic life (Scale)
    ## beta = Shape

    etaHAT <- exp(coefficients(yw())[1])
    betaHAT <- 1/yw()$scale

    ## Lifetime: expected value and standard deviation.
    muHAT = etaHAT * gamma(1 + 1/betaHAT)
    sigmaHAT = etaHAT * sqrt(gamma(1+2/betaHAT) - (gamma(1+1/betaHAT))^2)

    data.frame(eta=etaHAT, beta=betaHAT,mu=muHAT, sigma=sigmaHAT)
  })

  output$ywWei<-renderTable({
    ywWei()
  })

  output$densityWei<-renderPlot({
    df<-ywWei()
    ## Probability density of fitted model.
    curve(dweibull(x, shape=df$beta, scale=df$eta),
          from=0, to=df$mu+6*df$sigma, col="blue",
          xlab="Hours", ylab="Probability Density",
          main='Probability density of fitted model')
  })
  
}

  ui <- fluidPage(
    column(width=6,
    fluidSplineOutput(outputId="d3"),
    column(6,
    p('Point Data'),
    tableOutput('pointsOut')),
    column(6,
    p('Sample from Step Function'),
    tableOutput('pathOut'))),
    
    column(width=4,
    plotOutput('KMplot'),
    plotOutput('densityWei')),
    column(width=2,
    p('Weibull model: survreg fits log(T) = log(eta) + (1/beta)*log(E)'),
    p('MLE Estimates'),
    tableOutput('ywEst'),
    p('Fit'),
    tableOutput('ywFit'),
    p('Lifetime: expected value and standard deviation'),
    tableOutput('ywWei')
    )
  )

shinyApp(ui = ui, server = server,options = 'launch.browser')
