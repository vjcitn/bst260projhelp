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
#' silently omitting the link. When a plain `url` is also known (often
#' true even when no DOI is), it's rendered as a second, explicitly
#' labeled link alongside the "no DOI" marker, rather than dropped.
#'
#' Each `<li>` gets `id = key`, so in-text citations can link down to
#' their entry with [bib_cite_link()]. If `cited_at` names one or more
#' anchor ids per key (by convention, the ids [bib_cite_link()] sets),
#' each entry also gets an "up" backlink to every one of its citing
#' locations -- so a reader can jump from the bibliography back to
#' where a source was actually used, not just from the citation down to
#' the source.
#'
#' @param keys Character vector of citation keys, used as each `<li>`'s
#'   `id` (so other output, e.g. [rand_link_citations()] results, can
#'   link to `#<key>`).
#' @param text Character vector of formatted, HTML-escaped reference
#'   text (author/title/container/year as appropriate).
#' @param doi Character vector of DOIs, the same length as `keys`;
#'   `NA` or `""` where no DOI is known.
#' @param url Character vector of plain URLs, the same length as
#'   `keys`; `NA` or `""` where none is known. Optional.
#' @param cited_at A named list, keys matching (a subset of) `keys`,
#'   each value a character vector of anchor ids to backlink to.
#'   Optional.
#' @return A character vector of HTML lines.
#' @export
bib_html_list <- function(keys, text, doi, url = NA_character_, cited_at = NULL) {
  if (length(url) == 1) url <- rep(url, length(keys))
  has_doi <- !is.na(doi) & nzchar(doi)
  has_url <- !is.na(url) & nzchar(url)
  doi_mark <- ifelse(has_doi,
                      sprintf(' <a href="https://doi.org/%s">https://doi.org/%s</a>', doi, doi),
                      ' <span class="no-doi"><em>no DOI</em></span>')
  url_mark <- ifelse(has_url & !has_doi,
                      sprintf(' (<a href="%s">%s</a>)', url, url), "")
  back <- if (is.null(cited_at)) "" else vapply(keys, function(k) {
    ids <- cited_at[[k]]
    if (!length(ids)) "" else paste0(" ", paste(sprintf('<a href="#%s" class="backlink">&uarr;</a>', ids),
                                                  collapse = " "))
  }, "")
  c("<ol>", sprintf('<li id="%s">%s%s%s%s</li>', keys, text, doi_mark, url_mark, back), "</ol>")
}

#' Link in-text to a bibliography entry, with a round-trip backlink
#'
#' Produces an HTML anchor pointing down to the entry `key` (rendered by
#' [bib_html_list()] with `id = key`), and carries its own `id` so that
#' entry can link back up to this exact citing location. Pass the same
#' id(s) via `cited_at` in [bib_html_list()] to get a live "up" link on
#' the entry; use a distinct `id` for a second citation of the same key
#' (e.g. `paste0("cite-", key, "-2")`) and list both under that key in
#' `cited_at`.
#'
#' @param key Bibliography entry key to link to.
#' @param label Visible link text; defaults to `key`.
#' @param id Anchor id for this citing location; defaults to
#'   `paste0("cite-", key)`.
#' @return A character vector of HTML strings, the same length as `key`.
#' @export
bib_cite_link <- function(key, label = key, id = paste0("cite-", key)) {
  sprintf('<a id="%s" href="#%s">%s</a>', id, key, label)
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
