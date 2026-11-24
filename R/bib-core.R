#' Escape BibTeX special characters in plain-text fields
#'
#' Backslash-escapes `& % $ # _`. Not applied to fields that are URLs,
#' DOIs or already-braced titles, which must pass through untouched.
#'
#' @param x Character vector.
#' @return Escaped character vector.
#' @export
bib_escape <- function(x) gsub("([&%$#_])", "\\\\\\1", x)

#' Render one BibTeX entry from a key, type and named field vector
#'
#' Fields that are `NA` or empty are dropped. Fields named `url`, `doi`,
#' `urldate`, `title` or `author` are written verbatim (titles and author
#' lists are expected to already carry any brace-protection they need);
#' every other field is passed through [bib_escape()].
#'
#' @param key BibTeX citation key.
#' @param type BibTeX entry type, e.g. `"article"`, `"book"`, `"misc"`.
#' @param fields A named character vector of field values.
#' @return A single string, the formatted `@type{key, ...}` entry.
#' @export
bib_entry <- function(key, type, fields) {
  fields <- fields[!is.na(fields) & nzchar(fields)]
  verbatim <- names(fields) %in% c("url", "doi", "urldate", "title", "author")
  vals <- ifelse(verbatim, fields, bib_escape(fields))
  paste0("@", type, "{", key, ",\n",
         paste(sprintf("  %s = {%s}", names(fields), vals), collapse = ",\n"), "\n}")
}

#' Render a bibliography as an HTML ordered list, with DOI links
#'
#' The single rendering routine both citation styles in this package
#' build on: given a bibliography as parallel vectors of citation keys,
#' already-formatted reference text and DOIs, produce an `<ol>` where
#' each entry that has a DOI links to `https://doi.org/<doi>`, and every
#' other entry is marked, in place, as having no DOI -- rather than
#' silently omitting the link.
#'
#' @param keys Character vector of citation keys, used as each `<li>`'s
#'   `id` (so other output, e.g. [rand_link_citations()] results, can
#'   link to `#<key>`).
#' @param text Character vector of formatted, HTML-escaped reference
#'   text (author/title/container/year as appropriate).
#' @param doi Character vector of DOIs, the same length as `keys`;
#'   `NA` or `""` where no DOI is known.
#' @return A character vector of HTML lines.
#' @export
bib_html_list <- function(keys, text, doi) {
  has_doi <- !is.na(doi) & nzchar(doi)
  mark <- ifelse(has_doi,
                 sprintf(' <a href="https://doi.org/%s">https://doi.org/%s</a>', doi, doi),
                 ' <span class="no-doi"><em>no DOI</em></span>')
  c("<ol>", sprintf('<li id="%s">%s%s</li>', keys, text, mark), "</ol>")
}

#' Write a BibTeX string to file
#'
#' @param bib A character string as produced by [bib_entry()] or one of
#'   the `rand_to_bibtex()` / `vancouver_to_bibtex()` exporters (entries
#'   separated by blank lines).
#' @param path Destination file path.
#' @return `path`, invisibly.
#' @export
write_bib <- function(bib, path) {
  writeLines(bib, path)
  invisible(path)
}
