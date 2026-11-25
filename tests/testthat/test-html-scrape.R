article <- bst260_example("PMC13794488.html")

test_that("html_article_meta reads the standard citation_* meta tags", {
  meta <- html_article_meta(article)
  expect_equal(meta$journal, "BMC Public Health")
  expect_true(grepl("^10\\.", meta$doi))
  expect_length(meta$authors, 3)
})

test_that("html_table_index finds both tables and html_read_table reads them", {
  idx <- html_table_index(article)
  expect_equal(idx$id, c("Tab1", "Tab2"))

  tab1 <- html_read_table(article, "Tab1")
  expect_equal(nrow(tab1), 17)
  expect_equal(ncol(tab1), 3)

  tab2 <- html_read_table(article, "Tab2")
  expect_equal(nrow(tab2), 15)
})

test_that("html_abstract splits the structured abstract by subheading", {
  ab <- html_abstract(article)
  expect_equal(names(ab), c("Background", "Methods", "Results", "Conclusions"))
})

test_that("html_figure_caption reads a <figcaption>", {
  cap <- html_figure_caption(article, "Fig1")
  expect_match(cap, "^National age-adjusted mortality rate")
})

test_that("html_figure_image reads the <img> src", {
  img <- html_figure_image(article, "Fig1")
  expect_match(img$src, "^https://")
  expect_match(img$src, "\\.webp$")
})

test_that("pmc_ref_entries parses all 21 reference-list entries", {
  refs <- pmc_ref_entries(article)
  expect_equal(nrow(refs), 21)
  expect_equal(refs$key, paste0("CR", 1:21))
  expect_true(any(!is.na(refs$doi)))
  expect_true(any(is.na(refs$doi)))
})

test_that("every in-text citation link resolves to a reference-list entry", {
  refs <- pmc_ref_entries(article)
  cites <- pmc_find_citations(article)
  expect_true(nrow(cites) > 0)
  expect_true(all(cites$key %in% refs$key))
})

test_that("pmc_bibliography_html renders a DOI link and backlink", {
  refs <- pmc_ref_entries(article)[1, ]
  html <- pmc_bibliography_html(refs, cited_at = list(CR1 = "cite-CR1-1"))
  expect_true(any(grepl("doi.org", html)))
  expect_true(any(grepl("cite-CR1-1", html)))
})
