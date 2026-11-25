# Extract one table from a PDF page by word geometry

A general-purpose table reader for PDFs where
[`pdftools::pdf_text()`](https://docs.ropensci.org/pdftools/reference/pdftools.html)
loses the column structure (wrapped cells, centred headers, rotated
pages). It locates a table by its caption, assigns every word below the
caption to a text line and then to a column, and finally groups lines
into records either by vertical gaps (`record = "gap"`) or by a column
that starts every new record (`record = "anchor"`).

## Usage

``` r
pdf_read_table(
  pdf_file,
  table_id,
  page,
  header_first,
  header_span = c(0, 0),
  edges = NULL,
  centres = NULL,
  record = c("gap", "anchor"),
  anchor_col = NULL,
  stop_pat = "^(NOTE|SOURCE|Note|Source):?$",
  y_max = 650,
  x_min = -Inf,
  x_max = Inf,
  gap_factor = 1.35,
  col_names = NULL
)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- table_id:

  Table identifier as it appears in the caption, e.g. `"2.3"` or
  `"A.6"`.

- page:

  Integer page number the table (or its continuation) is on.

- header_first:

  Regular expression matching the first word of the header line used as
  an anchor, e.g. `"^Study$"`.

- header_span:

  Integer vector `c(lines_above, lines_below)`: how many additional
  lines around the anchor line belong to the header (for multi-line
  headers).

- edges:

  Numeric vector of column left edges relative to the table's leftmost
  word. Mutually exclusive with `centres`.

- centres:

  Numeric vector of absolute column centre x-coordinates. Mutually
  exclusive with `edges`.

- record:

  Either `"gap"` (a new record starts after an unusually large vertical
  gap) or `"anchor"` (a new record starts on every line where column
  `anchor_col` is non-empty).

- anchor_col:

  Integer column index used when `record = "anchor"`.

- stop_pat:

  Regular expression for the first word of a line that ends the table
  body, e.g. a `"NOTE:"` or `"SOURCE:"` line.

- y_max:

  Discard words below this y-coordinate (footers).

- x_min, x_max:

  Discard words outside this x-range; useful on rotated pages where
  running heads and page numbers sit in the margin.

- gap_factor:

  Multiplier applied to the smallest line-to-line vertical gap to decide
  what counts as a "large" gap when `record = "gap"`.

- col_names:

  Optional character vector of output column names; defaults to the
  header text, cleaned with
  [`make.names()`](https://rdrr.io/r/base/make.names.html).

## Value

A data frame, one row per record, one column per detected column, with
an attribute `"header"` holding the raw header text.

## Details

Column boundaries must be supplied one of two ways, matching how the
table is actually typeset:

- `edges`: left edges of left-aligned columns, in points *relative to*
  the table's own leftmost word (so the same spec works across pages
  with different margins).

- `centres`: absolute x centres of centred columns; each word is
  assigned to its nearest centre. Use
  [`pdf_suggest_edges()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_suggest_edges.md)
  to measure candidate values from the page.
