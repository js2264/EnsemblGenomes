#' @rdname EnsemblGenomes
#' @export
#' @examples
#' list_ensembl_taxa()

list_ensembl_taxa <- function() {
    tibble::tibble(
        taxon = c("vertebrate", "metazoa", "protists", "fungi", "plants", "bacteria"), 
        url = c(
            "https://ftp.ensembl.org/pub/",
            "https://ftp.ebi.ac.uk/ensemblgenomes/pub/metazoa/", 
            "https://ftp.ebi.ac.uk/ensemblgenomes/pub/protists/", 
            "https://ftp.ebi.ac.uk/ensemblgenomes/pub/fungi/", 
            "https://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/", 
            "https://ftp.ebi.ac.uk/ensemblgenomes/pub/bacteria/"
        )
    )
}

#' @rdname EnsemblGenomes
#' @export
#' @examples 
#' list_ensembl_releases('vertebrate')
#' list_ensembl_releases('fungi')

list_ensembl_releases <- function(taxon) {
    taxon <- .check_taxon(taxon)
    if (taxon == 'vertebrate') {
        releases <- httr::GET("https://ftp.ensembl.org/pub") |> 
            .extract_ftp_listing() |> 
            dplyr::select(Name, `Last modified`) |> 
            dplyr::filter(grepl('release-[0-9]', Name)) |>
            dplyr::rename(release = Name, date = `Last modified`) |> 
            dplyr::mutate(release = stringr::str_replace(release, '/$', ''))
        nbs <- stringr::str_replace(releases$release, 'release-', '') |> 
            as.numeric()
        r <- releases[nbs >= .VERTEBRATE_RELEASE_MIN, ]
        r <- r[seq(nrow(r), 1, by = -1), ]
        r$url <- paste0("https://ftp.ensembl.org/pub/", r$release)
    }
    else {
        releases <- httr::GET("https://ftp.ebi.ac.uk/ensemblgenomes/pub") |> 
            .extract_ftp_listing() |> 
            dplyr::filter(grepl('release-[0-9]', Name)) |>
            dplyr::rename(release = Name, date = `Last modified`) |> 
            dplyr::mutate(release = stringr::str_replace(release, '/$', ''))
        nbs <- stringr::str_replace(releases$release, 'release-', '') |> 
            as.numeric()
        r <- releases[nbs >= .GENOMES_RELEASE_MIN, ]
        r <- r[seq(nrow(r), 1, by = -1), ]
        r$url <- paste0("https://ftp.ebi.ac.uk/ensemblgenomes/pub/", taxon, "/", r$release)
    }
    return(r)
}

#' @name EnsemblGenomes
#' @rdname EnsemblGenomes
#' @details 
#' ## List of Ensembl species
#' As of Jul. 2025, there are around: 
#'   - vertebrate: ~ 325 species \[release-112\]
#'   - metazoa: ~ 335 species \[release-59\]
#'   - protists: ~ 237 species \[release-59\]
#'   - fungi: ~ 1502 species \[release-59\]
#'   - plants: ~ 153 species \[release-59\]
#'   - bacteria: ~ 31332 species \[release-59\]
#' @export
#' @examples 
#' list_ensembl_species('vertebrate', release = 'release-110')

list_ensembl_species <- function(
    taxon, 
    release = utils::head(list_ensembl_releases(taxon)$release, 1)
) {
    taxon <- .check_taxon(taxon)
    release <- .check_release(release, taxon)

    df <- httr::GET(.get_fasta_path(taxon, release)) |> 
        .extract_ftp_listing() |> 
        dplyr::rename(species = Name, date = `Last modified`) |> 
        dplyr::mutate(species = stringr::str_replace(species, '/$', '')) |> 
        dplyr::mutate(
            taxon = taxon, 
            collection = NA, 
            release = release
        ) |> 
        dplyr::relocate(date, .after = release) 
    
    if (taxon == "vertebrate") {
        df <- mutate(df, 
            url = glue::glue("https://ensembl.org/{species}/Info/Annotation#genebuild")
        ) |> dplyr::relocate(url, .after = species) |> 
            dplyr::filter(species != 'ancestral_alleles')
    } 
    else {
        df <- mutate(df, 
            url = glue::glue("https://{taxon}.ensembl.org/{species}/Info/Index")
        ) |> dplyr::relocate(url, .after = species) 
    }
    
    collections <- grep('_collection', df$species, value = TRUE)
    if (length(collections) > 0) {
        cols <- lapply(cli::cli_progress_along(collections), function(i) {
            col <- collections[i]
            glue::glue("{.get_fasta_path(taxon, release)}/{col}") |> 
                httr::GET() |> 
                .extract_ftp_listing() |> 
                dplyr::rename(species = Name, date = `Last modified`) |> 
                dplyr::mutate(species = stringr::str_replace(species, '/$', '')) |> 
                dplyr::mutate(
                    release = release, 
                    taxon = taxon, 
                    collection = col, 
                    url = glue::glue("https://{taxon}.ensembl.org/{species}/Info/Index")
                ) |> 
                dplyr::relocate(c(species, date), .after = collection)
        }) |> do.call(rbind, args = _)
        df <- filter(df, !species %in% collections) |> rbind(cols)
    }
    return(df)
}

