library(fluidSpline)
library(shiny)
server <- function(input, output) {

  network <- reactiveValues()

  observeEvent(input$d3_update,{
    network$nodes <- unlist(input$d3_update$.pointsData)
  })

  output$pointsOut<-renderTable({
    dat=matrix(network$nodes,ncol=2,byrow = T)
    dat.df=data.frame(Id=1:nrow(dat),dat)
    names(dat.df)=c('Id','X','Y')
    dat.df
    })

  output$d3 <- renderFluidSpline({
    fluidSpline(obj = data.frame(x=1:10,y=runif(10)),cW = 500,cH = 300)
  })
}

ui <- fluidPage(
  column(9,fluidSplineOutput(outputId="d3",width = '1000px',height = '800px')),
  column(3,tableOutput('pointsOut'))
)

shinyApp(ui = ui, server = server)
