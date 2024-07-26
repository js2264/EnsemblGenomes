test_that("Test list_files for randomly picked species", {

    some_species <- lapply(
        list_ensembl_taxa()$taxon, function(.x) list_ensembl_species(.x)
    ) |> 
        do.call(rbind, args = _) |>
        dplyr::group_by(taxon) |>
        dplyr::slice_sample(n = 3)

    expect_true(
        lapply(some_species$url, function(.x) {
            print(.x)
            httr::status_code(httr::HEAD(.x))
        }) |> unlist() |> all()
    )

    expect_true(
        lapply(some_species$url, function(.x) {
            httr::status_code(httr::HEAD(.x)) == 200
        }) |> unlist() |> all()
    )

    some_files <- lapply(some_species$species, function(.x) {
        print(.x)
        taxon <- some_species |> dplyr::filter(species == .x) |> dplyr::pull(taxon)
        list_ensembl_files(.x, taxon = taxon)
    }) |> do.call(rbind, args = _)

    expect_true(all(some_files$url_status == 200))

})
