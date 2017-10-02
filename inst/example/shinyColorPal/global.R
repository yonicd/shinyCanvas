library(shiny)
library(viridis)
library(shinyCanvas)
library(dplyr)

data=data.frame(x=1:1000,y=1:1000)

concaveman <- function(d){
  library(V8)
  ctx <- v8()
  ctx$source('https://www.mapbox.com/bites/00222/concaveman-bundle.js')
  jscode <- sprintf(
    "var points = %s;var polygon = concaveman(points);", 
    jsonlite::toJSON(d, dataframe = 'values')
  )
  ctx$eval(jscode)
  setNames(as.data.frame(ctx$get('polygon')), names(d))
}

rhull <- function(n,x) {
  boundary <- x[chull(x),]
  #boundary <- concaveman(x)
  
  xlim <- range(boundary[,1])
  ylim <- range(boundary[,2])
  
  boundary <- rbind(c(NA,NA), boundary)  # add space for new test point
  
  result <- matrix(NA, n, 2)
  
  for (i in 1:n) {
    repeat {
      boundary[1,1] <- runif(1, xlim[1], xlim[2])
      boundary[1,2] <- runif(1, ylim[1], ylim[2])
      if ( !(1 %in% chull(boundary))) {
        result[i,] <- boundary[1,]
        break
      }
    }
  }
  
  result
}