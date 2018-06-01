#' Captures Training
#' 
#' Creates an ShinyGadget to capture training.
#' 
#' Your left and right arrow keys can be used to capture discrete turns. To
#' perform continuous turns use instead the keys: 'a', 's', 'd', 'f' and
#' 'h', 'j', 'k', 'l'.
#' 
#' @param target_path Destination path for captured images.
#' @param width Width of captured image.
#' @param height Height of captured image.
#' @param circuit The circuit index, valid values: 1, 2 or 3.
#' @param discrete Discrete capture of direction? Discrete capture produces images
#'   labeled: left, right or forward. Otherwise, it will produce continuous
#'   labels with a steering angle appended.
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
kartsim_capture <- function(
  target_path = "capture",
  width = 32,
  height = 32,
  circuit = 1,
  discrete = TRUE) {
  if (!dir.exists(target_path))
    dir.create(target_path, recursive = TRUE)
  
  counter <- 1
  kartsim_control(direction = function(image, angle) {
    writeBin(
      image,
      file.path(
        target_path,
        if (discrete)
          sprintf("%05d-%s.png", counter, angle)
        else {
          label <- ifelse(angle > 0, "right", ifelse(angle == 0, "forward", "left"))
          sprintf("%05d-%s-%i.png", counter, label, abs(angle))
        }
      )
    )
    
    counter <<- counter + 1
    NULL
  }, width = width, height = height, circuit = circuit, discrete = discrete)
}