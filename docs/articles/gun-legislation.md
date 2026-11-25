# Gun legislation: tables and bibliographic integrity in a RAND report

``` r

library(bst260projhelp)
```

This vignette works through RAND’s *The Science of Gun Policy* (4th ed.,
2024), a 512-page report bundled with the package:

``` r

pdf <- bst260_example("scienceOfGunPolicy.pdf")
```

It demonstrates the two kinds of information transformation this package
supports on reports like this one – pulling structured tables out of a
PDF that was never designed to be machine-read, and recovering enough of
the document’s bibliographic structure to check that an in-text claim
traces back to a real, identifiable source.

## Information transformation: recovering tables from PDF geometry

[`pdftools::pdf_text()`](https://docs.ropensci.org/pdftools/reference/pdftools.html)
returns each page as a block of plain text, which is enough for prose
but loses column structure whenever cells wrap or headers are centred
rather than left-aligned – both common in this report.
[`pdf_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_table.md)
instead works from word-level coordinates
([`pdftools::pdf_data()`](https://docs.ropensci.org/pdftools/reference/pdftools.html)),
grouping words first into text lines and then into columns.

Before parsing an unfamiliar table, find out which page its caption is
on:

``` r

idx <- pdf_table_index(pdf)
head(idx)
#>   table pdf_page continued
#> 1   S.1       10     FALSE
#> 2   S.1       11      TRUE
#> 3   S.1       12      TRUE
#> 4   2.1       59     FALSE
#> 5   2.2       60     FALSE
#> 6   2.3       69     FALSE
subset(idx, table %in% c("18.1", "A.3", "A.6"))
#>    table pdf_page continued
#> 13  18.1      397     FALSE
#> 21   A.3      492     FALSE
#> 27   A.6      501     FALSE
```

### A simple two-column table: 18.1

Table 18.1 lists concealed-carry studies and whether they found a
significant effect. Its columns are left-aligned, so we give
[`pdf_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_table.md)
column edges (relative to the table’s own left margin) rather than
centres:

``` r

t181 <- pdf_read_table(
  pdf, "18.1", page = 397, header_first = "^Study$",
  edges = c(0, 121), stop_pat = "^(NOTE|SOURCE|a|b)$",
  col_names = c("study", "significant_effect")
)
t181$study <- pdf_strip_footnote_letter(t181$study)
dtab(t181)
```

### A numeric table with a confidence interval: A.3

Table A.3 reports incidence-rate ratios with 95% CIs as a single text
column (`"1.12 [1.03-1.21]"`); once extracted, ordinary regex parsing
pulls out the numbers:

``` r

a3 <- pdf_read_table(
  pdf, "A.3", page = 492, header_first = "^Study$",
  edges = c(0, 131, 228, 322),
  col_names = c("study", "policy", "outcome", "irr_ci")
)
m <- regmatches(a3$irr_ci, regexec("^([0-9.]+) \\[([0-9.]+)[\u2013-]([0-9.]+)\\]$", a3$irr_ci))
a3[c("irr", "ci_lo", "ci_hi")] <- lapply(2:4, function(i) as.numeric(vapply(m, function(z) z[i], "")))
a3$ci_excludes_1 <- a3$ci_lo > 1 | a3$ci_hi < 1
stopifnot(nrow(a3) == 18, !anyNA(a3$irr))
dtab(a3)
```

### A table where records aren’t separated by whitespace: A.6

Table A.6 compares 2022-vs-2024 conclusions by policy; its first column
wraps across lines with no blank line between records, so a new record
must instead be recognized by a column that’s always filled – here,
“No. of Studies” (column 2):

``` r

a6 <- pdf_read_table(
  pdf, "A.6", page = 501, header_first = "^Policy$", header_span = c(2, 0),
  edges = c(0, 113, 136, 252, 276), record = "anchor", anchor_col = 2,
  col_names = c("policy", "n_2022", "conclusion_2022", "n_2024", "conclusion_2024")
)
a6$n_2022 <- as.integer(a6$n_2022)
a6$n_2024 <- as.integer(a6$n_2024)
#> Warning: NAs introduced by coercion
dtab(a6)
```

If you need to extract a table this package hasn’t already seen,
[`pdf_suggest_edges()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_suggest_edges.md)
measures candidate column left-edges directly from the page – shared
x-coordinates across several lines are usually column boundaries:

``` r

pdf_suggest_edges(pdf, "A.6", page = 501)
#>     x rel n_lines
#> 1  57   0      36
#> 2 170 113      18
#> 3 193 136      32
#> 4 205 148      18
#> 5 309 252      18
#> 6 332 275      26
#> 7 345 288      14
```

## Bibliographic integrity: linking citations to a RAND-style reference list

This report has no single master bibliography: each chapter closes with
its own `"Chapter N References"` list, in RAND’s own citation style (not
author-year), while in-text citations in tables and prose *are*
author-year (e.g. `"Lott and Mustard (1997)"`). Checking bibliographic
integrity here means parsing the chapter’s reference list into
structured entries, deriving an author-year key for each one, and
confirming every in-text citation resolves to exactly one entry.

``` r

refs <- rand_parse_chapter_refs(pdf, chapter = 18, chapter_title = "Concealed-Carry Laws")
length(refs)
#> [1] 135
refs_df <- rand_refs_table(refs)
head(refs_df[c("key", "type", "title", "container")])
#>                 key       type
#> 1         Adams2022    article
#> 2 AldrichNelson1984       misc
#> 3     AnejaEtAl2011    article
#> 4     AnejaEtAl2014 techreport
#> 5  AyresDonohue1999    article
#> 6 AyresDonohue2003a    article
#>                                                                                                                     title
#> 1                                                       No Retreat: The Impact of Stand Your Ground Laws on Violent Crime
#> 2                                                                                                      Linear Probability
#> 3            The Impact of Right-to-Carry Laws and the NRC Report: Lessons for the Empirical Evaluation of Law and Policy
#> 4 The Impact of Right to Carry Laws and the NRC Report: The Latest Lessons for the Empirical Evaluation of Law and Policy
#> 5              Nondiscretionary Concealed Weapons Laws: A Case Study of Statistics, Standards of Proof, and Public Policy
#> 6                                                                      Shooting Down the More Guns, Less Crime Hypothesis
#>                           container
#> 1           Criminal Justice Review
#> 2                              <NA>
#> 3 American Law and Economics Review
#> 4                              <NA>
#> 5 American Law and Economics Review
#> 6               Stanford Law Review
```

Now link Table 18.1’s `study` column to this reference table:

``` r

t181_linked <- rand_link_citations(t181, "study", refs_df)
stopifnot(!anyNA(t181_linked$bib_key))

# one anchor id per row, so each study links down to its bibliography
# entry and that entry can link back up to this exact row
cite_id <- paste0("cite-", t181_linked$bib_key, "-", seq_len(nrow(t181_linked)))
disp <- t181_linked[c("study", "significant_effect", "bib_key")]
disp$study <- bib_cite_link(t181_linked$bib_key, label = t181_linked$study, id = cite_id)
dtab(disp, escape = FALSE)
```

Every one of the 22 studies in Table 18.1 resolves to exactly one
chapter-18 reference-list entry – the
[`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) above is the
integrity check: if some future edit to the report, or some mistake in
the transcription, broke that correspondence, this line would fail
instead of silently producing a table with dangling citations. Each
`study` cell above is itself a link down to that entry in the rendered
bibliography below.

That setup – parse the chapter’s reference list, link a table’s
citations against it, and check the link is complete – is the pattern
the rest of this package’s bibliography tools build on. The remaining
steps (restricting to the studies actually cited by Table 18.1, and
attaching a DOI, looked up via \[rand_crossref_doi()\] against Crossref
and cached in the package so the vignette doesn’t need network access to
build) are mechanical, so they’re run but not shown here; only the final
rendered bibliography is displayed.

### The rendered bibliography

Each entry below links to its DOI on `doi.org` when one was found via
Crossref, or to a plain URL (parsed straight from the reference text)
when no DOI was found but a URL was still given; either way, an entry
with no DOI is explicitly marked `no DOI` – a reader should never have
to guess whether a missing link means “none exists” or “nobody checked”.
The small `&uarr;` after each entry links back up to the Table 18.1 row
that cited it:

``` r

cat(rand_bibliography_html(cited, cited_at), sep = "\n")
```

1.  Ayres, Ian, and John J. Donohue III, “Nondiscretionary Concealed
    Weapons Laws: A Case Study of Statistics, Standards of Proof, and
    Public Policy,” American Law and Economics Review, Vol. 1, No. 1–2,
    January 1999. <https://doi.org/10.1093/aler/1.1.436>
    [↑](#cite-AyresDonohue1999-8)
2.  Ayres, Ian, and John J. Donohue III, “Shooting Down the More Guns,
    Less Crime Hypothesis,” Stanford Law Review, Vol. 55, No. 4, 2003a.
    *no DOI* [↑](#cite-AyresDonohue2003a-19)
3.  Ayres, Ian, and John J. Donohue III, “The Latest Misfires in Support
    of the More Guns, Less Crime Hypothesis,” Stanford Law Review, Vol.
    55, No. 4, 2003b. *no DOI* [↑](#cite-AyresDonohue2003b-20)
4.  Bartley, William Alan, and Mark A. Cohen, “The Effect of Concealed
    Weapons Laws: An Extreme Bound Analysis,” Economic Inquiry, Vol. 36,
    No. 2, 1998. <https://doi.org/10.1111/j.1465-7295.1998.tb01711.x>
    [↑](#cite-BartleyCohen1998-2)
5.  Benson, Bruce L., and Brent D. Mast, “Privately Produced General
    Deterrence,” Journal of Law and Economics, Vol. 44, No. S2, 2001.
    <https://doi.org/10.1086/323766> [↑](#cite-BensonMast2001-11)
6.  Black, Dan A., and Daniel S. Nagin, “Do Right-to-Carry Laws Deter
    Violent Crime?” Journal of Legal Studies, Vol. 27, No. 1, 1998.
    <https://doi.org/10.1086/468019> [↑](#cite-BlackNagin1998-3)
7.  Bronars, Stephen G., and John R. Lott, Jr., “Criminal Deterrence,
    Geographic Spillovers, and the Right to Carry Concealed Handguns,”
    American Economic Review, Vol. 88, No. 2, 1998. *no DOI*
    [↑](#cite-BronarsLott1998-4)
8.  Donohue, John J., “The Impact of Concealed Carry Laws,” in Jens
    Ludwig and Philip J. Cook, eds., Evaluating Gun Policy: Effects on
    Crime and Violence, Brookings Institution Press, 2003. *no DOI*
    [↑](#cite-Donohue2003-21)
9.  Duggan, Mark, “More Guns, More Crime,” Journal of Political Economy,
    Vol. 109, No. 5, 2001. <https://doi.org/10.1086/322833>
    [↑](#cite-Duggan2001-12)
10. Helland, E., and A. Tabarrok, “Using Placebo Laws to Test ‘More
    Guns, Less Crime,’” Advances in Economic Analysis and Policy, Vol.
    4, No. 1, 2004. <https://doi.org/10.2202/1538-0637.1182>
    [↑](#cite-HellandTabarrok2004-22)
11. Lott, John R., Jr., “The Concealed-Handgun Debate,” Journal of Legal
    Studies, Vol. 27, No. 1, January 1998a.
    <https://doi.org/10.1086/468020> [↑](#cite-Lott1998a-5)
12. Lott, John R., Jr., More Guns, Less Crime: Understanding Crime and
    Gun-Control Laws, 1st ed., University of Chicago Press, 1998b. *no
    DOI* [↑](#cite-Lott1998b-6)
13. Lott, John R., Jr., More Guns, Less Crime: Understanding Crime and
    Gun-Control Laws, 2nd ed., University of Chicago Press, 2000. *no
    DOI* [↑](#cite-Lott2000-10)
14. Lott, John R., Jr., and William M. Landes, Multiple Victim Public
    Shootings, Bombings, and Right-to-Carry Concealed Handgun Laws:
    Contrasting Private and Public Law Enforcement, University of
    Chicago Law School, John M. Olin Law and Economics Working Paper
    No. 73, 1999. *no DOI* [↑](#cite-LottLandes1999-9)
15. Lott, John R., Jr., and D. B. Mustard, “Crime, Deterrence, and
    Right-to-Carry Concealed Handguns,” Journal of Legal Studies, Vol.
    26, No. 1, 1997. <https://doi.org/10.1086/467988>
    [↑](#cite-LottMustard1997-1)
16. Lott, John R., Jr., and John E. Whitley, “Measurement Error in
    County-Level UCR Data,” Journal of Quantitative Criminology, Vol.
    19, No. 2, June 2003. <https://doi.org/10.1023/a:1023054204615>
    [↑](#cite-LottWhitley2003-16)
17. Ludwig, Jens, “Concealed-Gun-Carrying Laws and Violent Crime:
    Evidence from State Panel Data,” International Review of Law and
    Economics, Vol. 18, No. 3, 1998.
    <https://doi.org/10.1016/s0144-8188(98)00012-x>
    [↑](#cite-Ludwig1998-7)
18. Moody, Carlisle E., “Testing for the Effects of Concealed Weapons
    Laws: Specification Errors and Robustness,” Journal of Law and
    Economics, Vol. 44, No. S2, 2001. <https://doi.org/10.1086/323313>
    [↑](#cite-Moody2001-13)
19. Olson, David E., and Michael D. Maltz, “Right-to-Carry Concealed
    Weapon Laws and Homicide in Large U.S. Counties: The Effect on
    Weapon Types, Victim Characteristics, and Victim-Offender
    Relationships,” Journal of Law and Economics, Vol. 44, No. S2, 2001.
    <https://doi.org/10.1086/338345> [↑](#cite-OlsonMaltz2001-14)
20. Plassmann, Florenz, and T. Nicolaus Tideman, “Does the Right to
    Carry Concealed Handguns Deter Countable Crimes? Only a Count
    Analysis Can Say,” Journal of Law and Economics, Vol. 44,
    No. S2, 2001. <https://doi.org/10.1086/323311>
    [↑](#cite-PlassmannTideman2001-15)
21. Plassmann, F., and J. E. Whitley, “Comments: Confirming ‘More Guns,
    Less Crime,’” Stanford Law Review, Vol. 55, No. 4, 2003. *no DOI*
    [↑](#cite-PlassmannWhitley2003-17)
22. Rubin, Paul H., and Hashem Dezhbakhsh, “The Effect of Concealed
    Handgun Laws on Crime: Beyond the Dummy Variables,” International
    Review of Law and Economics, Vol. 23, No. 2, 2003.
    <https://doi.org/10.1016/s0144-8188(03)00027-9>
    [↑](#cite-RubinDezhbakhsh2003-18)
