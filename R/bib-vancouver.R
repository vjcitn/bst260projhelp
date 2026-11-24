# Parsing support for reports styled like CDC's WBDOSS surveillance
# summaries: numbered (Vancouver-style) in-text citations "(1)", "(2)",
# resolved against a short numbered "References" list.

#' Parse a numbered Vancouver-style reference list
#'
#' @param pdf_file Path to a PDF file.
#' @param page Integer page number the reference list is on.
#' @param header_label Text of the heading line the list starts under,
#'   e.g. `"References"`.
#' @return A named character vector, names are reference numbers (as
#'   strings), values are the (re-joined, wrapped) entry text. A
#'   continuation line is glued directly onto the previous entry's text
#'   when that text ends mid-URL (no trailing period), otherwise joined
#'   with a space.
#' @export
vancouver_ref_entries <- function(pdf_file, page, header_label = "References") {
  ln <- trimws(strsplit(pdftools::pdf_text(pdf_file)[page], "\n")[[1]])
  ln <- ln[nzchar(ln)]
  i <- which(ln == header_label)
  if (!length(i)) stop("heading '", header_label, "' not found on page ", page)
  ents <- list(); cur <- NULL
  for (l in ln[-seq_len(i)]) {
    m <- regmatches(l, regexec("^([0-9]+)\\.\\s+(.*)$", l))[[1]]
    if (length(m)) { ents[[m[2]]] <- m[3]; cur <- m[2]; next }
    prev <- ents[[cur]]
    ents[[cur]] <- if (grepl("http", prev) && !endsWith(prev, ".")) paste0(prev, l) else paste(prev, l)
  }
  unlist(ents)
}

#' Convert a Vancouver-style author list to BibTeX author form
#'
#' `"Collier SA, Deng L, Adam EA, et al"` becomes
#' `"Collier, S. A. and Deng, L. and Adam, E. A. and others"`.
#'
#' @param s The Vancouver-style author-list string.
#' @return A single BibTeX-ready author string.
#' @export
vancouver_authors <- function(s) {
  others <- grepl(",\\s*et al$", s)
  s <- sub(",\\s*et al$", "", s)
  au <- trimws(strsplit(s, ",")[[1]])
  one <- function(a) {
    tok <- strsplit(a, " ")[[1]]
    fam <- paste(tok[-length(tok)], collapse = " "); ini <- tok[length(tok)]
    sprintf("%s, %s", fam, paste0(strsplit(ini, "")[[1]], ".", collapse = " "))
  }
  paste(c(vapply(au, one, ""), if (others) "others"), collapse = " and ")
}

#' Parse a Vancouver-style journal-article reference
#'
#' Expects the form
#' `"Authors. Title. Journal. YYYY;vol(issue):pages. doi:..."`.
#'
#' @param e The entry text, as from [vancouver_ref_entries()].
#' @param num The reference number (used only in the error message if
#'   parsing fails).
#' @return A list with `type = "article"`, `num`, `author`, `title`,
#'   `journal`, `year`, `volume`, `number`, `pages`, `doi`.
#' @export
vancouver_parse_article <- function(e, num) {
  m <- regmatches(e, regexec(paste0("^(.*?(?:et al)?)\\.\\s+(.*?)\\.\\s+(.*?)\\.\\s+((?:19|20)[0-9]{2});",
                                     "([0-9]+)\\(([^)]*)\\):([0-9-]+)\\.\\s*(?:doi:(\\S+?)\\.?)?$"),
                              e, perl = TRUE))[[1]]
  if (!length(m)) stop("reference ", num, " does not look like a Vancouver journal article:\n", e)
  list(type = "article", num = num,
       author = vancouver_authors(m[2]), title = m[3], journal = m[4], year = m[5],
       volume = m[6], number = m[7], pages = sub("-", "--", m[8]), doi = m[9])
}

