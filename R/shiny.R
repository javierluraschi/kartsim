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
#'       #kartsim {
#'         height: 270px !important;
#'         margin-top: 10px;
#'       }
#'     "))
#'   ),
#'   kartsim_shiny_output("kartsim"),
#'   textOutput("angle")
#' )
#' 
#' server <- function(input, output) {
#' kartsim_shiny_render(
#'   kartsim_play(size)
#' )
#' 
#' observeEvent(input$done, {
#'   input$angle <- input$angle
#' })
#' }
#' 
#' if (interactive()) {
#'   shinyApp(ui = ui, server = server)
#' }
#' 
#' @export
kartsim_shiny_output <- function(outputId, width = "100%", height = "100%") {
  shinyWidgetOutput(outputId, "kartsim", width, height, package = "kartsim")
}

#' Shiny Widget Render
#' 
#' Renders the Shiny Widget.
#' 
#' @param expr The \code{expr} for \code{shinyRenderWidget}.
#' @param env The \code{env} for \code{shinyRenderWidget}.
#' @param quoted The \code{quoted} for \code{shinyRenderWidget}.
#' 
#' @seealso [kartsim_shiny_output()] for an example of using this function
#' within a 'Shiny' application.
#'   
#' @export
kartsim_shiny_render <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, kartsim_shiny_output, env, quoted = TRUE)
}