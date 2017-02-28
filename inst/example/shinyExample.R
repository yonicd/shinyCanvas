library(fluidSpline)
library(shiny)
server <- function(input, output) {

  network <- reactiveValues()

  observeEvent(input$d3_update,{
    network$nodes <- unlist(input$d3_update$.pointsData)
  })

  output$pointsOut<-renderTable({data.frame(x=network$nodes)})

  output$d3 <- renderFluidSpline({
    fluidSpline(obj = data.frame(x=1:10,y=runif(10)),cW = 700,cH = 300)
  })
}

ui <- fluidPage(
  column(6,fluidSplineOutput(outputId="d3",width = '1200px',height = '800px')),
  column(6,tableOutput('pointsOut'))
)

shinyApp(ui = ui, server = server)
