library(fluidSpline)
library(shiny)
server <- function(input, output) {

  network <- reactiveValues()

  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    network$nodes <- jsonlite::fromJSON(netNodes)
  })

  observeEvent(network$nodes,{
    output$pointsOut<-renderTable({
      dat=network$nodes
      dat.df=data.frame(Id=1:nrow(dat),dat)
      names(dat.df)=c('Id','X','Y')
      dat.df
    })    
  })


  output$d3 <- renderFluidSpline({
    isolate({fluidSpline(obj = data.frame(x=1:10,y=runif(10)),cW =     600,cH = 300)})
  })
}

ui <- fluidPage(
  column(9,fluidSplineOutput(outputId="d3",width = '1000px',height = '800px')),
  column(3,tableOutput('pointsOut'))
)

shinyApp(ui = ui, server = server)
