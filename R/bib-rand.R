# Parsing support for reports styled like RAND's "The Science of Gun
# Policy": no master bibliography, each chapter ends with its own
# "Chapter N References" list in RAND style (not author-year), and
# in-text citations are author-year, e.g. "Lott and Mustard (1997)".

#' Locate a chapter's reference-list pages
#'
#' @param pdf_file Path to a PDF file.
#' @param chapter Integer chapter number.
#' @return A named integer vector `c(start, end)`: the PDF page holding
#'   `"Chapter <chapter> References"` and the page where the next
#'   chapter's `"CHAPTER <chapter+1>"` heading begins.
#' @export
rand_chapter_ref_pages <- function(pdf_file, chapter) {
  txt <- pdftools::pdf_text(pdf_file)
  start <- which(vapply(txt, function(p) any(grepl(sprintf("^\\s*Chapter %d References\\s*$", chapter),
                                                     strsplit(p, "\n")[[1]])), NA, USE.NAMES = FALSE))[1]
  end <- which(vapply(txt, function(p) any(grepl(sprintf("^\\s*CHAPTER %d\\s*$", chapter + 1),
                                                   strsplit(p, "\n")[[1]])), NA, USE.NAMES = FALSE))
  end <- end[end > start][1]
  c(start = start, end = end)
}

#' Extract a chapter's reference-list lines, with running heads removed
#'
#' @param pdf_file Path to a PDF file.
#' @param chapter Integer chapter number.
#' @param chapter_title The chapter's running-head title text, e.g.
#'   `"Concealed-Carry Laws"`, so it can be filtered out.
#' @return Character vector of reference-list lines, in order.
#' @export
rand_chapter_ref_lines <- function(pdf_file, chapter, chapter_title) {
  pg <- rand_chapter_ref_pages(pdf_file, chapter)
  txt <- pdftools::pdf_text(pdf_file)[pg["start"]:pg["end"]]
  out <- character(0); started <- FALSE
  for (page in txt) for (l in trimws(strsplit(page, "\n")[[1]])) {
    if (!nzchar(l)) next
    if (grepl(sprintf("^Chapter %d References$", chapter), l)) { started <- TRUE; out <- character(0); next }
    if (!started) next
    if (grepl(sprintf("^CHAPTER %d$", chapter + 1), l)) return(out)
    if (grepl("^The Science of Gun Policy", l) || l == chapter_title || grepl("^[0-9]+$", l)) next
    out <- c(out, l)
  }
  out
}

#' Split reference-list lines into individual entries
#'
#' An entry is taken to be complete when its last line ends with a
#' period (that isn't a mid-name initial like `"D."`) or is a bare URL;
#' the next entry starts where a line beginning with a capital letter
#' follows a completed one. Hyphenated line-end breaks are rejoined.
#'
#' @param lines Character vector as returned by [rand_chapter_ref_lines()].
#' @return Character vector, one re-joined string per reference entry.
#' @export
rand_split_entries <- function(lines) {
  ents <- list(); cur <- character(0)
  for (l in lines) {
    prev <- if (length(cur)) cur[length(cur)] else ""
    closed <- (endsWith(prev, ".") && !grepl("(^|\\s)[A-Z]\\.$", prev)) || grepl("^https?://\\S+$", prev)
    if (length(cur) && closed && grepl("^[A-Z]", l)) { ents[[length(ents) + 1]] <- cur; cur <- character(0) }
    cur <- c(cur, l)
  }
  if (length(cur)) ents[[length(ents) + 1]] <- cur
  vapply(ents, function(e) {
    s <- e[1]
    for (l in e[-1]) s <- if (endsWith(s, "-")) paste0(s, l) else paste(s, l)
    s
  }, "")
}

.rand_suffix <- "(Jr\\.|Sr\\.|II|III|IV)"
.rand_months <- "January|February|March|April|May|June|July|August|September|October|November|December"

