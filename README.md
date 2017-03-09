# fluidSpline

Htmlwidget that binds a fork of [Spline Editor](https://bl.ocks.org/mbostock/4342190) by Mike Bostock to create an interactive object in Shiny. 


<iframe src="https://bl.ocks.org/yonicd/raw/4bc59fca901388ebe4905bdb19af1567/" marginwidth="0" marginheight="0" scrolling="no"></iframe>


![](https://raw.githubusercontent.com/yonicd/fluidSpline/master/fluidSplineAnimation.gif)

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

When run in the Shiny environment, Shiny is observing the points and returns to the server their x,y mapping. So instead of predefining scenarios in simulations you can let the user define the relationship between two variables.

Click Picture to see Youtube Video

[![fluidSpline in Shiny](http://img.youtube.com/vi/obfjcYty7vk/0.jpg)](https://www.youtube.com/watch?v=obfjcYty7vk)

```
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

```
