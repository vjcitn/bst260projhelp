# rvest-based scraping of PMC/JATS-derived HTML article pages. Generalized
# from one worked example -- the stroke-mortality paper bundled as
# "PMC13794488.html" -- the same way R/pdftab-core.R was generalized from
# this package's two PDFs, but nothing here is specific to that one paper:
# it reads the standard citation_* meta-tag scheme and PMC's own element-id
# conventions (TabN/FigN/AbsN sections), which hold across PMC articles.

#' Extract standard scholarly metadata from an article's `<meta>` tags
#'
#' Reads the `citation_*` meta tags (the Highwire Press/Google Scholar
#' convention most journal publishing platforms, including PMC, emit in
#' every article's `<head>`), rather than anything specific to one paper.
#'
#' @param html_file Path or URL to the article's HTML page.
#' @return A list with `title`, `journal`, `authors` (character vector,
#'   one per `citation_author` tag), `doi`, `pmid`, `date`, `volume`,
#'   `firstpage`.
#' @export
html_article_meta <- function(html_file) {
  doc <- rvest::read_html(html_file)
  one <- function(name) {
    v <- rvest::html_attr(rvest::html_elements(doc, sprintf('meta[name="%s"]', name)), "content")
    if (!length(v)) NA_character_ else v[1]
  }
  many <- function(name) rvest::html_attr(rvest::html_elements(doc, sprintf('meta[name="%s"]', name)), "content")
  list(title = one("citation_title"), journal = one("citation_journal_title"),
       authors = many("citation_author"), doi = one("citation_doi"),
       pmid = one("citation_pmid"), date = one("citation_publication_date"),
       volume = one("citation_volume"), firstpage = one("citation_firstpage"))
}

#' Index of an article's tables, by element id
#'
#' PMC wraps each table in a `<section id="TabN">` carrying its own
#' number (`.obj_head`) and caption (`.caption`) -- this lists all of
#' them, so a table's id can be looked up before reading it with
#' [html_read_table()], just as [pdf_table_index()] does for PDF tables.
#'
#' @param html_file Path or URL to the article's HTML page.
#' @return A data frame with columns `id`, `label` (e.g. `"Table 1."`)
#'   and `caption`.
#' @export
html_table_index <- function(html_file) {
  doc <- rvest::read_html(html_file)
  secs <- rvest::html_elements(doc, "[id^='Tab']")
  text_of <- function(s, sel) { e <- rvest::html_element(s, sel); if (is.na(e)) NA_character_ else rvest::html_text2(e) }
  data.frame(id = rvest::html_attr(secs, "id"),
             label = vapply(secs, text_of, "", sel = ".obj_head"),
             caption = vapply(secs, text_of, "", sel = ".caption"),
             stringsAsFactors = FALSE)
}

#' Read one table from an article as a data frame
#'
#' Drills down to the actual `<table>` element before calling
#' [rvest::html_table()] -- calling it directly on the enclosing
#' wrapper (PMC wraps each table together with its caption) produces
#' nonsensical single-column pseudo-tables rather than erroring.
#'
#' @param html_file Path or URL to the article's HTML page.
#' @param id The table's element id, e.g. `"Tab1"` (as listed by
#'   [html_table_index()]).
#' @return A data frame (tibble, if the tibble package is available).
#' @export
html_read_table <- function(html_file, id) {
  doc <- rvest::read_html(html_file)
  wrap <- rvest::html_element(doc, paste0("#", id))
  if (is.na(wrap)) stop("no element with id '", id, "' found")
  tab <- rvest::html_element(wrap, "table")
  if (is.na(tab)) stop("element '", id, "' has no <table> inside it")
  rvest::html_table(tab)
}

#' Extract a figure's caption text
#'
#' @param html_file Path or URL to the article's HTML page.
#' @param id The figure's element id, e.g. `"Fig1"`.
#' @return A single string, or `NA` if the figure has no caption.
#' @export
html_figure_caption <- function(html_file, id) {
  doc <- rvest::read_html(html_file)
  wrap <- rvest::html_element(doc, paste0("#", id))
  if (is.na(wrap)) stop("no element with id '", id, "' found")
  cap <- rvest::html_element(wrap, "figcaption, .caption")
  if (is.na(cap)) NA_character_ else rvest::html_text2(cap)
}

#' Extract a figure's image URL
#'
#' Reads the `<img>` element's `src` (and `alt`) directly, rather than
#' downloading the image -- PMC serves figures from its own CDN, so the
#' URL alone is enough to display or re-cite the figure. This package
#' does not vendor the pixels: reusing a figure, even from an
#' open-access article, is a licensing decision (see the article's own
#' licence statement) that belongs to whoever embeds it, not to this
#' extraction step.
#'
#' @param html_file Path or URL to the article's HTML page.
#' @param id The figure's element id, e.g. `"Fig1"`.
#' @return A list with `src` (the image URL) and `alt` (alt text, `NA`
#'   if none was given).
#' @export
html_figure_image <- function(html_file, id) {
  doc <- rvest::read_html(html_file)
  wrap <- rvest::html_element(doc, paste0("#", id))
  if (is.na(wrap)) stop("no element with id '", id, "' found")
  img <- rvest::html_element(wrap, "img")
  if (is.na(img)) stop("element '", id, "' has no <img> inside it")
  list(src = rvest::html_attr(img, "src"), alt = rvest::html_attr(img, "alt"))
}

#' Extract an article's structured abstract
#'
#' @param html_file Path or URL to the article's HTML page.
#' @param id The abstract section's element id (PMC uses `"Abs1"`).
#' @return A named character vector, names are subsection headings
#'   (e.g. `"Background"`, `"Methods"`), values the subsection text; or,
#'   if the abstract has no subheadings, a single unnamed string.
#' @export
html_abstract <- function(html_file, id = "Abs1") {
  doc <- rvest::read_html(html_file)
  sec <- rvest::html_element(doc, paste0("#", id))
  if (is.na(sec)) stop("no element with id '", id, "' found")
  subs <- rvest::html_elements(sec, "section:has(h3.pmc_sec_title)")
  if (!length(subs)) return(rvest::html_text2(sec))
  head_of <- function(s) rvest::html_text2(rvest::html_element(s, "h3.pmc_sec_title"))
  body_of <- function(s) paste(rvest::html_text2(rvest::html_elements(s, "p")), collapse = " ")
  out <- vapply(subs, body_of, "")
  names(out) <- vapply(subs, head_of, "")
  out
}
