# Waterborne disease: tables and bibliographic integrity in a CDC surveillance report

``` r

library(bst260projhelp)
```

This vignette works through the CDC’s *2021 Annual Waterborne Disease
Surveillance Report* (the WBDOSS summary), bundled with the package:

``` r

pdf <- bst260_example("2021_Annual_Waterborne_Disease_Surveillance_Report.pdf")
pdftools::pdf_info(pdf)[c("pages", "created", "version")]
#> $pages
#> [1] 26
#> 
#> $created
#> [1] "2024-04-12 11:08:51 EDT"
#> 
#> $version
#> [1] "1.7"
```

As the original `data-raw/waterborne/README.txt` for this project put
it: the underlying question is whether results pulled from this single
annual report are consistent with the longer 1971-2023 WBDOSS resource
studied elsewhere in the course, which makes getting the extraction
*right* – not just plausible-looking – the point of this vignette.

## Information transformation: two kinds of PDF table

Where does each table start?

``` r

pdf_caption_index(pdf)
#>    page    table
#> 1     2  Table 1
#> 2     5  Table 2
#> 3     6  Table 3
#> 4     8  Table 4
#> 5     9  Table 5
#> 6     9  Table 6
#> 7    10  Table 7
#> 8    10  Table 8
#> 9    12  Table 9
#> 10   15 Table 10
#> 11   17 Table 11
#> 12   18 Table 12
#> 13   19 Table 13
#> 14   19 Table 14
#> 15   22 Table 15
#> 16   24 Table 16
```

### Tables with no wrapped cells: a simple line-by-line read

Tables 1 and 3 are short enough, and typeset simply enough, that each
row is a single text line: a label followed by one or more
`count (percent)` pairs, ending in a “Total” row.
[`pdf_read_count_pct_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_count_pct_table.md)
reads this layout directly off
[`pdftools::pdf_text()`](https://docs.ropensci.org/pdftools/reference/pdftools.html),
with no need for word coordinates:

``` r

tab1 <- pdf_read_count_pct_table(
  pdf, page = 3, header_pat = "^\\s*(Water\\s+)?Exposure",
  col_names = c("outbreaks", "cases", "hosp", "deaths")
)
tab1
#>          label outbreaks_n outbreaks_pct cases_n cases_pct hosp_n hosp_pct
#> 1 Recreational          32            62     284        56     37       36
#> 2     Drinking          15            29     214        42     56       54
#> 3        Other           1             2       2         0      2        2
#> 4      Unknown           4             8      11         2      9        9
#> 5        Total          52           100     511       100    104      100
#>   deaths_n deaths_pct
#> 1        1         10
#> 2        7         70
#> 3        0         NA
#> 4        2         20
#> 5       10        100

tab3 <- pdf_read_count_pct_table(
  pdf, page = 6, header_pat = "^Setting\\s+N",
  col_names = c("outbreaks", "cases")
)
tab3
#>                           label outbreaks_n outbreaks_pct cases_n cases_pct
#> 1                   Hotel/Motel          13            25     116        23
#> 2  Hospital/Healthcare Facility           9            17      38         7
#> 3     Outdoor Recreational Area           6            12      64        13
#> 4                         Beach           5            10      23         5
#> 5               Apartment/Condo           4             8      31         6
#> 6    Club (Requires Membership)           3             6      12         2
#> 7            Camp/Cabin Setting           2             4      99        19
#> 8        Community/Municipality           2             4      68        13
#> 9     School/College/University           2             4      32         6
#> 10     Subdivision/Neighborhood           2             4      13         3
#> 11                      Unknown           2             4       6         1
#> 12            Private Residence           1             2       5         1
#> 13                    Ship/Boat           1             2       4         1
#> 14                        Total          52           100     511       100
```

The report prints its own totals, so we can check the extraction against
them directly – the kind of check worth automating as a
[`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) rather than
eyeballing once and trusting forever:

``` r

stopifnot(
  sum(tab3$outbreaks_n[tab3$label != "Total"]) == 52,
  sum(tab3$cases_n[tab3$label != "Total"]) == 511
)
```

### Tables with wrapped cells: word-geometry extraction

