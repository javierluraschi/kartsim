#' Play Simulation
#' 
#' Creates an HTMLWidget to play the simulation.
#' 
#' @param width While capturing, width of capture image.
#' @param height While capturing, height of capture image.
#' @param circuit The circuit index, valid values: 1 or 2.
#' @param discrete Kart steering is discrete?
#' 
#' @examples 
#' 
#' library(kartsim)
#' kartsim_play()
#' 
#' @import htmlwidgets
#' @export
kartsim_play <- function(width = NULL, height = NULL, circuit = 1, discrete = TRUE) {
  
  # forward options using x
  x = list(
    width = width,
    height = height,
    circuit = (circuit - 1),
    discrete = discrete
  )
  
  # create widget
  htmlwidgets::createWidget(
    name = 'kartsim',
    x
  )
}