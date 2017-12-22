#' Controls Simulation
#' 
#' Creates an ShinyGadget to control kart in simulation.
#' 
#' @param direction A function \code{function(image, direction) {}} that returns
#'  a direction as string with valid values: \code{"left"},  \code{"forward"} or 
#'  \code{"right"} and which can make use of a raw png \code{image}.
#' @param width Width of captured image.
#' @param height Height of captured image.
#' 
#' #' @examples 
#' 
#' library(hexkart)
#' if (interactive()) {
#'   hexkart_control(function(image) { "right" )
#' }
#' 
#' @import shiny
#' @import miniUI
#' @export
hexkart_control <- function(direction, width = 32, height = 32) {
  if (!is.function(direction))
    stop(
      "The 'direction' parameter must be a 'function(image, direction) {}'",
      "that retruns the new direction: 'left', 'right', 'forward'."
    )
  
  ui <- miniPage(
    gadgetTitleBar("HexKart"),
    miniContentPanel(
      hexkart_shiny_output("hexkart"),
      span(
        textOutput("label"),
        style = "position: absolute; top: 5px; left: 10px; z-index: 100"
      )
    )
  )
  
  server <- function(input, output, session) {
    output$hexkart <- hexkart_shiny_render(
      hexkart_play(width, height)
    )
    
    output$label <- renderText({ 
      input$hexkart_capture$direction
    })
    
    observeEvent(input$hexkart_capture, {
      data <- sub("data:image/png;base64,", "", input$hexkart_capture$data)
      base64 <- sub("data:image/png;base64,", "", data)
      raw <- base64enc::base64decode(base64)
      
      if (!is.null(direction)) {
        direction_change <- direction(raw, input$hexkart_capture$direction)
        if (!is.null(direction_change)) {
          session$sendCustomMessage(type = "hexkart_control", list(
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