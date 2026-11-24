water_pdf <- bst260_example("2021_Annual_Waterborne_Disease_Surveillance_Report.pdf")
gun_pdf <- bst260_example("scienceOfGunPolicy.pdf")

test_that("pdf_caption_index finds the known Table captions", {
  idx <- pdf_caption_index(water_pdf)
  expect_true(all(c("Table 1", "Table 3", "Table 8") %in% idx$table))
})

test_that("pdf_read_count_pct_table reproduces the report's own totals", {
  tab3 <- pdf_read_count_pct_table(water_pdf, page = 6, header_pat = "^Setting\\s+N",
                                    col_names = c("outbreaks", "cases"))
  expect_equal(sum(tab3$outbreaks_n[tab3$label != "Total"]), 52L)
  expect_equal(sum(tab3$cases_n[tab3$label != "Total"]), 511L)
})

test_that("pdf_read_wide_wrapped_table recovers all 22 rows of Table 8", {
  h <- function(prefix, k = 1) c(prefix, k)
  cols8 <- list(Jurisdiction = list(h("Jurisdiction")), Month = list(h("Month")),
                Status = list(h("Status")), Etiology = list(h("Etiology", 2)),
                Cases = list(h("Cases")), Hosp = list(h("Hospitalizati")),
                Deaths = list(h("Deaths")), Venue = list(h("Water", 1), h("Venue(s)")),
                Setting = list(h("Water", 2), h("Setting")))
  tab8 <- do.call(rbind, lapply(11:12, function(p) pdf_read_wide_wrapped_table(water_pdf, p, cols8)))
  expect_equal(nrow(tab8), 22)
})

test_that("pdf_read_table recovers Table 18.1 from the gun policy report", {
  t181 <- pdf_read_table(gun_pdf, "18.1", page = 397, header_first = "^Study$",
                          edges = c(0, 121), stop_pat = "^(NOTE|SOURCE|a|b)$",
                          col_names = c("study", "significant_effect"))
  expect_equal(nrow(t181), 22)
})