#' Parse a RAND-style author list into one row per author
#'
#' Handles `"Last, First, and First Last"` style lists: the first author
#' is `"Family, Given"`, later authors are `"First Last"`.
#'
#' @param seg The author segment of a reference entry.
#' @return A data frame with columns `family`, `given`, `suffix`, one
#'   row per author.
#' @export
rand_parse_names <- function(seg) {
  parts <- trimws(strsplit(gsub("\\s+", " ", sub(",\\s*$", "", trimws(seg))), ",")[[1]])
  parts <- parts[nzchar(parts)]
  if (length(parts) == 1) return(data.frame(family = parts, given = "", suffix = "", stringsAsFactors = FALSE))
  fam <- parts[1]; giv <- parts[2]; suf <- ""; i <- 3
  if (i <= length(parts) && grepl(paste0("^", .rand_suffix, "$"), parts[i])) { suf <- parts[i]; i <- i + 1 }
  while (i <= length(parts)) {
    p <- sub("^and\\s+", "", parts[i]); i <- i + 1; s <- ""
    if (i <= length(parts) && grepl(paste0("^", .rand_suffix, "$"), parts[i])) { s <- parts[i]; i <- i + 1 }
    m <- regmatches(p, regexec(paste0("^(.*)\\s+", .rand_suffix, "$"), p))[[1]]
    if (length(m)) { p <- m[2]; s <- m[3] }
    tok <- strsplit(p, " ")[[1]]
    fam <- c(fam, tok[length(tok)]); giv <- c(giv, paste(tok[-length(tok)], collapse = " ")); suf <- c(suf, s)
  }
  data.frame(family = fam, given = giv, suffix = suf, stringsAsFactors = FALSE)
}

#' Split the remainder of an unquoted (book/report) entry into title parts
#'
#' @param rest The part of the entry after the author list.
#' @return A list with `title`, `edition` and `after` (remaining
#'   comma-separated parts: publisher/institution, series, etc.).
#' @export
rand_split_title <- function(rest) {
  rest <- sub("\\s*(As of |https?://).*$", "", rest)
  parts <- trimws(strsplit(rest, ",")[[1]])
  j <- which(grepl(":", parts))[1]; if (is.na(j)) j <- 1
  title <- paste(parts[seq_len(j)], collapse = ", ")
  after <- if (j < length(parts)) parts[(j + 1):length(parts)] else character(0)
  ed <- after[grepl("^[0-9]+(st|nd|rd|th) ed\\.?$", after)]
  after <- after[!after %in% ed & !grepl("^(19|20)[0-9]{2}[a-z]?\\.?$", after)]
  after <- sub("\\.$", "", after)
  k <- which(grepl("^(Inc|Ltd|LLC)$", after))
  for (i in rev(k)) { after[i - 1] <- paste(after[i - 1], after[i], sep = ", "); after <- after[-i] }
  list(title = title, edition = sub("\\.$", "", ed[1]), after = after)
}

