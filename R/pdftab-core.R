#' Per-page word coordinates for a PDF, with convenience columns
#'
#' Thin, cached wrapper around [pdftools::pdf_data()]. Adds `x2` (right
#' edge), `yc` (vertical centre) and `cx` (horizontal centre) to each
#' page's word data frame, which [pdf_read_table()] relies on for
#' clustering words into lines and columns.
#'
#' Results are cached per PDF path for the life of the R session, because
#' a single document is usually queried for several tables in a row and
#' `pdf_data()` re-parses the whole file every time it is called.
#'
#' @param pdf_file Path to a PDF file.
#' @param page Integer page number (1-based, matching PDF page order).
#' @return A data frame of words on that page.
#' @export
pdf_page_words <- function(pdf_file, page) {
  w <- .pdftab_cache(pdf_file)[[page]]
  w$x2 <- w$x + w$width
  w$yc <- w$y + w$height / 2
  w$cx <- w$x + w$width / 2
  w
}

.pdftab_cache_env <- new.env(parent = emptyenv())

.pdftab_cache <- function(pdf_file) {
  key <- normalizePath(pdf_file, mustWork = TRUE)
  if (is.null(.pdftab_cache_env[[key]])) {
    .pdftab_cache_env[[key]] <- pdftools::pdf_data(pdf_file)
  }
  .pdftab_cache_env[[key]]
}

#' Group words on a page into text lines
#'
#' Words are sorted by vertical centre then x, and a new line starts
#' whenever the vertical centre jumps by more than `tol`. The default
#' tolerance (4pt) is chosen to sit between the offset of a superscript
#' footnote marker from its baseline (about 3pt) and the pitch between
#' ordinary text lines (about 8pt or more); re-check it for documents with
#' unusually tight or loose line spacing.
#'
#' @param w A word data frame from [pdf_page_words()].
#' @param tol Numeric vertical-centre tolerance, in points.
#' @return `w` with an added integer `line` column.
#' @export
pdf_add_lines <- function(w, tol = 4) {
  w <- w[order(w$yc, w$x), ]
  w$line <- cumsum(c(1, diff(w$yc) > tol))
  w
}

#' Collapse a lined word data frame to one text string per line
#'
#' @param w A word data frame that has been through [pdf_add_lines()].
#' @return A named character vector, names are line numbers (as strings),
#'   values are the words on that line joined by a single space, in
#'   left-to-right order.
#' @export
pdf_line_text <- function(w) {
  tapply(w$text[order(w$line, w$x)], w$line[order(w$line, w$x)], paste, collapse = " ")
}

#' Index the table captions in a PDF
#'
#' Scans every page for lines matching a caption pattern such as
#' `"TABLE 2.3"` or `"Table 2.3-Continued"`, and reports which PDF page(s)
#' each table's caption appears on. Useful as the first step when working
#' with an unfamiliar report: run this, then pass the page number(s) it
#' reports to [pdf_read_table()].
#'
#' @param pdf_file Path to a PDF file.
#' @param pattern A Perl-compatible regular expression with one capture
#'   group for the table identifier (e.g. `"2.3"` or `"A.1"`), matched
#'   against each full text line. The default expects captions of the
#'   form `"TABLE 2.3"`, `"Table A.1"`, optionally followed by an em-dash
#'   and "Continued".
#' @return A data frame with columns `table`, `pdf_page`, `continued`.
#' @export
pdf_table_index <- function(pdf_file,
                             pattern = "^\\s*(?:TABLE|Table)\\s+([A-Z]\\.[0-9]+|[0-9]+\\.[0-9]+)(\u2014Continued)?\\s*$") {
  txt <- pdftools::pdf_text(pdf_file)
  out <- lapply(seq_along(txt), function(p) {
    ln <- strsplit(txt[p], "\n")[[1]]
    m <- regmatches(ln, regexec(pattern, ln, perl = TRUE))
    m <- Filter(length, m)
    if (!length(m)) return(NULL)
    data.frame(table = vapply(m, `[`, "", 2), pdf_page = p,
               continued = nzchar(vapply(m, `[`, "", 3)))
  })
  do.call(rbind, out)
}

