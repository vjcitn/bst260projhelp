# Look up a DOI for a parsed reference entry via Crossref

Requires network access and the Suggests-only `httr2` package. A
candidate match is accepted only if its publication year is within one
year of the entry's year and its title is at least `min_sim` similar
(normalized Levenshtein similarity) – Crossref's bibliographic search is
lenient, so check a sample of results by hand before trusting them in
bulk.

## Usage

``` r
rand_crossref_doi(r, mailto, min_sim = 0.85)
```

## Arguments

- r:

  A parsed entry, as from
  [`rand_parse_entry()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_entry.md).

- mailto:

  An email address to include in the request, per Crossref's "polite
  pool" convention.

- min_sim:

  Minimum title similarity, in `[0, 1]`.

## Value

A DOI string, or `NA_character_` if no match passed, or the entry's type
isn't one Crossref can plausibly index (article, book, incollection).

## Details

A candidate is also rejected if Crossref's own `type` for it doesn't
match what's expected for `r$type` (`"journal-article"` for `article`,
`"book-chapter"`/`"chapter"` for `incollection`, `"monograph"`/`"book"`
for `book`). This matters most for books: Crossref indexes many book
*reviews* whose title is just the book's own title, which would
otherwise look like a near-perfect title match while actually being the
wrong, unrelated work.
