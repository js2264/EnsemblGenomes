test_that("list_* functions work", {

    # list_ensembl_taxa
    expect_equal(list_ensembl_taxa()$taxon, c("vertebrate", "metazoa", "protists", "fungi", "plants", "bacteria"))

    # list_ensembl_releases
    expect_error(list_ensembl_releases())
    expect_error(list_ensembl_releases(taxon = "fdvsdfv"))
    expect_equal(list_ensembl_releases(taxon = "vertebrate")$release[3], "release-110")
    expect_equal(list_ensembl_releases(taxon = "fungi")$release[3], "release-57")
    expect_equal(list_ensembl_releases(taxon = "vertebrate")$release[3], "release-110")

    # list_ensembl_species
    expect_error(list_ensembl_species())
    expect_error(list_ensembl_species(taxon = "fungi", release = 'release-16'))
    expect_error(list_ensembl_species(taxon = "vertebrate", release = 'release-51'))
    expect_equal(
        list_ensembl_species(taxon = "metazoa", release = 'release-19')$species[3], 
        "amphimedon_queenslandica"
    )
    expect_equal(
        list_ensembl_species(taxon = "plants", release = 'release-19')$species[3], 
        "arabidopsis_thaliana"
    )
    expect_equal(
        list_ensembl_species(taxon = "protists", release = 'release-19')$species[3], 
        "entamoeba_histolytica"
    )
    expect_equal(
        list_ensembl_species(taxon = "fungi", release = 'release-19')$species[3], 
        "aspergillus_flavus"
    )
    expect_equal(
        list_ensembl_species(taxon = "vertebrate", release = 'release-82')$species[3], 
        "anolis_carolinensis"
    )
    expect_equal(
        list_ensembl_species(taxon = "bacteria", release = 'release-19')$species[3], 
        "acinetobacter_baumannii_ac12"
    )

    # list_ensembl_species for CURRENT release
    expect_equal(
        list_ensembl_species(taxon = "metazoa")$species[3], 
        "acropora_millepora_gca013753865v1"
    )
    expect_equal(
        list_ensembl_species(taxon = "plants")$species[3], 
        "aegilops_umbellulata"
    )
    expect_equal(
        list_ensembl_species(taxon = "protists")$species[3], 
        "dictyostelium_discoideum"
    )
    expect_equal(
        list_ensembl_species(taxon = "fungi")$species[3], 
        "ashbya_gossypii"
    )
    expect_equal(
        list_ensembl_species(taxon = "vertebrate")$species[3], 
        "ailuropoda_melanoleuca"
    )
    expect_equal(
        list_ensembl_species(taxon = "bacteria")$species[3], 
        "aeromonas_hydrophila_subsp_hydrophila_atcc_7966_gca_000014805"
    )

})

