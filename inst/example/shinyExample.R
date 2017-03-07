library(fluidSpline)
library(shiny)
server <- function(input, output) {

  network <- reactiveValues()

  df<-reactive({
    data.frame(Var1=1:10,Var2=sort(rexp(10),decreasing = T))
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

  observeEvent(network$path,{
    output$pathOut<-renderTable({
      dat=as.data.frame(network$path)
      colnames(dat)=names(df())
      dat=data.frame(Id=1:nrow(dat),dat)
      dat
    })    
  })
  
  output$d3 <- renderFluidSpline({
    isolate({fluidSpline(obj = df(),animate = T,
                         animate.opts = list(duration=500,pathRadius=5),
                         cW = 400,cH = 400)})
  })
}

ui <- fluidPage(
  column(9,fluidSplineOutput(outputId="d3",width = '600px',height = '600px')),
  column(3,tableOutput('pointsOut')),
  column(3,tableOutput('pathOut'))
)

shinyApp(ui = ui, server = server)
