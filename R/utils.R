#' Show the species name available
#'
#' Show the species name available in each of the three databases of allometric
#' equations.
#'
#' @param dataset From which dataset should we pull the names?
#' @return Character string with the unique species name.
#'
#' @export
show_species <- function(dataset = c('diameter-height',
                                     'diameter-only',
                                     'plot-level')) {

    dataset <- match.arg(dataset)
    allo_df <- switch(
        dataset,
        'diameter-height' = allo_tree_dbh_height,
        'diameter-only' = allo_tree_dbh,
        'plot-level' = allo_plot_basal_area
        )

    return(sort(unique(allo_df$Species)))
}

#' Find match for user-specified species
#'
#' Find the corresponding species in our database of allometric equations.
#'
#' This step is required, as there is no standard on how to write species name.
#' For example, "Spruce, Black", "Black Spruce", and "Black spruce" should all
#' be considered equivalent.
#'
#' To find the best match, we use fuzzy-matching based on the cosine distance
#' between strings (see [stringdist::stringdist]).
#'
#' @param data Data frame containing the tree list.
#' @param species Character. Name of the column of \code{data} containing the
#'   species information.
#' @param dataset Against which database should we match?
#' @return Data frame with two columns, \code{species} and "biomasscan", showing
#'   the matches.
#' @export
match_species_name <- function(data, species,
                               dataset = c('diameter-height',
                                           'diameter-only',
                                           'plot-level')) {

    stopifnot(is.character(species))
    dataset <- match.arg(dataset)

    str_dist <- stringdist::stringdistmatrix(
        stringr::str_remove(tolower(data[[species]]),
                            '[,\\(\\)]'),
        tolower(show_species(dataset = dataset)),
        method = 'cosine'
        )

    matched_spec <- apply(str_dist, 1, \(row) {
        tmp <- which.min(row)
        ifelse(length(tmp), tmp[1], NA)
        })

    out_df <- data.frame(
        'user' = data[[species]],
        'biomasscan' = show_species(dataset = dataset)[matched_spec]
    )

    names(out_df)[1] <- species

    return(dplyr::distinct(out_df))

}
