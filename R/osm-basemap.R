#' osm_basemap
#'
#' Generates a base OSM plot ready for polygon, line, and point objects to be
#' overlain with \code{\link{add_osm_objects}}. 
#'
#' @param bbox bounding box (Latitude-longitude range) to be plotted.  A 2-by-2
#' matrix of 4 elements with columns of min and max values, and rows of x and y
#' values.
#' @param structures Data frame returned by \code{\link{osm_structures}} used
#' here to specify background colour of plot; if missing, the colour is
#' specified by \code{bg}.
#' @param bg Background colour of map (default = \code{gray20}) only if
#' \code{structs} not given).
#' @return A \code{ggplot2} object containing the base \code{map}.
#' @export
#'
#' @seealso \code{\link{add_osm_objects}}, \code{\link{make_osm_map}}.
#'
#' @examples
#' bbox <- get_bbox (c (-0.13, 51.5, -0.11, 51.52))
#' map <- osm_basemap (bbox=bbox, bg='gray20')
#' map <- add_osm_objects (map, london$dat_BNR, col='gray40') 
#' print_osm_map (map)

osm_basemap <- function (bbox, structures, bg='gray20')
{
    # ---------------  sanity checks and warnings  ---------------
    # ------- bbox
    if (missing (bbox))
        stop ('bbox must be supplied')
    if (!is.numeric (bbox))
        stop ('bbox is not numeric')
    if (length (bbox) < 4)
        stop ('bbox must have length = 4')
    if (length (bbox) > 4)
    {
        warning ('bbox has length > 4; only first 4 elements will be used')
        bbox <- matrix (bbox [1:4], 2, 2)
    }
    # ------- structures
    if (!missing (structures))
    {
        if (!is.data.frame (structures))
            stop ('structures must be a data frame')
        ns <- c ('structure', 'key', 'value', 'suffix', 'cols')
        if (!all (names (structures) == ns))
            stop ('structures not in recognised format')
        bg = structure$cols [which (structures$structure == 'background')]
    }
    # ------- structures
    if (is.null (bg)) stop ('Invalid bg')
    if (length (bg) > 1)
    {
        warning ('bg has length > 1; only first element will be used')
        bg <- bg [1]
    }
    if (is.na (bg)) stop ('Invalid bg')
    tryCatch (
              col2rgb (bg),
              error = function (e) 
              {
                  e$message <-  paste0 ('Invalid bg: ', bg)
                  stop (e)
              })
    # ---------------  end sanity checks and warnings  ---------------

    # Because the initial plot has no data, setting these elements suffices to
    # generate a blank plot area with no margins
    new_theme <- ggplot2::theme_minimal ()
    new_theme$panel.background <- ggplot2::element_rect (fill = bg, size=0)
    new_theme$line <- ggplot2::element_blank ()
    new_theme$axis.text <- ggplot2::element_blank ()
    new_theme$axis.title <- ggplot2::element_blank ()
    new_theme$plot.margin <- ggplot2::margin (rep (ggplot2::unit (0, 'null'), 4))
    new_theme$plot.margin <- ggplot2::margin (rep (ggplot2::unit (-0.5, 'line'), 4))
    new_theme$legend.position <- 'none'
    new_theme$axis.ticks.length <- ggplot2::unit(0,'null')

    lon <- lat <- NA
    # coord_map uses mapproj::mapproject, but I can't add this as a dependency
    # because it's not explicitly called, so coord_equal is a workaround.
    map <- ggplot2::ggplot () + new_theme +
                ggplot2::coord_equal (xlim=range (bbox[1,]), 
                                    ylim=range (bbox[2,])) +
                ggplot2::aes (x=lon, y=lat) +
                ggplot2::scale_x_continuous (expand=c(0, 0)) +
                ggplot2::scale_y_continuous (expand=c(0, 0))

    return (map)
}

