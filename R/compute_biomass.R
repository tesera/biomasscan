#' Compute the biomass of a tree list
#'
#' Using allometric equations, this function estimates the biomass of different
#' tree components using the species, diameter, and (if available) height of the
#' tree.
#'
#' Biomass is estimated for the corresponding tree using the equations published
#' in Lambert *et al* (2005) and Ung *et al* (2008). The estimates are given for
#' four different components of the tree: bark, branches, foliage, and wood. If
#' \code{total = TRUE} (which is the default), the output also contains the
#' total biomass (i.e. adding up all four components).
#'
#' The user must pay special attention to the units of the input data. Heights
#' should be given in meters, while diameters (at breast height) should be given
#' in centimeters.
#'
#' @param data Data frame containing the tree list.
#' @param height Character. Name of the column of \code{data} containing the
#'   height information.
#' @param diameter Character. Name of the column of \code{data} containing the
#'   diameter information.
#' @param species Character. Name of the column of \code{data} containing the
#'   species information.
#' @param total Logical. Should the output also contain the total biomass?
#'   Defaults to \code{TRUE}
#' @return Data frame containing the biomass estimates of the trees in
#'   \code{data} for different components (in kilograms), along with all other
#'   columns of \code{data}.
#' @export
#' @examples
#' test_df <- data.frame(
#'     'spec' = c("Jack pine", "Trembling aspen", "Black spruce",
#'                "Black spruce", "Eucaplyptus"),
#'     'diam' = c(21.0, 32.1, 31.0, 21.0, 14.0),
#'     'ht' = c(15.2, 28.0, 22.6, 20.8, 10.2)
#' )
#' compute_biomass(test_df, species = 'spec', diameter = 'diam',
#'                 height = 'ht')
#' # Using diameters only
#' compute_biomass(test_df, species = 'spec', diameter = 'diam')
#' @references Lambert, M.-C., C.-H. Ung, and F. Raulier 2005. Canadian national
#'   biomass equations. Can. J. For. Res 35: 1996-2018.
#' @references Ung, C.-H., Bernier, P., Guo, X.-J. 2008. Canadian national
#'   biomass equations: new parameter estimates that include British Columbia
#'   data. Can. J. For. Res 38:1123-2232.
compute_biomass <- function(data, species, diameter, height,
                            total = TRUE) {

    diam_only <- missing(height)

    stopifnot(is.character(diameter),
              is.character(species))

    if (diam_only) {
        allo_df <- allo_tree_dbh
    } else {
        allo_df <- allo_tree_dbh_height
        stopifnot(is.character(height))
    }

    join_by <- c('Species')
    names(join_by) <- species

    in_df <- dplyr::mutate(data, .id_tree = dplyr::row_number())

    out_df <- in_df |>
        dplyr::left_join(allo_df,
                         by = join_by,
                         relationship = 'many-to-many')

    if (diam_only) {
        out_df <- out_df |>
            dplyr::mutate(biomass = a * .data[[diameter]]^b) |>
            dplyr::select(-a, -b)
    } else {
        out_df <- out_df |>
            dplyr::mutate(biomass = a * .data[[diameter]]^b *
                              .data[[height]]^c) |>
            dplyr::select(-a, -b, -c)
    }

    out_df <- out_df |>
        dplyr::filter(!is.na(biomass)) |>
        tidyr::pivot_wider(names_from = Component,
                           values_from = biomass,
                           id_cols = .id_tree,
                           values_fill = 0.0)

    if (total) {
        out_df <- dplyr::mutate(
            out_df,
            Total = Bark + Branches + Foliage + Wood
            )
    }

    out_df <- in_df |>
        dplyr::left_join(out_df, by = '.id_tree') |>
        dplyr::select(-.id_tree)

    return(out_df)
}

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
#' compute_biomass_single_tree(species = 'Jack pine', diameter = 21, height = 15.2)
#' compute_biomass_single_tree(species = 'Jack pine', diameter = 21)
#' # Wide format
#' compute_biomass_single_tree(species = 'Jack pine', diameter = 21, height = 15.2, wide = TRUE)
#' @references Lambert, M.-C., C.-H. Ung, and F. Raulier 2005. Canadian national
#'   biomass equations. Can. J. For. Res 35: 1996-2018.
#' @references Ung, C.-H., Bernier, P., Guo, X.-J. 2008. Canadian national
#'   biomass equations: new parameter estimates that include British Columbia
#'   data. Can. J. For. Res 38:1123-2232.
compute_biomass_single_tree <- function(species, diameter, height,
                                        wide = FALSE) {
    stopifnot(is.character(species))
    if (diameter <= 0) stop('diameter must be positive')

    if (missing(height)) {
        cmp_diam_only(species, diameter, wide)
    } else {
        cmp_diam_height(species, diameter, height, wide)
    }
}

# biomass_kg = a * diameter^b * height^c
cmp_diam_height <- function(species, diameter, height, wide) {
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
cmp_diam_only <- function(species, diameter, wide) {
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

# Fix no visible binding note----
utils::globalVariables(c('Species', 'Component', 'biomass',
                         'a', 'b', 'c', '.id_tree',
                         '.data', 'Bark', 'Branches',
                         'Foliage', 'Wood'))
