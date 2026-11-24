#' Split a PDF page of plain text into lines
#'
#' @param pdf_file Path to a PDF file.
#' @param page Integer page number.
#' @return Character vector of lines on that page.
#' @export
pdf_page_lines <- function(pdf_file, page) {
  strsplit(pdftools::pdf_text(pdf_file)[page], "\n")[[1]]
}

#' Parse a "label  N (pct)  N (pct) ..." table row
#'
#' Handles the common report idiom of a row label followed by one or more
#' `count` or `count (percent)` tokens, e.g. `"Groundwater system 32 (62)"`.
#' Footnote marks (`*`, daggers) are stripped before parsing.
#'
#' @param line A single line of text.
#' @return A list with `label` (character), `n` (integer vector) and
#'   `pct` (integer vector, `NA` where no percentage was present), or
#'   `NULL` if the line doesn't match the expected shape.
#' @export
pdf_parse_count_pct_row <- function(line) {
  line <- gsub("[\u2020\u2021\u00a7*]", "", line)
  m <- regmatches(line, regexec("^(.+?)\\s+(\\d+(?:\\s*\\(\\d+\\))?(?:\\s+\\d+(?:\\s*\\(\\d+\\))?)*)\\s*$", line,
                                 perl = TRUE))[[1]]
  if (length(m) == 0) return(NULL)
  tok <- regmatches(m[3], gregexpr("\\d+(?:\\s*\\(\\d+\\))?", m[3], perl = TRUE))[[1]]
  n <- as.integer(sub("\\s*\\(.*$", "", tok))
  pct <- suppressWarnings(as.integer(sub("^.*\\((\\d+)\\).*$", "\\1", ifelse(grepl("\\(", tok), tok, NA))))
  list(label = trimws(m[2]), n = n, pct = pct)
}

#' Read a simple "count (percent)" table from a PDF page
#'
#' For tables where each row is a single text line: a label followed by
#' one or more `count (percent)` pairs, ending in a "Total" row. This
#' covers the common case where [pdftools::pdf_text()] alone preserves
#' row structure because nothing wraps across lines.
#'
#' @param pdf_file Path to a PDF file.
#' @param page Integer page number.
#' @param header_pat Regular expression identifying the header line; the
#'   table body is read starting on the next line.
#' @param col_names Character vector naming the count/percent column
#'   pairs, e.g. `c("outbreaks", "cases")` yields columns
#'   `outbreaks_n`, `outbreaks_pct`, `cases_n`, `cases_pct`.
#' @param stop_pat Regular expression for the row that ends the table
#'   (inclusive); defaults to a line starting with "Total".
#' @return A data frame with one row per table row (including the Total
#'   row), columns `label` plus `<name>_n`/`<name>_pct` for each entry in
#'   `col_names`.
#' @export
pdf_read_count_pct_table <- function(pdf_file, page, header_pat, col_names, stop_pat = "^\\s*Total") {
  ln <- pdf_page_lines(pdf_file, page)
  h <- grep(header_pat, ln)[1]
  start <- if (is.na(h)) 1 else h + 1
  end <- grep(stop_pat, ln)
  end <- end[end >= start][1]
  if (is.na(end)) stop("no row matching stop_pat found on page ", page, "; inspect pdf_page_lines(pdf_file, ", page, ")")
  rows <- Filter(Negate(is.null), lapply(ln[start:end], pdf_parse_count_pct_row))
  rows <- Filter(function(r) any(!is.na(r$pct)), rows)
  out <- do.call(rbind, lapply(rows, function(r) {
    vals <- as.vector(rbind(r$n, r$pct))
    names(vals) <- as.vector(t(outer(col_names, c("_n", "_pct"), paste0)))
    data.frame(label = r$label, as.list(vals)[seq_len(2 * length(col_names))], check.names = FALSE)
  }))
  rownames(out) <- NULL
  out
}

#' Read a wide table whose cells wrap across several text lines
#'
#' For tables where a plain line-by-line read breaks down because a
#' single record spans multiple lines (a long etiology or jurisdiction
#' name wraps) and/or columns are centred rather than left-aligned. Each
#' word on the page is assigned to the column whose header centre it is
#' nearest to, then to the row ("anchor") whose first-column entry is
#' closest in y -- this keeps tall wrapped cells attached to the correct
#' record even when the first column itself does not wrap.
#'
#' @param pdf_file Path to a PDF file.
#' @param page Integer page number.
#' @param col_labels A named list, one entry per output column, where
#'   each entry is a list of `c(prefix, k)` pairs: "the k-th header word
#'   (left to right) that starts with `prefix`". More than one pair per
#'   column is useful when a header's wording differs across pages, or
#'   when poppler splits a long header word in two (e.g. `"Hospitalizati"`
#'   + `"ons"`) -- just key on the unambiguous prefix.
#' @param line_gap Minimum vertical gap, in points, between consecutive
#'   text lines in the same column before they are treated as belonging
#'   to different records.
#' @return A data frame, one row per record, columns named as in
#'   `col_labels`.
#' @export
pdf_read_wide_wrapped_table <- function(pdf_file, page, col_labels, line_gap = 14) {
  w <- pdf_page_words(pdf_file, page)

  jy <- min(w$y[startsWith(w$text, col_labels[[1]][[1]][1])])
  hdr <- w[w$y >= jy - 10 & w$y <= jy + 15, ]
  centre <- vapply(col_labels, function(spec) {
    mean(vapply(spec, function(p) {
      i <- which(startsWith(hdr$text, p[1]))
      i <- i[order(hdr$x[i])][as.integer(p[2])]
      if (is.na(i)) stop("header word not found: '", p[1], "' (#", p[2], ") on page ", page)
      hdr$cx[i]
    }, numeric(1)))
  }, numeric(1))

  body <- w[w$y > max(hdr$y), ]
  nearest <- function(x, ref) max.col(-abs(outer(x, ref, "-")), ties.method = "first")
  body$col <- nearest(body$cx, centre)

  stop_y <- body$y[body$col == 1 & grepl("^(The|\\*)", body$text)]
  if (length(stop_y)) body <- body[body$y < min(stop_y), ]

  anchors <- sort(unique(body$y[body$col == 1]))
  body$row <- NA_integer_
  for (cc in seq_along(centre)) {
    sel <- body$col == cc
    ys <- sort(unique(body$y[sel]))
    run <- cumsum(c(1, diff(ys) > line_gap))
    mid <- tapply(ys, run, function(v) mean(range(v)))
    run_row <- nearest(as.numeric(mid), anchors)
    body$row[sel] <- run_row[run[match(body$y[sel], ys)]]
  }

  body <- body[order(body$row, body$col, body$y, body$x), ]
  cells <- tapply(body$text, list(factor(body$row, seq_along(anchors)),
                                   factor(body$col, seq_along(centre))),
                   paste, collapse = " ")
  out <- as.data.frame(cells, stringsAsFactors = FALSE)
  names(out) <- names(col_labels)
  out[] <- lapply(out, function(x) trimws(gsub("\\s+", " ", x)))
  rownames(out) <- NULL
  out
}