#' @rdname EnsemblGenomes
#' @export
#' @examples 
#' list_ensembl_files("amphiprion_percula")
#' list_ensembl_files("amphiprion_percula", release = 'release-99')

list_ensembl_files <- function(species, taxon = NULL, release = NULL) {

    if (!is.null(taxon)) {
        taxon <- .check_taxon(taxon)
        if (!is.null(release)) {
            release <- .check_release(release, taxon)
        }
        else {
            release <- utils::head(list_ensembl_releases(taxon)$release, 1)
        }
        avail_species <- list_ensembl_species(taxon, release)
        if (!species %in% avail_species$species) 
            stop("Species not found. Check available species with `list_ensembl_species()`")
        entry <- avail_species[avail_species$species == species, ]
    } else {
        cli::cli_alert_info("Scanning taxons{ifelse(is.null(release),'', glue::glue(' [{release}]'))}...")
        for (i in cli::cli_progress_along(list_ensembl_taxa()$taxon)) {
            taxon <- list_ensembl_taxa()$taxon[i]
            r <- ifelse(is.null(release), utils::head(list_ensembl_releases(taxon)$release, 1), release)
            avail_species <- list_ensembl_species(taxon, release = r)
            if (species %in% avail_species$species) cli::cli_progress_done() && break
            if (i == nrow(list_ensembl_taxa())) cli::cli_progress_done() && break
        }
        if (i == nrow(list_ensembl_taxa()) && !species %in% avail_species$species)
            stop("Species not found. Check available species with `list_ensembl_species()`")
        if (!is.null(release)) {
            release <- .check_release(release, taxon)
        }
        else {
            release <- utils::head(list_ensembl_releases(taxon)$release, 1)
        }
        cli::cli_alert_success("Taxon found: {taxon} [{release}]")
        entry <- avail_species[avail_species$species == species, ]
    }

    release_nb <- stringr::str_replace(release, 'release-', '') |> as.numeric()
    release_pattern <- glue::glue("\\.{release_nb}\\.gff3.gz")

    ## FASTA
    fastas_folder <- .get_fasta_path(entry$taxon, entry$release) |> 
        stringr::str_c(
            stringr::str_replace_na(entry$collection,''), "/",
            entry$species, '/dna'
        )
    fastas <- httr::GET(fastas_folder) |> 
        .extract_ftp_listing() |> 
        dplyr::rename(file = Name, date = `Last modified`) |> 
        dplyr::filter(stringr::str_detect(file, 'toplevel.fa.gz$')) |>
        dplyr::mutate(
            release = release, 
            taxon = taxon, 
            collection = NA, 
            species = entry$species, 
            type = 'reference', 
            url = stringr::str_c(fastas_folder, "/", file), 
            url_status = lapply(url, function(.x) httr::status_code(httr::HEAD(.x))) |> unlist()
        ) |> 
        dplyr::select(-file)

    ## GFF3s
    gffs_folder <- fastas_folder |>
        stringr::str_replace("/fasta/", "/gff3/") |> 
        stringr::str_replace("/dna$", "")
    gffs <- httr::GET(gffs_folder) |> 
        .extract_ftp_listing() |> 
        dplyr::rename(file = Name, date = `Last modified`) |> 
        dplyr::filter(stringr::str_detect(file, paste0(release_nb, '.gff3.gz$'))) |>
        dplyr::mutate(
            release = release, 
            taxon = taxon, 
            collection = NA, 
            species = entry$species, 
            type = 'annotations', 
            url = stringr::str_c(gffs_folder, "/", file), 
            url_status = lapply(url, function(.x) httr::status_code(httr::HEAD(.x))) |> unlist()
        ) |> 
        dplyr::select(-file)

    rbind(fastas, gffs)

}