#' Parse a Vancouver-style web-page reference
#'
#' Expects the form
#' `"Title. YYYY MM/DD/YYYY [cited YYYY MM/DD]; Available from: URL"`.
#'
#' @param e The entry text, as from [vancouver_ref_entries()].
#' @param num The reference number (used only in the error message if
#'   parsing fails).
#' @return A list with `type = "misc"`, `num`, `title`, `year`, `url`,
#'   `author` (inferred from the URL host when recognizable, else `NA`),
#'   `note`, `urldate`, `annote`.
#' @export
vancouver_parse_web <- function(e, num) {
  m <- regmatches(e, regexec(paste0("^(.*?)\\.\\s+((?:19|20)[0-9]{2})\\s+([0-9]{2}/[0-9]{2}/(?:19|20)[0-9]{2})\\s+",
                                     "\\[cited\\s+((?:19|20)[0-9]{2})\\s+([0-9]{2}/[0-9]{2})\\];\\s+Available from:\\s+(\\S+?)\\.?$"),
                              e, perl = TRUE))[[1]]
  if (!length(m)) stop("reference ", num, " does not look like a Vancouver web page:\n", e)
  upd <- as.Date(m[4], "%m/%d/%Y"); cit <- as.Date(paste(m[5], m[6], sep = "/"), "%Y/%m/%d")
  list(type = "misc", num = num, title = m[2], year = m[3], url = m[7],
       author = if (grepl("epa\\.gov", m[7])) "{U.S. Environmental Protection Agency}" else NA,
       note = sprintf("Page last updated %s", format(upd)), urldate = format(cit),
       annote = "Author inferred from URL host; not stated in the reference list.")
}

#' Export a list of Vancouver-style (plus any hand-curated) entries as BibTeX
#'
#' @param refs A named list of entries, each a list with at least
#'   `type` and the fields `bib_entry()` expects for that type (`author`,
#'   `title`, and for articles `journal`/`volume`/`number`/`pages`, for
#'   techreports/misc `institution`/`address`/`url`/`note`/etc.). Names
#'   are used as BibTeX citation keys.
#' @param accessed A default access date (e.g. `"2026-11-22"`) used as
#'   `urldate` for entries with a `url` or `doi` but no `urldate` of
#'   their own; pass `NA` (the default) to leave `urldate` unset until
#'   you have actually checked the link.
#' @return A single character string of BibTeX entries separated by
#'   blank lines.
#' @export
vancouver_to_bibtex <- function(refs, accessed = NA) {
  one <- function(key, r) {
    doi <- if (!is.null(r$doi) && !is.na(r$doi)) r$doi else NULL
    url <- if (!is.null(doi) && is.null(r$url)) paste0("https://doi.org/", doi) else r$url
    urldate <- if (!is.null(url) || !is.null(doi)) (if (is.null(r$urldate)) accessed else r$urldate) else NULL
    f <- c(author = r$author, title = paste0("{", r$title, "}"), journal = r$journal,
           volume = r$volume, number = r$number, pages = r$pages,
           institution = r$institution, address = r$address, year = r$year,
           doi = doi, url = url, urldate = urldate, note = r$note, annote = r$annote)
    bib_entry(key, r$type, f)
  }
  paste(Map(one, names(refs), refs), collapse = "\n\n")
}

#' Find numbered in-text citations in a PDF, for cross-checking
#'
#' Looks for a word followed by `(N)` or `(N, M)` and punctuation, which
#' is how Vancouver-style citations typically read; deliberately excludes
#' matches like `"Other 1 (2)"` where the preceding token is itself a
#' digit (a table cell, not a citation), by requiring the word before the
#' parenthesis to start with a letter.
#'
#' @param pdf_file Path to a PDF file.
#' @param max_ref Only keep hits whose number(s) are between 1 and
#'   `max_ref`; typically `length(vancouver_ref_entries(...))`.
#' @return A data frame with columns `page`, `cited` (the matched text)
#'   and `numbers` (comma-separated reference numbers). Review the hits
#'   rather than trusting them blindly -- the regex is a heuristic.
#' @export
vancouver_find_numeric_citations <- function(pdf_file, max_ref) {
  txt <- pdftools::pdf_text(pdf_file)
  out <- lapply(seq_along(txt), function(p) {
    flat <- gsub("\\s+", " ", txt[p])
    m <- gregexpr("[A-Za-z]{2,}\\.? ?\\(([0-9]+(?:, ?[0-9]+)*)\\)[.,;]", flat, perl = TRUE)[[1]]
    if (m[1] == -1) return(NULL)
    hit <- regmatches(flat, list(m))[[1]]
    nums <- lapply(strsplit(gsub("^.*\\(([0-9, ]+)\\)[.,;]$", "\\1", hit), ",\\s*"), as.integer)
    keep <- vapply(nums, function(n) all(n >= 1 & n <= max_ref), NA)
    if (!any(keep)) return(NULL)
    data.frame(page = p, cited = hit[keep], numbers = vapply(nums[keep], paste, "", collapse = ","),
               stringsAsFactors = FALSE)
  })
  do.call(rbind, out)
}

