#' Compute the biomass of a single tree
#'
#' Using allometric equations, this function estimates the biomass of different
#' tree components using the species, diameter, and (if available) height of the
#' tree.
#'
#' Biomass is estimated for the corresponding tree using the equations published
#' in Lambert *et al* (2005) and Ung *et al* (2008). The estimates are given for
#' four different components of the tree: bark, branches, foliage, and wood.
#'
#' The user must pay special attention to the units of the input data. Heights
#' should be given in meters, while diameters (at breast height) should be given
#' in centimeters.
#'
#' @param height Height of the tree (in meters)
#' @param diameter Diameter of the tree at breast height (in centimeters)
#' @param species Species of the tree
#' @param wide Logical. Should the output be transformed into wide format?
#'   Defaults to \code{FALSE}
#' @return Data frame containing the biomass estimates of the different
#'   components (in kilograms)
#' @export
#' @examples
#' compute_biomass_single_tree(height = 15.2, diameter = 21, species = 'Jack pine')
#' compute_biomass_single_tree(diameter = 21, species = 'Jack pine')
#' # Wide format
#' compute_biomass_single_tree(height = 15.2, diameter = 21, species = 'Jack pine', wide = TRUE)
#' @references Lambert, M.-C., C.-H. Ung, and F. Raulier 2005. Canadian national
#'   biomass equations. Can. J. For. Res 35: 1996-2018.
#' @references Ung, C.-H., Bernier, P., Guo, X.-J. 2008. Canadian national
#'   biomass equations: new parameter estimates that include British Columbia
#'   data. Can. J. For. Res 38:1123-2232.
compute_biomass_single_tree <- function(height, diameter, species,
                                       wide = FALSE) {
    if (diameter <= 0) stop('diameter must be positive')

    if (missing(height)) {
        cmp_diam_only(diameter, species, wide)
    } else {
        cmp_diam_height(height, diameter, species, wide)
    }
}

# biomass_kg = a * diameter^b * height^c
cmp_diam_height <- function(height, diameter, species, wide) {
    if (height <= 0) stop('height must be positive')
    if (!species %in% allo_tree_dbh_height$Species) {
        stop('species is not in the database')
    }

    out_df <- allo_tree_dbh_height |>
        dplyr::filter(Species == species) |>
        dplyr::mutate(biomass = a * diameter^b * height^c) |>
        dplyr::select(-a, -b, -c)

    if (wide) {
        out_df <- tidyr::pivot_wider(out_df,
                                     names_from = Component,
                                     values_from = biomass)
    }

    return(out_df)
}

# biomass_kg = a * diameter^b
cmp_diam_only <- function(diameter, species, wide) {
    if (!species %in% allo_tree_dbh$Species) {
        stop('species is not in the database')
    }

    out_df <- allo_tree_dbh |>
        dplyr::filter(Species == species) |>
        dplyr::mutate(biomass = a * diameter^b) |>
        dplyr::select(-a, -b)

    if (wide) {
        out_df <- tidyr::pivot_wider(out_df,
                                     names_from = Component,
                                     values_from = biomass)
    }

    return(out_df)
}

# Fix no visible binding note
utils::globalVariables(c('Species', 'Component', 'biomass',
                         'a', 'b', 'c'))
