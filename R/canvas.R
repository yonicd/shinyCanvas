#' @title a title
#'
#' @description a description.
#' @param obj data.frame that contains coordinates x,y
#' @param opts opttions to pass to widget, see details
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#'   
#' @details options to pass to server side includes:animation, animation duration, animation ease, animation radius,
#'   duration which is the speed which the animation moves (default 10000ms). 
#' When deploying a shiny app the number of samples taken from the path is a function of the size of the duration.
#' and loop if set to TRUE (default FALSE) automatically restarts the animation when it reaches the end.
#' pathRadius set the size of the circle that moves along the interpolated curve.
#'
#' @examples
#' if(interactive()) canvas(obj=data.frame(x=1:10,y=runif(10)))
#' 
#' @import htmlwidgets
#'
#' @export
canvas <- function(obj, opts=NULL, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    data=obj,
    n=nrow(obj)
  )
  
  if(!is.null(opts)){
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
