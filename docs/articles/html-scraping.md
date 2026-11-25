# Stroke mortality: scraping tables and citations from a PMC HTML article

``` r

library(bst260projhelp)
```

The other two vignettes work from PDF reports. This one works from a
journal article published only as HTML – a PMC page bundled with the
package – and shows a third kind of information transformation:
`rvest`-based scraping instead of `pdftools`-based extraction.

``` r

article <- bst260_example("PMC13794488.html")
```

## Information transformation: scraping structure out of PMC’s HTML

PMC renders every article against the same handful of conventions:
standard `citation_*` meta tags in the `<head>` (the Highwire
Press/Google Scholar scheme most publishing platforms emit), and
predictable element ids in the body (`TabN` for tables, `FigN` for
figures, `AbsN` for the abstract, `CRN` for reference-list entries).
None of the functions below are specific to this one paper – they read
those conventions, not anything peculiar to this article.

### Article metadata, straight from the `<head>`

``` r

meta <- html_article_meta(article)
meta[c("title", "journal", "volume", "date", "doi", "pmid")]
#> $title
#> [1] "Trends and disparities in stroke mortality with diabetes as a contributing cause among U.S. adults, 1999–2023: a uniform-definition national analysis of long-term decline and a post-2014, pandemic-era increase"
#> 
#> $journal
#> [1] "BMC Public Health"
#> 
#> $volume
#> [1] "26"
#> 
#> $date
#> [1] "2026 Aug 31"
#> 
#> $doi
#> [1] "10.1186/s12889-026-29268-y"
#> 
#> $pmid
#> [1] "43073902"
meta$authors
#> [1] "Yan Cheng"    "Ji Li"        "Yunzhou Yang"
```

### Finding and reading a table

