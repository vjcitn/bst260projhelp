# Split the remainder of an unquoted (book/report) entry into title parts

Split the remainder of an unquoted (book/report) entry into title parts

## Usage

``` r
rand_split_title(rest)
```

## Arguments

- rest:

  The part of the entry after the author list.

## Value

A list with `title`, `edition` and `after` (remaining comma-separated
parts: publisher/institution, series, etc.).
