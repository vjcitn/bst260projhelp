# Drop a trailing single-letter footnote marker from a string

Many reports mark a cell with a lowercase superscript letter (`a`-`f`)
tied to a footnote; once extracted as plain text that letter rides along
as a lone trailing word. This strips `") x"` down to `")"` for `x` in
`a`-`f`.

## Usage

``` r
pdf_strip_footnote_letter(x)
```

## Arguments

- x:

  Character vector.

## Value

Character vector with trailing footnote letters removed.
