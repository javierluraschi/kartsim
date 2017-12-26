#' Captures Training
#' 
#' Creates an ShinyGadget to capture training
#' 
#' @param target_path Destination path for captured images.
#' @param width Width of captured image.
#' @param height Height of captured image.
#' @param circuit The circuit index, valid values: 1 or 2.
#' 
#' #' @examples 
#' 
#' library(kartsim)
#' if (interactive()) {
#'   kartsim_capture()
#' }
#' 
#' @import shiny
#' @import miniUI
#' @export
kartsim_capture <- function(target_path = "capture", width = 32, height = 32, circuit = 1) {
  if (!dir.exists(target_path))
    dir.create(target_path, recursive = TRUE)
  
  counter <- 1
  kartsim_control(direction = function(image, direction) {
    writeBin(
      image,
      file.path(
        target_path,
        sprintf("%05d-%s.png", counter, direction)
      )
    )
    
    counter <<- counter + 1
    NULL
  }, width = width, height = height, circuit = circuit)
}