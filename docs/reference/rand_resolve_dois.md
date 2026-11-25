# Resolve DOIs for a list of parsed entries, with an on-disk cache

Resolve DOIs for a list of parsed entries, with an on-disk cache

## Usage

``` r
rand_resolve_dois(refs, mailto, cache = "doi_cache.rds")
```

## Arguments

- refs:

  A list of parsed entries.

- mailto:

  An email address for Crossref's "polite pool".

- cache:

  Path to an RDS file used to cache lookups across calls; entries
  already present are not re-queried.

## Value

The (possibly updated) cache, as a named list keyed by citation key.
