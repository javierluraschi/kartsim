#' Captures Training
#' 
#' Creates an ShinyGadget to capture training
#' 
#' @param target_path Destination path for captured images.
#' @param width Width of captured image.
#' @param height Height of captured image.
#' 
#' #' @examples 
#' 
#' library(hexkart)
#' if (interactive()) {
#'   hexkart_capture()
#' }
#' 
#' @import shiny
#' @import miniUI
#' @export
hexkart_capture <- function(target_path = "capture", width = 80, height = 40) {
  if (!dir.exists(target_path))
    dir.create(target_path, recursive = TRUE)
  
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
    counter <- reactiveValues(value = 1)
    
    output$hexkart <- hexkart_shiny_render(
      hexkart_play(width, height)
    )
    
    output$label <- renderText({ 
      input$hexkart$direction
    })
    
    observeEvent(input$hexkart, {
      data <- sub("data:image/png;base64,", "", input$hexkart$data)
      base64 <- sub("data:image/png;base64,", "", data)
      raw <- base64enc::base64decode(base64)
      
      writeBin(
        raw,
        file.path(
          target_path,
          sprintf("%s-%05d.png", input$hexkart$direction, counter$value)
        )
      )
      
      counter$value <- counter$value + 1 
    })
    
    observeEvent(input$done, {
      stopApp()
    })
  }
  
  runGadget(ui, server)
}