#' Index simple table captions ("Table N.")
#'
#' A lighter-weight sibling of [pdf_table_index()] for reports that caption
#' tables inline as plain prose, e.g. `"Table 8."`, rather than as a
#' standalone heading line. Looks for the pattern anywhere within the page
#' text rather than requiring it to be the whole line.
#'
#' @param pdf_file Path to a PDF file.
#' @param pattern Regular expression identifying a caption, default
#'   matches `"Table <digits>."`.
#' @return A data frame with columns `page`, `table`. Note that a caption
#'   can appear on the page before the table body actually starts.
#' @export
pdf_caption_index <- function(pdf_file, pattern = "Table [0-9]+\\.") {
  txt <- pdftools::pdf_text(pdf_file)
  out <- lapply(seq_along(txt), function(p) {
    m <- regmatches(txt[p], gregexpr(pattern, txt[p]))[[1]]
    if (!length(m)) return(NULL)
    data.frame(page = p, table = sub("\\.$", "", m))
  })
  do.call(rbind, out)
}

#' Extract one table from a PDF page by word geometry
#'
#' A general-purpose table reader for PDFs where [pdftools::pdf_text()]
#' loses the column structure (wrapped cells, centred headers, rotated
#' pages). It locates a table by its caption, assigns every word below the
#' caption to a text line and then to a column, and finally groups lines
#' into records either by vertical gaps (`record = "gap"`) or by a column
#' that starts every new record (`record = "anchor"`).
#'
#' Column boundaries must be supplied one of two ways, matching how the
#' table is actually typeset:
#' * `edges`: left edges of left-aligned columns, in points *relative to*
#'   the table's own leftmost word (so the same spec works across pages
#'   with different margins).
#' * `centres`: absolute x centres of centred columns; each word is
#'   assigned to its nearest centre. Use `pdf_suggest_edges()` to measure
#'   candidate values from the page.
#'
#' @param pdf_file Path to a PDF file.
#' @param table_id Table identifier as it appears in the caption, e.g.
#'   `"2.3"` or `"A.6"`.
#' @param page Integer page number the table (or its continuation) is on.
#' @param header_first Regular expression matching the first word of the
#'   header line used as an anchor, e.g. `"^Study$"`.
#' @param header_span Integer vector `c(lines_above, lines_below)`: how
#'   many additional lines around the anchor line belong to the header
#'   (for multi-line headers).
#' @param edges Numeric vector of column left edges relative to the
#'   table's leftmost word. Mutually exclusive with `centres`.
#' @param centres Numeric vector of absolute column centre x-coordinates.
#'   Mutually exclusive with `edges`.
#' @param record Either `"gap"` (a new record starts after an
#'   unusually large vertical gap) or `"anchor"` (a new record starts on
#'   every line where column `anchor_col` is non-empty).
#' @param anchor_col Integer column index used when `record = "anchor"`.
#' @param stop_pat Regular expression for the first word of a line that
#'   ends the table body, e.g. a `"NOTE:"` or `"SOURCE:"` line.
#' @param y_max Discard words below this y-coordinate (footers).
#' @param x_min,x_max Discard words outside this x-range; useful on
#'   rotated pages where running heads and page numbers sit in the margin.
#' @param gap_factor Multiplier applied to the smallest line-to-line
#'   vertical gap to decide what counts as a "large" gap when
#'   `record = "gap"`.
#' @param col_names Optional character vector of output column names;
#'   defaults to the header text, cleaned with [make.names()].
#' @return A data frame, one row per record, one column per detected
#'   column, with an attribute `"header"` holding the raw header text.
#' @export
pdf_read_table <- function(pdf_file, table_id, page, header_first, header_span = c(0, 0),
                            edges = NULL, centres = NULL,
                            record = c("gap", "anchor"), anchor_col = NULL,
                            stop_pat = "^(NOTE|SOURCE|Note|Source):?$",
                            y_max = 650, x_min = -Inf, x_max = Inf,
                            gap_factor = 1.35, col_names = NULL) {
  record <- match.arg(record)
  w <- pdf_add_lines(pdf_page_words(pdf_file, page))
  w <- w[w$x > x_min & w$x < x_max, ]

  lt <- pdf_line_text(w)
  cap <- grep(paste0("^(TABLE|Table) ", gsub("\\.", "\\\\.", table_id), "($|\u2014)"), lt)
  if (!length(cap)) stop("caption for table ", table_id, " not found on page ", page)
  cap_y <- min(w$yc[w$line == as.integer(names(lt)[cap[1]])])
  w <- w[w$yc > cap_y & w$y < y_max, ]

  lines <- sort(unique(w$line))
  leftmost <- vapply(lines, function(l) { s <- w[w$line == l, ]; s$text[which.min(s$x)] }, "")
  i0 <- which(grepl(header_first, leftmost))[1]
  if (is.na(i0)) stop("header line '", header_first, "' not found on page ", page)
  hdr_ids <- lines[(i0 - header_span[1]):(i0 + header_span[2])]
  rest <- i0 + header_span[2] + 1
  body_ids <- if (rest <= length(lines)) lines[rest:length(lines)] else integer(0)

  for (l in body_ids) {
    first <- leftmost[match(l, lines)]
    if (grepl(stop_pat, first)) { body_ids <- body_ids[body_ids < l]; break }
  }
  w <- w[w$line %in% c(hdr_ids, body_ids), ]

  if (!is.null(edges)) {
    e <- min(w$x) + edges
    w$col <- findInterval(w$x, e - 0.5)
    ncol <- length(e)
  } else if (!is.null(centres)) {
    w$col <- max.col(-abs(outer(w$cx, centres, "-")), ties.method = "first")
    ncol <- length(centres)
  } else {
    stop("supply either 'edges' or 'centres'")
  }
  w <- w[w$col >= 1, ]

  cell <- function(ids, cc) {
    s <- w[w$line %in% ids & w$col == cc, ]
    s <- s[order(s$line, s$x), ]
    paste(s$text, collapse = " ")
  }

  ym <- tapply(w$yc, w$line, mean)
  ym <- ym[as.character(body_ids)]
  recs <- list(); cur <- integer(0)
  if (record == "gap") {
    thr <- gap_factor * min(diff(ym))
    for (i in seq_along(body_ids)) {
      if (length(cur) && ym[i] - ym[cur[length(cur)]] > thr) { recs[[length(recs) + 1]] <- cur; cur <- integer(0) }
      cur <- c(cur, i)
    }
  } else {
    if (is.null(anchor_col)) stop("record = 'anchor' requires anchor_col")
    for (i in seq_along(body_ids)) {
      has <- any(w$line == body_ids[i] & w$col == anchor_col)
      if (has && length(cur)) { recs[[length(recs) + 1]] <- cur; cur <- integer(0) }
      cur <- c(cur, i)
    }
  }
  if (length(cur)) recs[[length(recs) + 1]] <- cur

  body <- t(vapply(recs, function(r) vapply(seq_len(ncol), function(cc) cell(body_ids[r], cc), ""),
                    character(ncol)))
  if (ncol == 1) body <- t(body)
  hdr <- vapply(seq_len(ncol), function(cc) cell(hdr_ids, cc), "")
  out <- as.data.frame(body, stringsAsFactors = FALSE)
  names(out) <- if (is.null(col_names)) make.names(hdr, unique = TRUE) else col_names
  out[] <- lapply(out, function(x) trimws(gsub("\\s+", " ", x)))
  attr(out, "header") <- hdr
  out
}

