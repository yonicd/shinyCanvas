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
      colnames(dat)=names(df())
      dat.df=data.frame(Id=1:nrow(dat),dat)
      dat.df
    })    
  })

df<-reactive({
  data.frame(Var1=1:10,Var2=sort(rexp(10),decreasing = T))
})
  output$d3 <- renderFluidSpline({
    isolate({fluidSpline(obj = df(),cW =     600,cH = 300)})
  })
}

ui <- fluidPage(
  column(9,fluidSplineOutput(outputId="d3",width = '600px',height = '600px')),
  column(3,tableOutput('pointsOut'))
)

shinyApp(ui = ui, server = server)
