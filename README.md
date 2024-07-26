# EnsemblGenomes

`EnsemblGenomes` scrapes [ensembl.org] and [ensemblgenomes.org] FTP 
servers to locate genome reference fasta files and genome annotation 
gff3 files provided for species supported by Ensembl. As of July 2024, 
this corresponds to more than 300 vertebrate, 300 metazoa, 200 protists, 
150 plants, 1,000 fungi and 30,000 bacteria species. Rather than supporting
`BiocFileCache`, EnsemblGenomes simply intends to retrieve and list URL 
of fasta and gff3 files across Ensembl releases as a plain data frame. 

## Installation 

In `R >= 4.4` and `Bioconductor >= 3.19`: 

```r
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("EnsemblGenomes")
```

## Usage

```r
library(EnsemblGenomes)

list_ensembl_species('vertebrate')
##  # A tibble: 324 × 6
##     species                          url                                                                            taxon      collection release     date        
##     <chr>                            <glue>                                                                         <chr>      <lgl>      <chr>       <chr>       
##   1 acanthochromis_polyacanthus      https://ensembl.org/acanthochromis_polyacanthus/Info/Annotation#genebuild      vertebrate NA         release-112 2024-04-23 …
##   2 accipiter_nisus                  https://ensembl.org/accipiter_nisus/Info/Annotation#genebuild                  vertebrate NA         release-112 2024-04-23 …
##   3 ailuropoda_melanoleuca           https://ensembl.org/ailuropoda_melanoleuca/Info/Annotation#genebuild           vertebrate NA         release-112 2024-04-23 …
##   4 amazona_collaria                 https://ensembl.org/amazona_collaria/Info/Annotation#genebuild                 vertebrate NA         release-112 2024-04-23 …
##   5 amphilophus_citrinellus          https://ensembl.org/amphilophus_citrinellus/Info/Annotation#genebuild          vertebrate NA         release-112 2024-04-23 …
##   6 amphiprion_ocellaris             https://ensembl.org/amphiprion_ocellaris/Info/Annotation#genebuild             vertebrate NA         release-112 2024-04-23 …
##   7 amphiprion_percula               https://ensembl.org/amphiprion_percula/Info/Annotation#genebuild               vertebrate NA         release-112 2024-04-23 …
##   8 anabas_testudineus               https://ensembl.org/anabas_testudineus/Info/Annotation#genebuild               vertebrate NA         release-112 2024-04-23 …
##   9 anas_platyrhynchos               https://ensembl.org/anas_platyrhynchos/Info/Annotation#genebuild               vertebrate NA         release-112 2024-04-23 …
##  10 anas_platyrhynchos_platyrhynchos https://ensembl.org/anas_platyrhynchos_platyrhynchos/Info/Annotation#genebuild vertebrate NA         release-112 2024-04-23 …
##  # ℹ 314 more rows
##  # ℹ Use `print(n = ...)` to see more rows

list_ensembl_files('amphiprion_percula')
##  ℹ Scanning taxons...
##  ✔ Taxon found: vertebrate [release-112]
##  # A tibble: 4 × 8
##    date             release     taxon      collection species            type        url                                                                url_status
##    <chr>            <chr>       <chr>      <lgl>      <chr>              <chr>       <chr>                                                                   <int>
##  1 2024-02-13 16:45 release-112 vertebrate NA         amphiprion_percula reference   https://ftp.ensembl.org/pub/release-112/fasta//amphiprion_percula…        200
##  2 2024-02-13 16:46 release-112 vertebrate NA         amphiprion_percula reference   https://ftp.ensembl.org/pub/release-112/fasta//amphiprion_percula…        200
##  3 2024-02-13 16:46 release-112 vertebrate NA         amphiprion_percula reference   https://ftp.ensembl.org/pub/release-112/fasta//amphiprion_percula…        200
##  4 2024-03-05 08:40 release-112 vertebrate NA         amphiprion_percula annotations https://ftp.ensembl.org/pub/release-112/gff3//amphiprion_percula/…        200
```

## Command-line usage

- Install `littler` and `EnsemblGenomes` in `R`

```sh
Rscript -e "BiocManager::install(c('littler', 'EnsemblGenomes'))"
```

- Make symlinks to `r` (from `littler`) and to `list_ensembl_files` (from `EnsemblGenomes`)

```sh
ln -s `Rscript -e "cat(.libPaths()[1])"`/littler/bin/r ~/.local/bin/
ln -s `Rscript -e "cat(.libPaths()[1])"`/EnsemblGenomes/bin/list_ensembl_files ~/.local/bin/
ln -s `Rscript -e "cat(.libPaths()[1])"`/EnsemblGenomes/bin/list_ensembl_species ~/.local/bin/
```

- Enjoy :)

```sh
list_ensembl_species fungi | head
list_ensembl_files plasmodium_vivax
```
