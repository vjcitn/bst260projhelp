# Check that cited URLs are still live

Sends a `HEAD` request to every URL in `refs` and reports the HTTP
status. Requires network access and the Suggests-only `httr2` package.
URLs move – CDC in particular has reorganized its site more than once –
so a cited page's old path may now redirect or return a stub; a non-404
status is not by itself proof the content is still what was originally
cited.

## Usage

``` r
vancouver_check_urls(refs)
```

## Arguments

- refs:

  A named list of entries, as passed to
  [`vancouver_to_bibtex()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_to_bibtex.md).

## Value

A data frame with columns `key`, `url`, `status` (`NA` if the request
failed outright).
