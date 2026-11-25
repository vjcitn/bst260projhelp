# Bibliographic integrity for PMC's own HTML rendering of an article:
# a numbered reference list (<li id="CRN">) that already carries direct
# links to each entry's DOI and PubMed record, plus in-text citation
# markers that are themselves real links (<a href="#CRN">) rather than
# plain "(N)" text. Parallel in role to R/bib-rand.R and R/bib-vancouver.R,
# but considerably less parsing is needed: PMC has already done the
# structuring that those two have to recover from plain PDF text.

#' Parse a PMC-style reference list
#'
#' Unlike [vancouver_ref_entries()] (which must locate and glue back
#' together a reference list typeset as plain PDF text), PMC's own
#' reference list is already machine-structured -- each entry is a
#' `<li id="CRN">` holding a formatted `<cite>` plus direct links to its
#' DOI, PubMed and PMC records -- so no text parsing is needed; reading
#' off the right attributes is enough.
#'
#' @param html_file Path or URL to the article's HTML page.
#' @param bib_id The reference list's element id (PMC uses `"Bib1"`).
#' @return A data frame with columns `key` (e.g. `"CR1"`), `num`
#'   (integer), `text` (the formatted reference, plain text), `doi`
#'   (`NA` if none was linked) and `url` (the PubMed link, as a fallback
#'   when there's no DOI; `NA` if neither is present).
#' @export
pmc_ref_entries <- function(html_file, bib_id = "Bib1") {
  doc <- rvest::read_html(html_file)
  bib <- rvest::html_element(doc, paste0("#", bib_id))
  if (is.na(bib)) stop("no element with id '", bib_id, "' found")
  items <- rvest::html_elements(bib, "li")
  key <- rvest::html_attr(items, "id")
  text <- vapply(items, function(li) {
    cite <- rvest::html_element(li, "cite")
    if (is.na(cite)) rvest::html_text2(li) else rvest::html_text2(cite)
  }, "")
  link_href <- function(li, label) {
    a <- rvest::html_elements(li, "a")
    i <- which(rvest::html_text2(a) == label)[1]
    if (is.na(i)) NA_character_ else rvest::html_attr(a[[i]], "href")
  }
  doi_href <- vapply(items, link_href, NA_character_, label = "DOI")
  doi <- ifelse(!is.na(doi_href), sub("^https?://doi\\.org/", "", doi_href), NA_character_)
  pubmed <- vapply(items, link_href, NA_character_, label = "PubMed")
  data.frame(key = key, num = as.integer(sub("^CR", "", key)), text = text,
             doi = doi, url = pubmed, stringsAsFactors = FALSE)
}

#' Find in-text citation links in an article's body
#'
#' PMC's own HTML links every in-text numeric citation marker straight
#' to its reference-list entry (`<a href="#CRN">`), so -- unlike
#' [vancouver_find_numeric_citations()], which must guess at a regex
#' over plain PDF text -- this is a direct structural read: every
#' citation link present is found, with no risk of misreading a table
#' number as a citation or vice versa.
#'
#' @param html_file Path or URL to the article's HTML page.
#' @return A data frame with one row per citation link, columns `para`
#'   (the id of the enclosing paragraph, `NA` if it's not inside one),
#'   `key` (e.g. `"CR1"`) and `label` (the visible marker text, e.g.
#'   `"1"`).
#' @export
pmc_find_citations <- function(html_file) {
  doc <- rvest::read_html(html_file)
  links <- rvest::html_elements(doc, "a[href^='#CR']")
  key <- sub("^#", "", rvest::html_attr(links, "href"))
  label <- rvest::html_text2(links)
  para <- vapply(links, function(a) {
    p <- rvest::html_elements(a, xpath = "ancestor::p[1]")
    if (!length(p)) NA_character_ else rvest::html_attr(p, "id")
  }, NA_character_)
  data.frame(para = para, key = key, label = label, stringsAsFactors = FALSE)
}

.pmc_html_escape <- function(x) gsub(">", "&gt;", gsub("<", "&lt;", gsub("&", "&amp;", x)))

#' Render a PMC reference list as a rendered bibliography
#'
#' A thin wrapper around [bib_html_list()]: PMC's reference entries
#' already come with plain-text, DOI and a fallback URL, so -- unlike
#' [rand_bibliography_html()] and [vancouver_bibliography_html()],
#' which must first format each entry from parsed fields -- there is no
#' formatting step to do first.
#'
#' @param refs A data frame as returned by [pmc_ref_entries()] (or a
#'   subset of its rows).
#' @param cited_at A named list, keys matching (a subset of)
#'   `refs$key`, each value a character vector of anchor ids --
#'   typically from [bib_cite_link()] -- to backlink to. Optional.
#' @return A character vector of HTML lines (an `<ol>`).
#' @export
pmc_bibliography_html <- function(refs, cited_at = NULL) {
  bib_html_list(refs$key, .pmc_html_escape(refs$text), refs$doi, refs$url, cited_at)
}
