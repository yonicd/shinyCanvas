shinyUI(
  fluidPage(
  sidebarLayout(
    sidebarPanel(
      fluidSplineOutput('d3',width ='300',height='300'),
      uiOutput('THREE'),
      selectInput('xAxis','Color 1',c('R','G','B'),'R'),
      selectInput('yAxis','Color 2',c('R','G','B'),'G'),
      width=6
      
    ),
    mainPanel(plotOutput("distPlot"),width=6)
  )
))