# Parse a PMC-style reference list

Unlike
[`vancouver_ref_entries()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_ref_entries.md)
(which must locate and glue back together a reference list typeset as
plain PDF text), PMC's own reference list is already machine-structured
– each entry is a `<li id="CRN">` holding a formatted `<cite>` plus
direct links to its DOI, PubMed and PMC records – so no text parsing is
needed; reading off the right attributes is enough.

## Usage

``` r
pmc_ref_entries(html_file, bib_id = "Bib1")
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

- bib_id:

  The reference list's element id (PMC uses `"Bib1"`).

## Value

A data frame with columns `key` (e.g. `"CR1"`), `num` (integer), `text`
(the formatted reference, plain text), `doi` (`NA` if none was linked)
and `url` (the PubMed link, as a fallback when there's no DOI; `NA` if
neither is present).
