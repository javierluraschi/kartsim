#' Play Simulation
#' 
#' Creates an HTMLWidget to play the simulation.
#' 
#' @param width While capturing, width of capture image.
#' @param height While capturing, height of capture image.
#' 
#' @examples 
#' 
#' library(hexkart)
#' show_pixels(
#'   round(runif(400, 0, 1)),
#'   grid = c(40, 10),
#'   size = c(800, 200),
#'   params = list(fill = list(color = "#FF3388"))
#' )
#' 
#' @import htmlwidgets
#' @export
hexkart_play <- function(width = NULL, height = NULL) {
  
  # forward options using x
  x = list(
    width = width,
    height = height
  )
  
  # create widget
  htmlwidgets::createWidget(
    name = 'hexkart',
    x
  )
}