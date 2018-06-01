#' Controls Simulation
#' 
#' Creates an ShinyGadget to control kart in simulation.
#' 
#' @param direction A function \code{function(image, angle) {}} that returns
#'  a direction angle as numeric and which can make use of a raw png \code{image}.
#' @param width Width of captured image.
#' @param height Height of captured image.
#' @param circuit The circuit index, valid values: 1, 2 or 3.
#' @param discrete Discrete control of direction? Discrete control expects
#'   the \code{direction} function to return a character string: left, right or
#'   forward. Otherwise, it will expect a numeric value with the steering angle.
#' 
#' #' @examples 
#' 
#' library(kartsim)
#' if (interactive()) {
#'   kartsim_control(function(image) "right")
#' }
#' 
#' @import shiny
#' @import miniUI
#' @export
kartsim_control <- function(
  direction,
  width = 32,
  height = 32,
  circuit = 1,
  discrete = TRUE
  ) {
  if (!is.function(direction))
    stop(
      "The 'direction' parameter must be a 'function(image, angle) {}'",
      "that retruns the new numeric direction [-1, 1]."
    )
  
  ui <- miniPage(
    gadgetTitleBar("KartSim"),
    miniContentPanel(
      kartsim_shiny_output("kartsim"),
      span(
        textOutput("label"),
        style = "position: absolute; top: 5px; left: 10px; z-index: 100"
      )
    )
  )
  
  server <- function(input, output, session) {
    output$kartsim <- kartsim_shiny_render(
      kartsim_play(width, height, circuit, discrete)
    )
    
    output$label <- renderText({ 
      input$kartsim_capture$angle
    })
    
    observeEvent(input$kartsim_capture, {
      data <- sub("data:image/png;base64,", "", input$kartsim_capture$data)
      base64 <- sub("data:image/png;base64,", "", data)
      raw <- base64enc::base64decode(base64)
      
      if (!is.null(direction)) {
        angle <- input$kartsim_capture$angle

        if (discrete) {
          if (angle < 0) angle <- "left"
          else if (angle > 0) angle <- "right"
          else angle <- "forward"
        }
        
        direction_change <- direction(raw, angle)
        
        if (discrete && !is.null(direction_change)) {
          if (direction_change == "left") direction_change <- -5
          else if (direction_change == "right") direction_change <- 5
          else direction_change <- 0
        }
        
        if (!is.null(direction_change)) {
          session$sendCustomMessage(type = "kartsim_control", list(
            angle = direction_change
          ))
        }
      }
    })
    
    observeEvent(input$done, {
      stopApp()
    })
  }
  
  runGadget(ui, server)
}