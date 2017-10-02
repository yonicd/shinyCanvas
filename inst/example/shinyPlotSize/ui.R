shinyUI(
  fluidPage(
  sidebarLayout(
    sidebarPanel(
      shinyCanvas::canvasOutput('d3',width ='300',height='300'),
      hr(),
      sliderInput("obs", "Number of observations:", 
                  min = 10, max = 500, value = 100),width = 6
    ),
    mainPanel(div(plotOutput("distPlot")),width = 6)
  )
)
)