#' Parse one RAND-style reference entry into structured fields
#'
#' Distinguishes quoted titles (article / incollection) from unquoted
#' titles (book / techreport / misc) and extracts authors, title,
#' container, volume/issue, publisher or institution, year and a
#' same-year disambiguation suffix (`"1998a"`), plus any URL.
#'
#' @param e A single reference-entry string, as produced by
#'   [rand_split_entries()].
#' @return A list of parsed fields: `raw`, `type`, `authors` (data
#'   frame), `title`, `container`, `volume`, `number`, `month`,
#'   `publisher`, `institution`, `edition`, `note`, `url`, `doi`, `year`,
#'   `suffix`.
#' @export
rand_parse_entry <- function(e) {
  r <- list(raw = e, type = "misc", title = NA, container = NA, volume = NA, number = NA,
            month = NA, publisher = NA, institution = NA, edition = NA, note = NA, url = NA,
            doi = NA, year = "", suffix = "")
  r$url <- regmatches(e, regexpr("https?://\\S+", e)); if (!length(r$url)) r$url <- NA
  asof <- regmatches(e, regexpr("As of [^:]+", e)); if (length(asof)) r$note <- asof

  q <- regmatches(e, regexec("^(.*?),?\\s+\u201C(.+?)(?:,\u201D|\u201D,?|\\.\u201D)\\s*(.*)$", e, perl = TRUE))[[1]]
  if (length(q)) {
    auth <- q[2]; r$title <- sub(",$", "", q[3]); rest <- q[4]
    r$authors <- if (grepl(",", auth)) rand_parse_names(auth) else
      data.frame(family = auth, given = "", suffix = "", stringsAsFactors = FALSE)
    if (grepl("^in\\s", rest)) {
      r$type <- "incollection"
      st <- rand_split_title(sub("^in .*?eds?\\.,\\s*", "", rest))
      r$container <- st$title; r$publisher <- st$after[1]
    } else {
      mj <- regmatches(rest, regexec(paste0("^(.*?),\\s*(?:Vol\\.|No\\.|(?:", .rand_months, ")\\b|(?:19|20)[0-9]{2})"),
                                      rest, perl = TRUE))[[1]]
      if (length(mj) && !grepl("webpage|working paper|report", mj[2], ignore.case = TRUE)) {
        r$type <- "article"; r$container <- mj[2]
      }
    }
  } else {
    parts <- trimws(strsplit(e, ",")[[1]])
    k <- which(startsWith(parts, "and "))[1]
    if (!is.na(k)) {
      auth <- paste(parts[1:k], collapse = ", "); rest <- paste(parts[-(1:k)], collapse = ", ")
      r$authors <- rand_parse_names(auth)
    } else if (length(parts) > 2 && grepl("^[A-Z][a-z]+( [A-Z]\\.?| [A-Z][a-z]+)*$", parts[2]) &&
               length(strsplit(parts[2], " ")[[1]]) <= 3 && !grepl("Press|Council|Corporation", parts[1])) {
      n <- if (grepl(paste0("^", .rand_suffix, "$"), parts[3])) 3 else 2
      auth <- paste(parts[1:n], collapse = ", "); rest <- paste(parts[-(1:n)], collapse = ", ")
      r$authors <- rand_parse_names(auth)
    } else {
      auth <- parts[1]; rest <- paste(parts[-1], collapse = ", ")
      r$authors <- data.frame(family = auth, given = "", suffix = "", stringsAsFactors = FALSE)
    }
    st <- rand_split_title(rest); r$title <- st$title; r$edition <- st$edition
    if (grepl("Press|Publishing|Publishers", rest)) { r$type <- "book"; r$publisher <- st$after[1] }
    else if (grepl("[Ww]orking [Pp]aper|Institute|Center|Corporation|Law School|University", rest)) {
      r$type <- "techreport"; r$institution <- st$after[1]
      extra <- st$after[-1]; extra <- extra[!grepl(paste0("^(", .rand_months, ")"), extra)]
      if (length(extra)) r$note <- paste(c(r$note[!is.na(r$note)], extra), collapse = "; ")
    }
  }
  yr_src <- sub("\\s*(As of |https?://).*$", "", rest)
  ym <- regmatches(yr_src, gregexpr("(?:19|20)[0-9]{2}[a-z]?\\b", yr_src, perl = TRUE))[[1]]
  if (length(ym)) { y <- ym[length(ym)]; r$year <- substr(y, 1, 4); r$suffix <- substring(y, 5) }
  mv <- regmatches(e, regexec("Vol\\.\\s*([^,]+)", e))[[1]]; if (length(mv)) r$volume <- trimws(mv[2])
  mn <- regmatches(e, regexec("No\\.\\s*([^,]+)", e))[[1]]; if (length(mn) && r$type == "article") r$number <- trimws(mn[2])
  mm <- regmatches(rest, regexpr(.rand_months, rest)); if (r$type == "article" && length(mm)) r$month <- mm
  r
}

#' Citation key for a parsed RAND reference entry
#'
#' Built as surname(s) + year + disambiguation letter, e.g.
#' `"LottMustard1997"`, `"Lott1998a"`, `"MoodyEtAl2014"`.
#'
#' @param r A parsed entry, as returned by [rand_parse_entry()].
#' @return A single character string.
#' @export
rand_ref_key <- function(r) {
  fam <- gsub("[^A-Za-z]", "", r$authors$family)
  base <- if (length(fam) <= 2) paste(fam, collapse = "") else paste0(fam[1], "EtAl")
  paste0(base, r$year, r$suffix)
}

