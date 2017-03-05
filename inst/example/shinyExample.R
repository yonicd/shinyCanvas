library(fluidSpline)
library(shiny)
server <- function(input, output) {

  network <- reactiveValues()

  df<-reactive({
    data.frame(Var1=1:20,Var2=sort(rexp(20),decreasing = T))
  })
  
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

  anim<-reactive({as.logical(input$anim)})
  
  output$d3 <- renderFluidSpline({
    fluidSpline(obj = df(),animate = anim(),cW = 600,cH = 800)
  })
}

ui <- fluidPage(
  column(9,fluidSplineOutput(outputId="d3",width = '600px',height = '600px')),
  radioButtons(inputId = 'anim',label = 'Turn on Animation',choices = c(0,1),selected = 0,inline = T),
  column(3,tableOutput('pointsOut'))
)

shinyApp(ui = ui, server = server)
