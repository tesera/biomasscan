
<!-- README.md is generated from README.Rmd. Please edit this file -->

# biomasscan

<!-- badges: start -->
<!-- badges: end -->

The goal of `biomasscan` is to provide an easy, programmatic way of
computing biomass from a tree list. The functions of this package were
designed to mimic the functionality of Natural Resources Canada’s online
tool, available
[here](https://apps-scf-cfs.rncan.gc.ca/calc/en/biomass-calculator).

## Installation

You can install the development version of `biomasscan` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tesera/biomasscan")
```

## Example

Biomass can be estimated for a single tree, by passing the relevant
attributes. For example, for a Jack pine, 15.2 meters tall and with a
diameter of 21 centimeters at breast height, we get:

``` r
library(biomasscan)

compute_biomass_single_tree(height = 15.2, diameter = 21, 
                            species = 'Jack pine')
#> # A tibble: 4 × 3
#>   Species   Component biomass
#>   <chr>     <chr>       <dbl>
#> 1 Jack pine Bark         9.29
#> 2 Jack pine Branches    14.2 
#> 3 Jack pine Foliage      7.51
#> 4 Jack pine Wood       101.
```

As we can see, we get estimates of biomass (in kilograms) for four
different components. We can turn this into a wide dataset by passing
`wide = TRUE`:

``` r
compute_biomass_single_tree(height = 15.2, diameter = 21, 
                            species = 'Jack pine', wide = TRUE)
#> # A tibble: 1 × 5
#>   Species    Bark Branches Foliage  Wood
#>   <chr>     <dbl>    <dbl>   <dbl> <dbl>
#> 1 Jack pine  9.29     14.2    7.51  101.
```

We can also get the biomass estimates for a whole tree list:

``` r
library(tibble)

test_df <- tribble(
    ~spec, ~diam, ~ht,
    'Jack pine', 21, 15.2,
    'Trembling aspen', 32.1, 28,
    'Black spruce', 31, 22.6,
    'Black spruce', 21, 20.8,
    'Eucaplyptus', 14, 10.2
)

test_df
#> # A tibble: 5 × 3
#>   spec             diam    ht
#>   <chr>           <dbl> <dbl>
#> 1 Jack pine        21    15.2
#> 2 Trembling aspen  32.1  28  
#> 3 Black spruce     31    22.6
#> 4 Black spruce     21    20.8
#> 5 Eucaplyptus      14    10.2

compute_biomass(test_df, species = 'spec', diameter = 'diam', 
                height = 'ht')
#> # A tibble: 5 × 8
#>   spec             diam    ht  Bark Branches Foliage  Wood Total
#>   <chr>           <dbl> <dbl> <dbl>    <dbl>   <dbl> <dbl> <dbl>
#> 1 Jack pine        21    15.2  9.29     14.2    7.51  101.  132.
#> 2 Trembling aspen  32.1  28   78.1      43.9    7.36  402.  531.
#> 3 Black spruce     31    22.6 34.3      32.8   20.0   282.  369.
#> 4 Black spruce     21    20.8 16.5      10.6    8.29  132.  167.
#> 5 Eucaplyptus      14    10.2 NA        NA     NA      NA    NA
```

## References

- Lambert, M.-C., C.-H. Ung, and F. Raulier (2005). *Canadian national
  biomass equations*. Can. J. For. Res 35: 1996-2018.
- Ung, C.-H., Bernier, P., Guo, X.-J. (2008). *Canadian national biomass
  equations: new parameter estimates that include British Columbia
  data*. Can. J. For. Res 38:1123-2232.