#' Parse an entire chapter's reference list into keyed entries
#'
#' Convenience wrapper chaining [rand_chapter_ref_lines()],
#' [rand_split_entries()] and [rand_parse_entry()], and assigning a
#' unique citation key (via [rand_ref_key()], de-duplicated with
#' [make.unique()]) to each entry.
#'
#' @param pdf_file Path to a PDF file.
#' @param chapter Integer chapter number.
#' @param chapter_title The chapter's running-head title text.
#' @return A list of parsed entries (see [rand_parse_entry()]), each with
#'   an added `key` element.
#' @export
rand_parse_chapter_refs <- function(pdf_file, chapter, chapter_title) {
  lines <- rand_chapter_ref_lines(pdf_file, chapter, chapter_title)
  refs <- lapply(rand_split_entries(lines), rand_parse_entry)
  keys <- make.unique(vapply(refs, rand_ref_key, ""), sep = "_")
  for (i in seq_along(refs)) refs[[i]]$key <- keys[i]
  refs
}

#' Flatten a list of parsed RAND entries into a data frame
#'
#' @param refs A list of parsed entries as returned by
#'   [rand_parse_chapter_refs()].
#' @return A data frame with one row per entry: `key`, `type`, `year`,
#'   `title`, `container`, `volume`, `number`, `publisher`, `institution`,
#'   `url`, `doi`, `first_author`, `n_authors`, `raw`.
#' @export
rand_refs_table <- function(refs) {
  do.call(rbind, lapply(refs, function(r) data.frame(
    key = r$key, type = r$type, year = r$year, title = r$title, container = r$container,
    volume = r$volume, number = r$number, publisher = r$publisher, institution = r$institution,
    url = r$url, doi = r$doi, first_author = r$authors$family[1], n_authors = nrow(r$authors),
    raw = r$raw, stringsAsFactors = FALSE)))
}

#' Resolve author-year in-text citations to reference keys
#'
#' Handles `"A (1999)"`, `"A and B (1999)"`, `"A, B, and C (1999)"`,
#' `"A et al. (2020)"`, and semicolon-separated lists of these such as
#' `"Lott (1998a, 1998b, 2000); Lott and Whitley (2003)"`.
#'
#' @param s A single in-text citation string.
#' @return A character vector of reference keys, one per
#'   semicolon-separated citation (with multiple years in one citation
#'   expanded to multiple keys).
#' @export
rand_cite_keys <- function(s) {
  s <- gsub("\\)\\s+[a-f](?=$|;)", ")", trimws(s), perl = TRUE)
  unlist(lapply(strsplit(s, ";\\s*")[[1]], function(piece) {
    m <- regmatches(piece, regexec("^(.*?)\\s*\\(([^)]*)\\)", piece, perl = TRUE))[[1]]
    if (!length(m)) return(NA_character_)
    who <- m[2]; yrs <- trimws(strsplit(m[3], ",")[[1]])
    surname <- function(n) gsub("[^A-Za-z]", "", utils::tail(strsplit(trimws(n), " ")[[1]], 1))
    base <- if (grepl(" et al", who)) paste0(surname(sub(" et al.*$", "", who)), "EtAl") else {
      nm <- strsplit(who, ",\\s*and\\s+|\\s+and\\s+|,\\s*", perl = TRUE)[[1]]; nm <- nm[nzchar(nm)]
      if (length(nm) <= 2) paste(vapply(nm, surname, ""), collapse = "") else paste0(surname(nm[1]), "EtAl")
    }
    paste0(base, yrs)
  }))
}

#' Resolve a vector of in-text citation strings to reference entries
#'
#' General form for tables where a cell may hold several citations; one
#' output row per (input string, resolved key) pair.
#'
#' @param strings Character vector of in-text citation strings.
#' @param refs A reference table, as from [rand_refs_table()].
#' @return A data frame with `row` (index into `strings`), `cited_as`,
#'   `cite_key` (as parsed), `bib_key`, `reference` (raw text), `doi`,
#'   `url`.
#' @export
rand_resolve_citations <- function(strings, refs) {
  out <- do.call(rbind, lapply(seq_along(strings), function(i) {
    k <- rand_cite_keys(strings[i])
    data.frame(row = i, cited_as = strings[i], cite_key = k, stringsAsFactors = FALSE)
  }))
  j <- match(out$cite_key, refs$key)
  out$bib_key <- refs$key[j]; out$reference <- refs$raw[j]; out$doi <- refs$doi[j]; out$url <- refs$url[j]
  out
}

