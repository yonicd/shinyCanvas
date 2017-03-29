# fluidSpline

Htmlwidget that binds a fork of [Spline Editor](https://bl.ocks.org/mbostock/4342190) by Mike Bostock to create an interactive object in Shiny. 

For an interactive bl.ock page to try the d3js code go to [here](https://bl.ocks.org/yonicd/4bc59fca901388ebe4905bdb19af1567).

<iframe src="https://vida.io/gists/zNyrLzwmWNQgKGDmd/index.html" seamless frameborder="0" width="968" height="516"></iframe>

<img src="https://raw.githubusercontent.com/yonicd/fluidSpline/master/gifs/fluidSplineExample.gif" "width="300" height="300"/>




The user inputs a data.frame that contains corrdinates x,y and then can:

  - add/remove points to the plot
  - change position of the points
  - change the type of interpolation between points
  - run animation on the interpolated curve to collect a sample from it

## Usage as an htmlwidget in the Rstudio viewer
```
fluidSpline()

fluidSpline(obj = data.frame(x=1:10,y=runif(10)))
```

## Usage in a Shiny app

When run in the Shiny environment, Shiny is observing the points and returns to the server their x,y mapping. So instead of predefining scenarios in simulations you can let the user define the relationship between two variables.

#### Reactive Canvas:
![](https://raw.githubusercontent.com/yonicd/fluidSpline/master/gifs/plotSize.gif)

![](https://raw.githubusercontent.com/yonicd/fluidSpline/master/gifs/fluidSplineRGB.gif)


### Click Pictures to see Youtube Videos

#### Basic Usage:

Script to run example below

[![fluidSpline in Shiny](http://img.youtube.com/vi/obfjcYty7vk/0.jpg)](https://www.youtube.com/watch?v=obfjcYty7vk)

##### Survival Analysis Example:

[![Bivariate Slider in Shiny](http://img.youtube.com/vi/56Ee_2MdptI/0.jpg)](https://www.youtube.com/watch?v=56Ee_2MdptI)

```
library(fluidSpline)
library(shiny)
server <- function(input, output) {

  network <- reactiveValues()

  df<-reactive({
    data.frame(Var1=1:10,Var2=sort(rexp(10),decreasing = T))
  })
  
  observeEvent(input$d3_update,{
    netNodes=input$d3_update$.pointsData
    if(!is.null(netNodes)) network$nodes <- jsonlite::fromJSON(netNodes)
    
    pathNodes=input$d3_update$.pathData
    if(!is.null(pathNodes)) network$path <- jsonlite::fromJSON(pathNodes)
  })

  observeEvent(network$nodes,{
    output$pointsOut<-renderTable({
      dat=network$nodes
      colnames(dat)=names(df())
      dat.df=data.frame(Id=1:nrow(dat),dat)
      dat.df
    })    
  })

  observeEvent(network$path,{
    output$pathOut<-renderTable({
      dat=as.data.frame(network$path)
      colnames(dat)=names(df())
      dat=data.frame(Id=1:nrow(dat),dat)
      dat
    })    
  })
  
  output$d3 <- renderFluidSpline({
    isolate({fluidSpline(obj = df(),
                         opts = list(animate = T,duration=500,pathRadius=10))})
  })
}

ui <- fluidPage(
  column(6,fluidSplineOutput(outputId="d3")),
  column(3,
         p('Plot Points'),
         tableOutput('pointsOut')
         ),
  column(3,
         p('Path Sample'),
         tableOutput('pathOut')
         )
)

shinyApp(ui = ui, server = server)


```
