#' @title Htmlwidget reactive canvas
#'
#' @description Creates a htmlwidget that shows a two dimensional interactive space with 
#' data points with an interpolation can be fit. Points can be moved, added and removed,
#' and interpolation updates automatically. The main objective is to create a new object 
#' for Shiny that represents a functional slider extending the one dimensional
#'  \code{\link[shiny]{sliderInput}}.
#' @param obj \code{data.frame} that contains coordinates x,y
#' @param ... options to pass to widget, see details
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param elementId The input slot that will be used to access the element.
#'    
#' @details When deployed in Shiny the location of points and location of 
#' anitmation is observed by Shiny. This information is used as a reactive 
#' elements to control other input/ui objects. It is also possible to sample 
#' from the interpolation function, as a function of the interpolate and ease
#' settings.
#' 
#' Options to pass to canvas via \strong{...} :
#' 
#' \strong{animate}: boolean, turns on animation, Default: FALSE 
#' 
#' \strong{duration}: numeric, duration which is the speed which the animation moves, Default: 10000 (ms)
#' 
#' \strong{loop}: boolean, automatically restarts the animation when it reaches the end, Default: True
#' 
#' \strong{ease}: character, function that controls how the animation progresses, Default: 'quadInOut' 
#' 
#' \strong{interpolate}: character, initial interpolation function to apply, Default: 'linear'
#' 
#' \strong{pathRadius}: numeric, set the size of the circle that moves along the interpolated curve, Default: 10
#' 
#' \strong{selectLabel}: boolean, controls if the dropdown select is shown, Default: TRUE
#' 
#' \strong{xlim,ylim}: numeric, limits to pass to x/y-axis, Default: NULL
#' 
#' \strong{x_angle}: numeric, angle to rotate x axis tick labels, Default: NULL
#' 
#' \href{https://bl.ocks.org/emmasaunders/f7178ed715a601c5b2c458a2c7093f78}{interpolation options}: (
#'   "linear","linear-closed",
#'   "step-before","step-after",
#'   "basis","basis-open","basis-closed",
#'   "cardinal","cardinal-open","cardinal-closed",
#'   "bundle",
#'   "monotone")
#'   
#' \href{https://bl.ocks.org/mbostock/248bac3b8e354a9103c4}{ease options}: (
#' "linear",
#' "quadIn","quadOut","quadInOut",
#' "cubicIn","cubicOut","cubicInOut",
#' "polyIn","polyOut","polyInOut",
#' "sinIn","sinOut","sinInOut",
#' "expIn","expOut","expInOut",
#' "circleIn","circleOut","circleInOut",
#' "bounceIn","bounceOut","bounceInOut",
#' "backIn","backOut","backInOut",
#' "elasticIn","elasticOut","elasticInOut")
#'
#' @examples
#' 
#' if(interactive()){
#' 
#' set.seed(123)
#' 
#' dat <- data.frame(x=1:10,y=sort(rexp(10,rate = 2),decreasing = TRUE))
#' 
#' canvas(obj=dat,animate=TRUE,duration=1000,interpolate='basis')
#' } 
#' 
#' @import htmlwidgets
#'
#' @export
canvas <- function(obj, ... , width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    data=obj,
    n=nrow(obj)
  )
  
  opts <- list(...)
  
  if(length(opts)>0){
    nm=names(opts)
    for(i in nm) x[[i]]=opts[[i]]
  }

  # create widget
  htmlwidgets::createWidget(
    name = 'canvas',
    x,
    width = width,
    height = height,
    package = 'shinyCanvas',
    elementId = elementId
  )
}

#' Shiny bindings for canvas
#'
#' Output and render functions for using canvas within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a canvas
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name canvas-shiny
#'
#' @export
canvasOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId = outputId,name =  'canvas', width, height, package = 'shinyCanvas')
}

#' @rdname canvas-shiny
#' @export
renderCanvas <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr = expr, outputFunction = canvasOutput, env, quoted = TRUE)
}
