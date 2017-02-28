# fluidSpline

Htmlwidget that binds [Spline Editor](https://bl.ocks.org/mbostock/4342190) by Mike Bostock to create an interactive object in Shiny. 

![](https://raw.githubusercontent.com/yonicd/fluidSpline/master/fluidSplineExample.gif)


The user inputs a data.frame that contains corrdinates x,y and then can:

  - add/remove points to the plot
  - change position of the points
  - change the type of interpolation between points


##Usage as an htmlwidget in the Rstudio viewer
```
fluidSpline()

fluidSpline(obj = data.frame(x=1:10,y=runif(10)),cW = 700,cH = 300)
```

##Usage in a Shiny app

When run in the Shiny environment, Shiny is observing the points and returns to the server their x,y mapping. So instead of predefining scenarios in simulations you can let the user define how the relationship between two variables should be.

```
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

```