Table 8 (treated recreational water outbreaks, pages 11-12) is harder:
columns are centred rather than left-aligned, and cells like etiology or
jurisdiction can wrap across several lines, so a line-by-line read would
scramble rows.
[`pdf_read_wide_wrapped_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_wide_wrapped_table.md)
instead assigns every word to its nearest column-header centre and then
to the row (anchored on the first column) that it vertically belongs to:

``` r

h <- function(prefix, k = 1) c(prefix, k)
cols8 <- list(
  Jurisdiction = list(h("Jurisdiction")),
  Month        = list(h("Month")),
  Status       = list(h("Status")),
  Etiology     = list(h("Etiology", 2)),       # "Etiology" appears twice in the header
  Cases        = list(h("Cases")),
  Hosp         = list(h("Hospitalizati")),      # poppler splits "Hospitalizations"
  Deaths       = list(h("Deaths")),
  Venue        = list(h("Water", 1), h("Venue(s)")),
  Setting      = list(h("Water", 2), h("Setting"))
)
tab8 <- do.call(rbind, lapply(11:12, function(p) pdf_read_wide_wrapped_table(pdf, p, cols8)))
tab8[c("Cases", "Hosp", "Deaths")] <- lapply(tab8[c("Cases", "Hosp", "Deaths")], as.integer)
tab8$Setting <- sub("/(Neig|Mun|Cond|U) ", "/\\1", tab8$Setting)  # repair a poppler line-split
nrow(tab8)  # expect 22
#> [1] 22
dtab(tab8)
```

Both extraction strategies are generic: neither function hard-codes
anything about waterborne disease, so the same calls work on the gun
policy report’s tables – see
[`vignette("gun-legislation")`](https://vjcitn.github.io/bst260projhelp/articles/gun-legislation.md)
– by supplying that document’s own page numbers and column layout.

## Bibliographic integrity: a numbered (Vancouver-style) reference list

Unlike the RAND report, this document cites by number – `"(1)"`, `"(2)"`
– against a short, two-entry reference list on page 25:

``` r

refs_raw <- vancouver_ref_entries(pdf, page = 25)
refs_raw
#>                                                                                                                                                                                                                        1 
#> "Collier SA, Deng L, Adam EA, et al. Estimate of Burden and Direct Healthcare Cost of Infectious Waterborne Disease in the United States. Emerging Infectious Diseases. 2021;27(1):140-149. doi:10.3201/eid2701.190676." 
#>                                                                                                                                                                                                                        2 
#>                                                      "Information about Public Water Systems. 2021 11/10/2021 [cited 2021 11/22]; Available from: https://www.epa.gov/dwreginfo/information-about-public-water-systems."
```

Each entry has its own shape (a journal article vs. a web resource), so
each is parsed with the matching function:

``` r

refs <- list(
  Collier2021 = vancouver_parse_article(refs_raw[["1"]], 1),
  EPA2021PWS  = vancouver_parse_web(refs_raw[["2"]], 2)
)
str(refs, max.level = 1)
#> List of 2
#>  $ Collier2021:List of 10
#>  $ EPA2021PWS :List of 9
```

Most of the report’s real evidentiary sources, though, are surveillance
*systems* (NORS, the NORS Dashboard, reporting forms) named in the
Methods and Conclusions sections rather than cited by number. Treating
these as if they weren’t sources at all would understate what the report
actually depends on, so they are curated by hand as `@misc` entries
(their URLs taken from the PDF’s own hyperlink annotations) and combined
with the parsed numbered references and the report’s own “Suggested
Citation” for itself:

``` r

cdc <- "{Centers for Disease Control and Prevention}"
curated <- list(
  Lawinger2023WBDOSS = list(
    type = "techreport",
    author = "Lawinger, H. and Hlavsa, M. and Miko, S. and Kunz, J. and Thuneibat, M. and Gerdes, M. and Gleason, M. and Roberts, V.",
    title = "Waterborne Disease and Outbreak Surveillance System ({WBDOSS}) Summary Report, {United States}, 2021",
    institution = "U.S. Department of Health and Human Services, CDC", address = "Atlanta, Georgia", year = "2023",
    annote = "Citation text from the report's own 'Suggested Citation' (p. 26)."
  ),
  CDCNORS = list(
    type = "misc", author = cdc, title = "National Outbreak Reporting System ({NORS})",
    url = "https://www.cdc.gov/nors/index.html",
    note = "Web-based platform used by jurisdictions to report outbreaks since 2009"
  ),
  CDCNORSDashboard = list(
    type = "misc", author = cdc, title = "{NORS} Dashboard",
    url = "https://www.cdc.gov/nors/data/dashboard/index.html",
    note = "2021 data in the report: outbreaks reported through NORS as of 19 January 2023; later pulls may differ"
  )
)
all_refs <- c(refs, curated)
```

That’s the full setup this package’s bibliography tools need: parsed
numbered references plus any hand-curated entries, combined into one
named list keyed by citation key. From here on, only the final rendered
bibliography is shown, not the construction code.

### Cross-checking the numbered citations

[`vancouver_find_numeric_citations()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_find_numeric_citations.md)
scans the whole document for text matching the `"word (N)"` citation
pattern, so the two entries in the reference list can be checked against
where they’re actually used – a cheap guard against a reference that was
added (or removed) from the list without updating the citation, or vice
versa. Each hit below is itself a link down to the entry it cites, and
carries its own anchor id so that entry can link back up to this exact
page:

