# Export a list of parsed RAND entries as CSL-JSON

CSL-JSON is understood by Zotero and by pandoc's `--citeproc`.

## Usage

``` r
rand_to_csl_json(refs)
```

## Arguments

- refs:

  A list of parsed entries, as from
  [`rand_parse_chapter_refs()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_chapter_refs.md).

## Value

A JSON string (class `json` from
[`jsonlite::toJSON()`](https://rdrr.io/pkg/jsonlite/man/fromJSON.html)).