#' Link one citation column of a table to reference entries
#'
#' The common case of [rand_resolve_citations()]: exactly one citation
#' per row, in column `col` of `tab`.
#'
#' @param tab A data frame with a citation column.
#' @param col Name of the citation column.
#' @param refs A reference table, as from [rand_refs_table()].
#' @return `tab` with added columns `cite_key`, `bib_key`, `reference`,
#'   `doi`, `url`.
#' @export
rand_link_citations <- function(tab, col, refs) {
  tab$cite_key <- vapply(tab[[col]], function(s) rand_cite_keys(s)[1], "")
  j <- match(tab$cite_key, refs$key)
  tab$bib_key <- refs$key[j]
  tab$reference <- refs$raw[j]
  tab$doi <- refs$doi[j]
  tab$url <- refs$url[j]
  tab
}

.rand_bib_names <- function(a) paste(ifelse(nzchar(a$suffix),
                                             sprintf("%s, %s, %s", a$family, a$suffix, a$given),
                                             ifelse(nzchar(a$given), sprintf("%s, %s", a$family, a$given),
                                                    sprintf("{%s}", a$family))), collapse = " and ")

#' Export a list of parsed RAND entries as BibTeX
#'
#' @param refs A list of parsed entries, as from [rand_parse_chapter_refs()]
#'   (or a subset of one).
#' @return A single character string of BibTeX entries separated by
#'   blank lines.
#' @export
rand_to_bibtex <- function(refs) {
  one <- function(r) {
    f <- switch(r$type,
      article      = c(journal = r$container, volume = r$volume, number = r$number, month = r$month),
      book         = c(publisher = r$publisher, edition = r$edition),
      techreport   = c(institution = r$institution),
      incollection = c(booktitle = r$container, publisher = r$publisher),
      misc         = c())
    f <- c(author = .rand_bib_names(r$authors), title = paste0("{", r$title, "}"), f,
           year = r$year, url = r$url, doi = r$doi, note = r$note)
    bib_entry(r$key, r$type, f)
  }
  paste(vapply(refs, one, ""), collapse = "\n\n")
}

.rand_csl_type <- c(article = "article-journal", book = "book", techreport = "report",
                     incollection = "chapter", misc = "webpage")

#' Export a list of parsed RAND entries as CSL-JSON
#'
#' CSL-JSON is understood by Zotero and by pandoc's `--citeproc`.
#'
#' @param refs A list of parsed entries, as from [rand_parse_chapter_refs()].
#' @return A JSON string (class `json` from [jsonlite::toJSON()]).
#' @export
rand_to_csl_json <- function(refs) {
  items <- lapply(refs, function(r) {
    it <- list(id = r$key, type = unname(.rand_csl_type[r$type]), title = r$title,
               author = lapply(seq_len(nrow(r$authors)), function(i) {
                 a <- r$authors[i, ]
                 if (nzchar(a$given)) Filter(nzchar, list(family = a$family, given = a$given, suffix = a$suffix))
                 else list(literal = a$family) }),
               issued = list(`date-parts` = list(list(as.integer(r$year)))),
               `container-title` = r$container, volume = r$volume, issue = r$number,
               publisher = if (!is.na(r$publisher)) r$publisher else r$institution,
               URL = r$url, DOI = r$doi, note = r$note)
    Filter(function(x) !(length(x) == 1 && is.na(x)), it)
  })
  jsonlite::toJSON(items, auto_unbox = TRUE, pretty = TRUE)
}

