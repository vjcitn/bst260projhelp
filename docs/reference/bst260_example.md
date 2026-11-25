# Path to a bundled example PDF

Path to a bundled example PDF

## Usage

``` r
bst260_example(file = NULL)
```

## Arguments

- file:

  Base name of a file under `inst/extdata`; omit to list the available
  files.

## Value

A file path (if `file` is given) or a character vector of available file
names (if it is omitted).

## Examples

``` r
bst260_example()
#> [1] "2021_Annual_Waterborne_Disease_Surveillance_Report.pdf"
#> [2] "PMC13794488.html"                                      
#> [3] "gunpolicy_ch18_dois.rds"                               
#> [4] "scienceOfGunPolicy.pdf"                                
bst260_example("2021_Annual_Waterborne_Disease_Surveillance_Report.pdf")
#> [1] "/private/var/folders/yw/gfhgh7k565v9w83x_k764wbc0000gp/T/Rtmpcx8yyT/temp_libpath7a47d5ec0a1/bst260projhelp/extdata/2021_Annual_Waterborne_Disease_Surveillance_Report.pdf"
```
