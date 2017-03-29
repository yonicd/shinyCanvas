library(shiny)
library(viridis)
library(fluidSpline)
library(dplyr)

rhull <- function(n,x) {
  boundary <- x[chull(x),]
  
  xlim <- range(boundary[,1])
  ylim <- range(boundary[,2])
  
  boundary <- rbind(c(NA,NA), boundary)  # add space for new test point
  
  result <- matrix(NA, n, 2)
  
  for (i in 1:n) {
    repeat {
      boundary[1,1] <- runif(1, xlim[1], xlim[2])
      boundary[1,2] <- runif(1, ylim[1], ylim[2])
      if ( !(1 %in% chull(boundary)) ) {
        result[i,] <- boundary[1,]
        break
      }
    }
  }
  
  result
}