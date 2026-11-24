#' bst260projhelp: table extraction and bibliographic integrity for PDF reports
#'
#' Two families of tools, bundled together because they recur on the same
#' kind of source document (a long government/NGO report distributed only
#' as PDF):
#'
#' * **Table extraction** (`pdf_*`): recovering structured tables from PDF
#'   pages, either by simple line-based parsing when a table doesn't wrap
#'   (`pdf_read_count_pct_table()`), or by clustering word coordinates when
#'   it does (`pdf_read_table()`, `pdf_read_wide_wrapped_table()`).
#' * **Bibliographic integrity** (`rand_*`, `vancouver_*`): parsing a
#'   report's own reference list, resolving its in-text citations against
#'   that list, and exporting the result as BibTeX or CSL-JSON so it can
#'   be checked, reused or linked. Two citation styles are covered,
#'   matching the two worked examples: `rand_*` for RAND-style per-chapter,
#'   author-year reference lists, `vancouver_*` for numbered
#'   Vancouver-style reference lists.
#'
#' See `vignette("gun-legislation", package = "bst260projhelp")` and
#' `vignette("waterborne-disease", package = "bst260projhelp")` for worked
#' examples on the two bundled reports (see [bst260_example()]).
#'
#' @keywords internal
#' @aliases bst260projhelp-package
"_PACKAGE"
