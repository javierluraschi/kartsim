#' Shiny Widget Output
#' 
#' Provides a Shiny Widget for Output.
#' 
#' @param outputId The identifier for this widget.
#' @param width The width for this widget.
#' @param height The height for this widget.
#' 
#' @examples 
#' library(shiny)
#' 
#' ui <- fluidPage(
#'   tags$head(
#'     tags$style(HTML("
#'       #hexkart {
#'         height: 270px !important;
#'         margin-top: 10px;
#'       }
#'     "))
#'   ),
#'   shiny_pixels_output("hexkart")
#'   textOutput("direction"),
#' )
#' 
#' server <- function(input, output) {
#' hexkart_shiny_render(
#'   hexkart_play(size)
#' )
#' 
#' observeEvent(input$done, {
#'   input$direction <- input$direction
#' })
#' }
#' 
#' if (interactive()) {
#'   shinyApp(ui = ui, server = server)
#' }
#' 
#' @export
hexkart_shiny_output <- function(outputId, width = "100%", height = "100%") {
  shinyWidgetOutput(outputId, "hexkart", width, height, package = "hexkart")
}

#' Shiny Widget Render
#' 
#' Renders the Shiny Widget.
#' 
#' @param expr The \code{expr} for \code{shinyRenderWidget}.
#' @param env The \code{env} for \code{shinyRenderWidget}.
#' @param quoted The \code{quoted} for \code{shinyRenderWidget}.
#' 
#' @seealso [shiny_pixels_output()] for an example of using this function
#' within a 'Shiny' application.
#'   
#' @export
hexkart_shiny_render <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, hexkart_shiny_output, env, quoted = TRUE)
}