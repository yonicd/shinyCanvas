#' @title fluidSpline
#'
#' @description Htmlwidget that allows users to interact with locations of points on a plot
#' 
#' @param obj data.frame that contains coordinates x,y
#' @param cW numeric plot width in px
#' @param cH numeric plot height in px
#'
#' @examples
#' if(interactive()) fluidSpline()
#' @import htmlwidgets
#'
#' @export
fluidSpline <- function(obj=data.frame(x=1:10,y=runif(10)),cW=1000,cH=500, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    data=obj,
    n=nrow(obj),
    width=cW,
    height=cH
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'fluidSpline',
    x,
    width = width,
    height = height,
    package = 'fluidSpline',
    elementId = elementId
  )
}

#' Shiny bindings for fluidSpline
#'
#' Output and render functions for using fluidSpline within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a fluidSpline
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name fluidSpline-shiny
#'
#' @export
fluidSplineOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'fluidSpline', width, height, package = 'fluidSpline')
}

#' @rdname fluidSpline-shiny
#' @export
renderFluidSpline <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, fluidSplineOutput, env, quoted = TRUE)
}