.vancouver_html_escape <- function(x) gsub(">", "&gt;", gsub("<", "&lt;", gsub("&", "&amp;", x)))

#' Render a list of Vancouver-style (plus curated) entries as a rendered bibliography
#'
#' Formats each entry as author/title plus its container (journal, with
#' volume/issue/pages, or institution, or a descriptive note) and year,
#' then renders the list with a live DOI link where `doi` is known;
#' failing that, its plain `url` when one is known (true of most of the
#' curated entries -- surveillance systems and reporting forms cited by
#' their web page, not a DOI); and an explicit "no DOI" marker in either
#' case when no DOI was found, including for entries that were never
#' going to have one.
#'
#' @param refs A named list of entries, as passed to
#'   [vancouver_to_bibtex()].
#' @param cited_at A named list, keys matching (a subset of)
#'   `names(refs)`, each value a character vector of anchor ids --
#'   typically from [bib_cite_link()] -- to backlink to. Optional.
#' @return A character vector of HTML lines (an `<ol>`).
#' @export
vancouver_bibliography_html <- function(refs, cited_at = NULL) {
  fmt <- function(r) {
    author <- if (!is.null(r$author) && !is.na(r$author)) paste0(gsub("\\{|\\}", "", r$author), ". ") else ""
    title <- paste0(gsub("\\{|\\}", "", r$title), ". ")
    tail <- if (!is.null(r$journal)) {
      sprintf("%s. %s;%s(%s):%s.", r$journal, r$year, r$volume, r$number, r$pages)
    } else if (!is.null(r$institution)) {
      sprintf("%s%s. %s.", r$institution, if (!is.null(r$address)) paste0(", ", r$address) else "", r$year)
    } else if (!is.null(r$note)) {
      sprintf("%s. %s.", r$note, r$year)
    } else {
      paste0(r$year, ".")
    }
    paste0(author, title, tail)
  }
  text <- .vancouver_html_escape(vapply(refs, fmt, ""))
  doi <- vapply(refs, function(r) if (is.null(r$doi) || is.na(r$doi)) NA_character_ else r$doi, NA_character_)
  url <- vapply(refs, function(r) if (is.null(r$url) || is.na(r$url)) NA_character_ else r$url, NA_character_)
  bib_html_list(names(refs), text, doi, url, cited_at)
}

#' Check that cited URLs are still live
#'
#' Sends a `HEAD` request to every URL in `refs` and reports the HTTP
#' status. Requires network access and the Suggests-only `httr2`
#' package. URLs move -- CDC in particular has reorganized its site more
#' than once -- so a cited page's old path may now redirect or return a
#' stub; a non-404 status is not by itself proof the content is still
#' what was originally cited.
#'
#' @param refs A named list of entries, as passed to
#'   [vancouver_to_bibtex()].
#' @return A data frame with columns `key`, `url`, `status` (`NA` if the
#'   request failed outright).
#' @export
vancouver_check_urls <- function(refs) {
  if (!requireNamespace("httr2", quietly = TRUE)) stop("package 'httr2' is required for vancouver_check_urls()")
  urls <- Filter(Negate(is.null), lapply(refs, `[[`, "url"))
  data.frame(key = names(urls), url = unlist(urls), status = vapply(urls, function(u) {
    tryCatch(httr2::resp_status(httr2::req_perform(httr2::req_method(httr2::request(u), "HEAD"))),
             error = function(e) NA_integer_)
  }, 1L), row.names = NULL)
}
