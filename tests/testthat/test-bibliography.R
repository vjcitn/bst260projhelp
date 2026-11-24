water_pdf <- bst260_example("2021_Annual_Waterborne_Disease_Surveillance_Report.pdf")
gun_pdf <- bst260_example("scienceOfGunPolicy.pdf")

test_that("vancouver_ref_entries parses both WBDOSS reference-list entries", {
  refs_raw <- vancouver_ref_entries(water_pdf, page = 25)
  expect_equal(names(refs_raw), c("1", "2"))
  expect_match(refs_raw[["1"]], "^Collier SA")
})

test_that("vancouver parsers and exporter round-trip without error", {
  refs_raw <- vancouver_ref_entries(water_pdf, page = 25)
  refs <- list(
    Collier2021 = vancouver_parse_article(refs_raw[["1"]], 1),
    EPA2021PWS  = vancouver_parse_web(refs_raw[["2"]], 2)
  )
  bib <- vancouver_to_bibtex(refs)
  expect_match(bib, "@article\\{Collier2021,")
  expect_match(bib, "@misc\\{EPA2021PWS,")
})

test_that("every study in gun-policy Table 18.1 resolves to a chapter-18 reference", {
  t181 <- pdf_read_table(gun_pdf, "18.1", page = 397, header_first = "^Study$",
                          edges = c(0, 121), stop_pat = "^(NOTE|SOURCE|a|b)$",
                          col_names = c("study", "significant_effect"))
  refs <- rand_parse_chapter_refs(gun_pdf, chapter = 18, chapter_title = "Concealed-Carry Laws")
  refs_df <- rand_refs_table(refs)
  t181_linked <- rand_link_citations(t181, "study", refs_df)
  expect_false(anyNA(t181_linked$bib_key))
  expect_equal(nrow(t181_linked), 22)
})
