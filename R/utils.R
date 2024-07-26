.check_taxon <- function(taxon) {
    if (missing(taxon)) {
        x <- paste0(list_ensembl_taxa()$taxon, collapse = ', ')
        stop(glue::glue("'`taxon` needs to be specified. It can be any of: {x}.'"))
    }
    taxon <- match.arg(taxon, list_ensembl_taxa()$taxon)
}

.check_release <- function(release, taxon) {
    if (!release %in% list_ensembl_releases(taxon)$release) {
        stop(glue::glue("The provided `release` is not available for the provided `taxon`"))
    }
    return(release)
}

.get_fasta_path <- function(taxon, release) {
    taxon <- .check_taxon(taxon)
    release <- .check_release(release, taxon)
    if (taxon == 'vertebrate') {
        glue::glue("https://ftp.ensembl.org/pub/{release}/fasta/")
    }
    else {
        glue::glue(
            "https://ftp.ebi.ac.uk/ensemblgenomes/pub/{release}/{taxon}/fasta/"
        )
    }
}

.extract_ftp_listing <- function(query) {
    httr::content(query) |> 
        rvest::html_element('table') |> 
        rvest::html_table(fill = TRUE) |> 
        dplyr::select(-1) |> 
        dplyr::filter(!Name %in% c('', 'Parent Directory')) |> 
        dplyr::select(Name, `Last modified`) 
}