``` r

nc <- vancouver_find_numeric_citations(pdf, max_ref = length(refs_raw))
num_to_key <- c(`1` = "Collier2021", `2` = "EPA2021PWS")
nc_keys <- strsplit(nc$numbers, ",")
cite_id <- Map(function(ks, i) paste0("cite-", num_to_key[ks], "-", i), nc_keys, seq_len(nrow(nc)))
nc$reference <- vapply(seq_along(nc_keys), function(i) {
  paste(bib_cite_link(num_to_key[nc_keys[[i]]], label = nc_keys[[i]], id = cite_id[[i]]), collapse = ", ")
}, "")
cited_at <- split(unlist(cite_id), unlist(lapply(nc_keys, function(ks) num_to_key[ks])))
dtab(nc[c("page", "cited", "reference")], escape = FALSE)
```

Both numbered citations – one on page 1, one on page 17 – are accounted
for in the two-entry reference list, which is the
bibliographic-integrity claim this section set out to check.

### The rendered bibliography

Each entry links to its DOI on `doi.org` when Crossref’s own parsed DOI
was captured in the reference text; failing that, to its plain `url`
when one is known (true of every curated entry, cited by its web page
rather than a DOI); and is explicitly marked `no DOI` in either case
when no DOI was found. The small `&uarr;` after `Collier2021` and
`EPA2021PWS` links back up to the page that cited them, found above –
the curated entries have no such link, since they’re named in the
report’s prose rather than cited by number:

``` r

cat(vancouver_bibliography_html(all_refs, cited_at), sep = "\n")
```

1.  Collier, S. A. and Deng, L. and Adam, E. A. and others. Estimate of
    Burden and Direct Healthcare Cost of Infectious Waterborne Disease
    in the United States. Emerging Infectious Diseases.
    2021;27(1):140–149. <https://doi.org/10.3201/eid2701.190676>
    [↑](#cite-Collier2021-1)
2.  U.S. Environmental Protection Agency. Information about Public Water
    Systems. Page last updated 2021-11-10. 2021. *no DOI*
    (<https://www.epa.gov/dwreginfo/information-about-public-water-systems>)
    [↑](#cite-EPA2021PWS-2)
3.  Lawinger, H. and Hlavsa, M. and Miko, S. and Kunz, J. and
    Thuneibat, M. and Gerdes, M. and Gleason, M. and Roberts, V..
    Waterborne Disease and Outbreak Surveillance System (WBDOSS) Summary
    Report, United States, 2021. U.S. Department of Health and Human
    Services, CDC, Atlanta, Georgia. 2023. *no DOI*
4.  Centers for Disease Control and Prevention. National Outbreak
    Reporting System (NORS). *no DOI*
    (<https://www.cdc.gov/nors/index.html>)
5.  Centers for Disease Control and Prevention. NORS Dashboard. *no DOI*
    (<https://www.cdc.gov/nors/data/dashboard/index.html>)

### A caution about URLs

The curated `@misc` entries above point at live CDC web resources rather
than fixed, versioned documents, and CDC has reorganized its site
before.
[`vancouver_check_urls()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_check_urls.md)
(not run here, since it requires network access) sends a `HEAD` request
to every URL in a reference list and reports the HTTP status, as a
first-pass check that a citation still resolves to *something* – not
proof that the content hasn’t changed underneath it:

``` r

vancouver_check_urls(all_refs)
```