Unlike a PDF, where a table has no machine-readable boundary and has to
be found by its caption text, an HTML table is a real `<table>` element
– but it still needs to be found correctly: PMC wraps each table
together with its caption in an enclosing `<section>`, and calling
[`rvest::html_table()`](https://rvest.tidyverse.org/reference/html_table.html)
on *that* wrapper (rather than drilling down to the actual `<table>`
inside it) silently produces a nonsense one-row pseudo-table instead of
erroring.
[`html_table_index()`](https://vjcitn.github.io/bst260projhelp/reference/html_table_index.md)
lists what’s there;
[`html_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/html_read_table.md)
does the drill-down correctly:

``` r

html_table_index(article)[c("id", "label")]
#>     id    label
#> 1 Tab1 Table 1.
#> 2 Tab2 Table 2.
```

Table 2 reports the paper’s own segmented-regression estimates, and its
column names are the paper’s abbreviations, not self-explanatory labels,
so they’re worth spelling out before the table appears rather than
after:

- **change point** – the year, estimated from the data rather than
  assumed, at which the trend in mortality significantly shifts.
- **APC** (annual percentage change) – the constant yearly rate of
  change *within* one segment of the trend (e.g. before vs. after the
  change point).
- **AAPC** (average annual percentage change) – a single summary rate
  across the *whole* 1999-2023 period, averaging the early- and
  late-period APCs in proportion to how many years each segment spans.

``` r

tab2 <- html_read_table(article, "Tab2")
dtab(tab2)
```

### Abstract and a cited figure

``` r

ab <- html_abstract(article)
names(ab)
#> [1] "Background"  "Methods"     "Results"     "Conclusions"
ab[["Background"]]
#> [1] "Diabetes mellitus is a major contributor to cerebrovascular risk and stroke-related mortality. Although U.S. cardiovascular mortality declined for decades, national estimates for stroke mortality among people with diabetes have been inconsistent, partly because of differences in case definition and in the handling of the 2018 change in population race classification."
```

Figures are harder to extract “as text” than tables are, since the data
they summarize was never in the HTML at all – but the image itself is:
PMC serves it from its own CDN, so
[`html_figure_image()`](https://vjcitn.github.io/bst260projhelp/reference/html_figure_image.md)
just needs the `<img>` element’s `src`, not a download. `article` is
licensed CC BY 4.0 (confirmed below, straight from the page’s own
licence statement), so it can be reproduced here with attribution rather
than only described:

``` r

fig1 <- html_figure_image(article, "Fig1")
knitr::include_graphics(fig1$src)
```

![](https://cdn.ncbi.nlm.nih.gov/pmc/blobs/a6b8/13794488/d10e044bd883/12889_2026_29268_Fig1_HTML.webp)

``` r

cap <- html_figure_caption(article, "Fig1")
meta <- html_article_meta(article)
cat(sprintf(
  "**Fig. 1.** %s\n\n*Source:* %s. %s. *%s*. %s;%s:%s. [%s](https://doi.org/%s). Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).",
  cap, paste(meta$authors, collapse = ", "), meta$title, meta$journal,
  substr(meta$date, 1, 4), meta$volume, meta$firstpage, meta$doi, meta$doi
))
```

**Fig. 1.** National age-adjusted mortality rate for stroke (underlying
cause; ICD-10 I60–I69) with diabetes (E10–E14) as a contributing cause,
U.S. adults ≥ 25 years, 1999–2023. Points show observed rates with a 95%
CI band; the red line shows the fitted segmented model, with the change
point at 2014 (dotted line) and the 2014 nadir (4.28 per 100,000)
marked. Segment annual percentage changes (APCs) with 95% confidence
intervals are annotated (\* P \< 0.05). The shaded band denotes the
2020–2021 pandemic-peak years

*Source:* Yan Cheng, Ji Li, Yunzhou Yang. Trends and disparities in
stroke mortality with diabetes as a contributing cause among U.S.
adults, 1999–2023: a uniform-definition national analysis of long-term
decline and a post-2014, pandemic-era increase. *BMC Public Health*.
2026;26:3518.
[10.1186/s12889-026-29268-y](https://doi.org/10.1186/s12889-026-29268-y).
Licensed under [CC BY
4.0](https://creativecommons.org/licenses/by/4.0/).

Both the table- and figure-extraction functions above are generic in the
same sense the PDF ones are: nothing about them is specific to stroke,
diabetes, or this journal – the same calls work on any PMC article that
follows these id and meta-tag conventions.

## Bibliographic integrity: a reference list PMC has already structured

This paper cites by number – `[1]`, `[1, 2]` – against a 21-entry
reference list. Unlike the RAND and CDC reports, where the reference
list is plain PDF text that first has to be parsed back into structure,
PMC’s own HTML has already done that: each entry is a `<li id="CRN">`
carrying a formatted citation plus direct links to its DOI and PubMed
record, and every in-text citation marker is itself a real link,
`<a href="#CRN">`, straight to its entry – not text that merely looks
like a citation. So
[`pmc_ref_entries()`](https://vjcitn.github.io/bst260projhelp/reference/pmc_ref_entries.md)
and
[`pmc_find_citations()`](https://vjcitn.github.io/bst260projhelp/reference/pmc_find_citations.md)
are reads, not parsers:

``` r

refs <- pmc_ref_entries(article)
nrow(refs)
#> [1] 21
refs[1:3, c("key", "text", "doi")]
#>   key
#> 1 CR1
#> 2 CR2
#> 3 CR3
#>                                                                                                                                                                         text
#> 1    Tsao CW, Aday AW, Almarzooq ZI, et al. Heart disease and stroke statistics—2023 update: a report from the American Heart Association. Circulation. 2023;147(8):e93–621.
#> 2 Virani SS, Alonso A, Aparicio HJ, et al. Heart disease and stroke statistics—2021 update: a report from the American Heart Association. Circulation. 2021;143(8):e254–743.
#> 3                              Gregg EW, Li Y, Wang J, et al. Changes in diabetes-related complications in the United States, 1990–2010. N Engl J Med. 2014;370(16):1514–23.
#>                            doi
#> 1 10.1161/CIR.0000000000001123
#> 2 10.1161/CIR.0000000000000950
#> 3        10.1056/NEJMoa1310799

cites <- pmc_find_citations(article)
nrow(cites)
#> [1] 30
head(cites)
#>   para key label
#> 1 Par5 CR1     1
#> 2 Par5 CR2     2
#> 3 Par5 CR1     1
#> 4 Par5 CR3     3
#> 5 Par5 CR4     4
#> 6 Par5 CR5     5
```

### Cross-checking the citations

Because every in-text marker is already a structural link, checking that
it resolves to a real entry is just a set-membership test – no heuristic
regex over plain text, the way \[vancouver_find_numeric_citations()\]
has to work:

``` r

stopifnot(all(cites$key %in% refs$key))
```

Each citation link gets its own anchor id, via the same
\[bib_cite_link()\] used for the RAND and CDC vignettes, so it can link
down to its entry and that entry can link back up to every place it was
cited:

``` r

cite_id <- paste0("cite-", cites$key, "-", seq_len(nrow(cites)))
cites$link <- bib_cite_link(cites$key, label = cites$label, id = cite_id)
cited_at <- split(cite_id, cites$key)
dtab(cites[c("para", "key", "link")], escape = FALSE)
```

### The rendered bibliography

[`pmc_bibliography_html()`](https://vjcitn.github.io/bst260projhelp/reference/pmc_bibliography_html.md)
is a thin wrapper around the same \[bib_html_list()\] renderer the RAND
and CDC vignettes use – PMC’s entries arrive already formatted with
their own DOI and a PubMed fallback URL, so there’s no formatting step
first. Every entry links to its DOI on `doi.org`; the small `&uarr;`
links back up to every place in the text it was actually cited:

``` r

cat(pmc_bibliography_html(refs, cited_at), sep = "\n")
```

1.  Tsao CW, Aday AW, Almarzooq ZI, et al. Heart disease and stroke
    statistics—2023 update: a report from the American Heart
    Association. Circulation. 2023;147(8):e93–621.
    <https://doi.org/10.1161/CIR.0000000000001123> [↑](#cite-CR1-1)
    [↑](#cite-CR1-3)
2.  Virani SS, Alonso A, Aparicio HJ, et al. Heart disease and stroke
    statistics—2021 update: a report from the American Heart
    Association. Circulation. 2021;143(8):e254–743.
    <https://doi.org/10.1161/CIR.0000000000000950> [↑](#cite-CR2-2)
3.  Gregg EW, Li Y, Wang J, et al. Changes in diabetes-related
    complications in the United States, 1990–2010. N Engl J Med.
    2014;370(16):1514–23. <https://doi.org/10.1056/NEJMoa1310799>
    [↑](#cite-CR3-4)
4.  Aggarwal R, Wadhera RK, Pandey A, et al. Temporal trends in
    cardiovascular mortality in the United States, 1999–2020. J Am Coll
    Cardiol. 2022;79(21):2143–52. *no DOI* [↑](#cite-CR4-5)
5.  Siddiqi TJ, Usman MS, Khan MS, et al. Trends in cardiovascular
    mortality in the United States, 1999–2019. JAMA Netw Open.
    2021;4(8):e2110231. *no DOI* [↑](#cite-CR5-6)
6.  Chen R, Ovbiagele B, Feng W. Diabetes and stroke: epidemiology,
    pathophysiology, pharmaceuticals and outcomes. Diabetologia.
    2020;63(10):2006–21. <https://doi.org/10.1016/j.amjms.2016.01.011>
    [↑](#cite-CR6-7) [↑](#cite-CR6-11) [↑](#cite-CR6-15)
7.  Brownlee M. The pathobiology of diabetic complications: a unifying
    mechanism. Diabetes. 2005;54(6):1615–25.
    <https://doi.org/10.2337/diabetes.54.6.1615> [↑](#cite-CR7-8)
8.  Hales CM, Carroll MD, Fryar CD, Ogden CL. Prevalence of obesity and
    severe obesity among adults: United States, 2017–2018. Hyattsville,
    MD: NCHS; 2020. NCHS Data Brief no. 360. *no DOI*
    (<https://pubmed.ncbi.nlm.nih.gov/32487284/>) [↑](#cite-CR8-9)
    [↑](#cite-CR8-23)
9.  Wang L, Li X, Wang Z, et al. Trends in prevalence of diabetes and
    control of risk factors in diabetes among US adults, 1999–2018.
    JAMA. 2021;326(8):704–16. <https://doi.org/10.1001/jama.2021.9883>
    [↑](#cite-CR9-10) [↑](#cite-CR9-24)
10. Rawshani A, Rawshani A, Franzén S, et al. Mortality and
    cardiovascular disease in type 1 and type 2 diabetes. N Engl J Med.
    2018;379(7):633–44. <https://doi.org/10.1056/NEJMoa1800256>
    [↑](#cite-CR10-12)
11. Ma H, Liu M, Teng J. Temporal trends and disparities in stroke and
    diabetes mellitus comorbidity-related mortality from 1999 to 2023.
    Sci Rep. 2025;15:43967. <https://doi.org/10.1038/s41598-025-27754-8>
    [↑](#cite-CR11-13) [↑](#cite-CR11-22)
12. Vahidy FS, Pan AP, Ahnstedt H, et al. Excess stroke-related
    mortality during the COVID-19 pandemic in the United States. Stroke.
    2023;54(1):230–41. *no DOI* [↑](#cite-CR12-14) [↑](#cite-CR12-29)
13. Cheng WS, Wingard DL, Kritz-Silverstein D, Barrett-Connor E.
    Sensitivity and specificity of death certificates for diabetes: as
    good as it gets? Diabetes Care. 2008;31(2):279–84.
    <https://doi.org/10.2337/dc07-1327> [↑](#cite-CR13-16)
    [↑](#cite-CR13-30)
14. Heron M. Comparability of race-specific mortality data based on 1977
    versus 1997 reporting standards. National Vital Statistics Reports;
    vol 70 no 3. Hyattsville, MD: National Center for Health
    Statistics; 2021.
    <https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-03-508.pdf>.
    Accessed 15 Jul 2026. *no DOI*
    (<https://pubmed.ncbi.nlm.nih.gov/34029180/>) [↑](#cite-CR14-17)
15. Muggeo VMR. Estimating regression models with unknown break-points.
    Stat Med. 2003;22(19):3055–71. <https://doi.org/10.1002/sim.1545>
    [↑](#cite-CR15-18) [↑](#cite-CR15-20)
16. Kim HJ, Fay MP, Feuer EJ, Midthune DN. Permutation tests for
    joinpoint regression with applications to cancer rates. Stat Med.
    2000;19(3):335–51.
    [](https://doi.org/10.1002/(sici)1097-0258(20000215)19:3%3C335::aid-sim336%3E3.0.co;2-z)<https://doi.org/10.1002/(sici)1097-0258(20000215)19:3>\<335::aid-sim336\>3.0.co;2-z
    [↑](#cite-CR16-19)
17. Ekker MS, Verhoeven JI, Vaartjes I, van Nieuwenhuizen KM, Klijn CJM,
    de Leeuw FE. Stroke incidence in young adults according to age,
    subtype, sex, and time trends. Neurology. 2019;92(21):e2444–54.
    <https://doi.org/10.1212/WNL.0000000000007533> [↑](#cite-CR17-21)
18. Eberly LA, Yang L, Eneanya ND, et al. Association of race/ethnicity,
    gender, and socioeconomic status with sodium-glucose cotransporter 2
    inhibitor use among patients with diabetes in the US. JAMA Netw
    Open. 2021;4(4):e216139.
    <https://doi.org/10.1001/jamanetworkopen.2021.6139>
    [↑](#cite-CR18-25)
19. Eberly LA, Yang L, Essien UR, et al. Racial, ethnic, and
    socioeconomic inequities in glucagon-like peptide-1 receptor agonist
    use among patients with diabetes in the US. JAMA Health Forum.
    2021;2(12):e214182.
    <https://doi.org/10.1001/jamahealthforum.2021.4182>
    [↑](#cite-CR19-26)
20. Libby P, Lüscher T. COVID-19 is, in the end, an endothelial disease.
    Eur Heart J. 2020;41(32):3038–44.
    <https://doi.org/10.1093/eurheartj/ehaa623> [↑](#cite-CR20-27)
21. Varga Z, Flammer AJ, Steiger P, et al. Endothelial cell infection
    and endotheliitis in COVID-19. Lancet. 2020;395(10234):1417–8.
    <https://doi.org/10.1016/S0140-6736(20)30937-5> [↑](#cite-CR21-28)

``` r

table(has_doi = !is.na(refs$doi))
#> has_doi
#> FALSE  TRUE 
#>     5    16
```

Most entries have a DOI linked directly in PMC’s own HTML, but not all –
a handful (e.g. government data-brief and surveillance-report citations)
have neither a DOI nor a PubMed record, and are correctly marked
`no DOI` above rather than silently dropped, the same guarantee
\[bib_html_list()\] makes for the RAND and CDC vignettes.