#' Look up a DOI for a parsed reference entry via Crossref
#'
#' Requires network access and the Suggests-only `httr2` package. A
#' candidate match is accepted only if its publication year is within
#' one year of the entry's year and its title is at least `min_sim`
#' similar (normalized Levenshtein similarity) -- Crossref's bibliographic
#' search is lenient, so check a sample of results by hand before
#' trusting them in bulk.
#'
#' A candidate is also rejected if Crossref's own `type` for it doesn't
#' match what's expected for `r$type` (`"journal-article"` for `article`,
#' `"book-chapter"`/`"chapter"` for `incollection`, `"monograph"`/`"book"`
#' for `book`). This matters most for books: Crossref indexes many book
#' *reviews* whose title is just the book's own title, which would
#' otherwise look like a near-perfect title match while actually being
#' the wrong, unrelated work.
#'
#' @param r A parsed entry, as from [rand_parse_entry()].
#' @param mailto An email address to include in the request, per
#'   Crossref's "polite pool" convention.
#' @param min_sim Minimum title similarity, in `[0, 1]`.
#' @return A DOI string, or `NA_character_` if no match passed, or the
#'   entry's type isn't one Crossref can plausibly index (article, book,
#'   incollection).
#' @export
rand_crossref_doi <- function(r, mailto, min_sim = 0.85) {
  compatible_type <- switch(r$type,
    article      = "journal-article",
    incollection = c("book-chapter", "chapter"),
    book         = c("monograph", "book"),
    NA_character_)
  if (length(compatible_type) == 1 && is.na(compatible_type)) return(NA_character_)
  if (!requireNamespace("httr2", quietly = TRUE)) stop("package 'httr2' is required for rand_crossref_doi()")
  norm <- function(x) gsub("[^a-z0-9]", "", tolower(x))
  title_sim <- function(a, b) { a <- norm(a); b <- norm(b); 1 - utils::adist(a, b)[1, 1] / max(nchar(a), nchar(b)) }
  q <- paste(r$title, r$authors$family[1], r$year)
  resp <- httr2::request("https://api.crossref.org/works") |>
    httr2::req_url_query(`query.bibliographic` = q, rows = 5, mailto = mailto,
                          select = "DOI,title,issued,type") |>
    httr2::req_retry(max_tries = 3) |> httr2::req_perform() |> httr2::resp_body_json()
  for (it in resp$message$items) {
    t <- if (length(it$title)) it$title[[1]] else ""
    y <- tryCatch(it$issued$`date-parts`[[1]][[1]], error = function(e) NA)
    if (!is.na(y) && abs(y - as.integer(r$year)) <= 1 && title_sim(t, r$title) >= min_sim &&
        it$type %in% compatible_type) return(it$DOI)
  }
  NA_character_
}

#' Resolve DOIs for a list of parsed entries, with an on-disk cache
#'
#' @param refs A list of parsed entries.
#' @param mailto An email address for Crossref's "polite pool".
#' @param cache Path to an RDS file used to cache lookups across calls;
#'   entries already present are not re-queried.
#' @return The (possibly updated) cache, as a named list keyed by
#'   citation key.
#' @export
rand_resolve_dois <- function(refs, mailto, cache = "doi_cache.rds") {
  have <- if (file.exists(cache)) readRDS(cache) else list()
  for (r in refs) if (is.null(have[[r$key]])) { have[[r$key]] <- rand_crossref_doi(r, mailto); Sys.sleep(0.2) }
  saveRDS(have, cache)
  have
}

.rand_html_escape <- function(x) gsub(">", "&gt;", gsub("<", "&lt;", gsub("&", "&amp;", x)))

#' Render a list of parsed RAND entries as a rendered bibliography
#'
#' Each entry is shown as its raw reference-list text, with a live link
#' to its DOI (field `doi`, e.g. as filled in by [rand_resolve_dois()])
#' when one is known, and an explicit "no DOI" marker otherwise.
#'
#' @param refs A list of parsed entries (see [rand_parse_entry()]), such
#'   as a subset of [rand_parse_chapter_refs()] output.
#' @return A character vector of HTML lines (an `<ol>`).
#' @export
rand_bibliography_html <- function(refs) {
  keys <- vapply(refs, `[[`, "", "key")
  text <- .rand_html_escape(vapply(refs, `[[`, "", "raw"))
  doi <- vapply(refs, function(r) if (is.null(r$doi) || is.na(r$doi)) NA_character_ else r$doi, NA_character_)
  bib_html_list(keys, text, doi)
}
