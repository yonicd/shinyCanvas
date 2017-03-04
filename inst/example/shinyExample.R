library(fluidSpline)
library(shiny)
server <- function(input, output) {

  network <- reactiveValues()

  df<-reactive({
    data.frame(Var1=1:20,Var2=sort(rexp(20),decreasing = T))
  })
  
  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    
    pathSample=input$d3_update$.pathSample
    
    network$nodes <- jsonlite::fromJSON(netNodes)
  })

  observeEvent(network$nodes,{
    output$pointsOut<-renderTable({
      dat=network$nodes
      colnames(dat)=names(df())
      dat.df=data.frame(Id=1:nrow(dat),dat)
      dat.df
    })    
  })


  output$d3 <- renderFluidSpline({
    isolate({fluidSpline(obj = df(),cW = 600,cH = 800)})
  })
}

ui <- fluidPage(
  column(9,fluidSplineOutput(outputId="d3",width = '600px',height = '600px')),
  column(3,tableOutput('pointsOut'))
)

shinyApp(ui = ui, server = server)