#' Drop a trailing single-letter footnote marker from a string
#'
#' Many reports mark a cell with a lowercase superscript letter
#' (`a`-`f`) tied to a footnote; once extracted as plain text that letter
#' rides along as a lone trailing word. This strips `") x"` down to `")"`
#' for `x` in `a`-`f`.
#'
#' @param x Character vector.
#' @return Character vector with trailing footnote letters removed.
#' @export
pdf_strip_footnote_letter <- function(x) sub("\\)\\s+[a-f]$", ")", x)

#' Suggest column edges for `pdf_read_table()`
#'
#' Measures how often words on a page share a left x-coordinate; shared
#' left edges are usually column boundaries. Run this on a table you
#' haven't parsed yet to find candidate `edges` values (the `rel` column,
#' already relative to the table's leftmost word).
#'
#' @param pdf_file Path to a PDF file.
#' @param table_id Table identifier as it appears in the caption.
#' @param page Integer page number.
#' @param min_lines Minimum number of lines an x-coordinate must appear on
#'   to be reported as a candidate column edge.
#' @param y_max Discard words below this y-coordinate (footers).
#' @return A data frame with columns `x` (absolute), `rel` (relative to
#'   the table's leftmost word -- pass this to `edges`), `n_lines`.
#' @export
pdf_suggest_edges <- function(pdf_file, table_id, page, min_lines = 4, y_max = 650) {
  w <- pdf_add_lines(pdf_page_words(pdf_file, page))
  lt <- pdf_line_text(w)
  cap <- grep(paste0("^(TABLE|Table) ", gsub("\\.", "\\\\.", table_id)), lt)[1]
  if (is.na(cap)) stop("caption for table ", table_id, " not found on page ", page)
  w <- w[w$yc > min(w$yc[w$line == as.integer(names(lt)[cap])]) & w$y < y_max, ]
  tab <- tapply(w$line, round(w$x), function(l) length(unique(l)))
  pk <- as.numeric(names(tab)[tab >= min_lines])
  data.frame(x = pk, rel = pk - min(w$x), n_lines = as.integer(tab[tab >= min_lines]))
}
