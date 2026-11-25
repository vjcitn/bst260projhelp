# Parse a numbered Vancouver-style reference list

Parse a numbered Vancouver-style reference list

## Usage

``` r
vancouver_ref_entries(pdf_file, page, header_label = "References")
```

## Arguments

- pdf_file:

  Path to a PDF file.

- page:

  Integer page number the reference list is on.

- header_label:

  Text of the heading line the list starts under, e.g. `"References"`.

## Value

A named character vector, names are reference numbers (as strings),
values are the (re-joined, wrapped) entry text. A continuation line is
glued directly onto the previous entry's text when that text ends
mid-URL (no trailing period), otherwise joined with a space.
