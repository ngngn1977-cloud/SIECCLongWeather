# Replace the local account name that `R CMD build` writes into the "Packaged:" field of DESCRIPTION.
# Usage: Rscript scripts/neutralise_packaged.R <package_tarball.tar.gz> [replacement]     (default replacement: gabinet)
# Only the text after the semicolon of the Packaged line changes; the date and every other file are kept, and the files keep their order in the archive.
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("usage: Rscript scripts/neutralise_packaged.R <tarball> [replacement]")
tb <- normalizePath(args[1], winslash = "/", mustWork = TRUE); who <- if (length(args) >= 2L) args[2L] else "gabinet"
ex <- tempfile("neutralise_"); dir.create(ex); on.exit(unlink(ex, recursive = TRUE), add = TRUE)
members <- utils::untar(tb, list = TRUE); utils::untar(tb, exdir = ex)
dpath <- file.path(ex, grep("^[^/]+/DESCRIPTION$", members, value = TRUE)[1L]); L <- readLines(dpath, warn = FALSE)
i <- grep("^Packaged: ", L); if (length(i) != 1L) stop("no single Packaged line in DESCRIPTION")
L[i] <- sub("^(Packaged: [^;]*);.*$", paste0("\\1; ", who), L[i]); con <- file(dpath, "wb"); writeBin(charToRaw(paste0(paste(L, collapse = "\n"), "\n")), con); close(con)
files <- members[!grepl("/$", members)]; old <- setwd(ex); on.exit(setwd(old), add = TRUE)
unlink(tb); utils::tar(tb, files = files, compression = "gzip", tar = "internal"); setwd(old)
cat("Packaged line now: ", L[i], "\n", sep = "")
