#' Controls Simulation
#' 
#' Creates an ShinyGadget to control kart in simulation.
#' 
#' @param direction A function \code{function(image, direction) {}} that returns
#'  a direction as string with valid values: \code{"left"},  \code{"forward"} or 
#'  \code{"right"} and which can make use of a raw png \code{image}.
#' @param width Width of captured image.
#' @param height Height of captured image.
#' @param circuit The circuit index, valid values: 1 or 2.
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
kartsim_control <- function(direction, width = 32, height = 32, circuit = 1) {
  if (!is.function(direction))
    stop(
      "The 'direction' parameter must be a 'function(image, direction) {}'",
      "that retruns the new direction: 'left', 'right', 'forward'."
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
      kartsim_play(width, height, circuit)
    )
    
    output$label <- renderText({ 
      input$kartsim_capture$direction
    })
    
    observeEvent(input$kartsim_capture, {
      data <- sub("data:image/png;base64,", "", input$kartsim_capture$data)
      base64 <- sub("data:image/png;base64,", "", data)
      raw <- base64enc::base64decode(base64)
      
      if (!is.null(direction)) {
        direction_change <- direction(raw, input$kartsim_capture$direction)
        if (!is.null(direction_change)) {
          session$sendCustomMessage(type = "kartsim_control", list(
            direction = direction_change
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