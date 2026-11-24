# Pre-compute DOIs (via Crossref) for the 22 studies cited in Table 18.1 of
# RAND's "The Science of Gun Policy", so the gun-legislation vignette can
# render live DOI links without depending on network access (or on
# Crossref's ~0.2s/request rate limit) at vignette-build time.
#
# Re-run this script (needs network access) whenever Table 18.1's cited
# studies change, or chapter 18's reference list is re-parsed differently.
# Output: inst/extdata/gunpolicy_ch18_dois.rds, a named list keyed by
# citation key (see rand_ref_key()), values are DOI strings or NA.

devtools::load_all(".")

pdf <- bst260_example("scienceOfGunPolicy.pdf")
t181 <- pdf_read_table(pdf, "18.1", page = 397, header_first = "^Study$",
                        edges = c(0, 121), stop_pat = "^(NOTE|SOURCE|a|b)$",
                        col_names = c("study", "significant_effect"))
t181$study <- pdf_strip_footnote_letter(t181$study)

refs <- rand_parse_chapter_refs(pdf, chapter = 18, chapter_title = "Concealed-Carry Laws")
refs_df <- rand_refs_table(refs)
t181_linked <- rand_link_citations(t181, "study", refs_df)
stopifnot(!anyNA(t181_linked$bib_key))

cited <- refs[vapply(refs, function(r) r$key %in% t181_linked$bib_key, NA)]
cat("looking up DOIs for", length(cited), "cited studies via Crossref...\n")

dois <- setNames(vector("list", length(cited)), vapply(cited, `[[`, "", "key"))
for (r in cited) {
  dois[[r$key]] <- rand_crossref_doi(r, mailto = "stvjc@channing.harvard.edu")
  Sys.sleep(0.2)
}
print(dois)
cat(sum(!vapply(dois, is.na, NA)), "of", length(dois), "resolved\n")

saveRDS(dois, "inst/extdata/gunpolicy_ch18_dois.rds")
