shinyUI(
  fluidPage(
  sidebarLayout(
    sidebarPanel(
      fluidSplineOutput('d3',width ='300',height='300'),
      sliderInput("B", "Blue Level", min = 0, max = 1, value = 0.5),
      width=6
      
    ),
    mainPanel(plotOutput("distPlot"),width=6)
  )
))