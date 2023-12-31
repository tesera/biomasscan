% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{match_species_name}
\alias{match_species_name}
\title{Find match for user-specified species}
\usage{
match_species_name(
  data,
  species,
  dataset = c("diameter-height", "diameter-only", "plot-level")
)
}
\arguments{
\item{data}{Data frame containing the tree list.}

\item{species}{Character. Name of the column of \code{data} containing the
species information.}

\item{dataset}{Against which database should we match?}
}
\value{
Data frame with two columns, \code{species} and "biomasscan", showing
the matches.
}
\description{
Find the corresponding species in our database of allometric equations.
}
\details{
This step is required, as there is no standard on how to write species name.
For example, "Spruce, Black", "Black Spruce", and "Black spruce" should all
be considered equivalent.

To find the best match, we use fuzzy-matching based on the cosine distance
between strings (see \link[stringdist:stringdist]{stringdist::stringdist}).
}
