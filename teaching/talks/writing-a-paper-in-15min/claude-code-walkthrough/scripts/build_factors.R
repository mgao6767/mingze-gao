## Build the Ken French daily factor panel for 1990-2024
##
## Inputs:
##   - https://mba.tuck.dartmouth.edu/.../F-F_Research_Data_Factors_daily_CSV.zip
##   - https://mba.tuck.dartmouth.edu/.../F-F_Momentum_Factor_daily_CSV.zip
##
## Outputs:
##   - data/ff_factors_daily.rds  (date, mkt_rf, smb, hml, mom, rf)
##   - data/.cache/*.zip          (raw cached downloads)
##
## Author: data-engineer
## Date:   2026-05-11

library(here)
library(tidyverse)
library(lubridate)
library(readr)

here::i_am("scripts/build_factors.R")

set.seed(20260519)
options(scipen = 999)

# ---- Constants --------------------------------------------------------------

URL_FACTORS <- paste0(
  "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/",
  "F-F_Research_Data_Factors_daily_CSV.zip"
)
URL_MOMENTUM <- paste0(
  "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/",
  "F-F_Momentum_Factor_daily_CSV.zip"
)

CACHE_DIR <- here::here("data", ".cache")
CACHE_MAX_AGE_DAYS <- 30L

DATE_START <- as.Date("1990-01-01")
DATE_END   <- as.Date("2024-12-31")

OUT_PATH <- here::here("data", "ff_factors_daily.rds")

# ---- Helpers ----------------------------------------------------------------

# Fetch a remote zip into the cache, re-downloading only if stale.
# Stops with an informative message on HTTP failure — we never silently
# fall back to a stale cache older than CACHE_MAX_AGE_DAYS.
fetch_zip <- function(url, cache_dir, max_age_days) {
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
  zip_name <- basename(url)
  zip_path <- file.path(cache_dir, zip_name)

  is_fresh <- file.exists(zip_path) &&
    as.numeric(difftime(Sys.time(), file.info(zip_path)$mtime,
                        units = "days")) < max_age_days

  if (is_fresh) {
    message("Using cached ", zip_name)
    return(zip_path)
  }

  message("Downloading ", zip_name)
  status <- tryCatch(
    utils::download.file(url, destfile = zip_path, mode = "wb", quiet = TRUE),
    error = function(e) {
      stop(sprintf("Failed to download %s: %s", url, conditionMessage(e)),
           call. = FALSE)
    }
  )
  if (!isTRUE(status == 0) || !file.exists(zip_path) ||
      file.info(zip_path)$size < 1024) {
    stop(sprintf("Download of %s failed or file is suspiciously small.", url),
         call. = FALSE)
  }
  zip_path
}

# Read a Ken French daily CSV from a zip. The KF format has a multi-line
# descriptive header, then a section of daily rows beginning with YYYYMMDD,
# then a footer (e.g. "Annual Factors:") followed by annual rows.
read_kf_daily <- function(zip_path) {
  csv_name <- utils::unzip(zip_path, list = TRUE)$Name[1]
  con <- unz(zip_path, csv_name)
  raw <- readr::read_lines(con)
  # NOTE: unz() connection is closed by read_lines on completion; no close().

  # First daily row: a line starting with exactly 8 digits, comma.
  is_daily <- grepl("^\\s*[0-9]{8}\\s*,", raw)
  if (!any(is_daily)) {
    stop(sprintf("No daily rows found in %s", basename(zip_path)),
         call. = FALSE)
  }
  first_daily <- which(is_daily)[1]
  # Header is the row just before the first daily row.
  header_line <- trimws(raw[first_daily - 1L])
  # Last daily row: contiguous block of daily rows starting at first_daily.
  daily_idx <- which(is_daily)
  contiguous_end <- first_daily +
    sum(cumprod(c(TRUE, diff(daily_idx) == 1L))) - 1L
  daily_rows <- raw[first_daily:contiguous_end]

  # Parse with explicit column names (handles header containing "Mkt-RF").
  col_names <- strsplit(header_line, ",", fixed = TRUE)[[1]] |>
    trimws()
  col_names <- c("date_str", col_names[col_names != ""])

  df <- readr::read_csv(
    I(paste(daily_rows, collapse = "\n")),
    col_names = col_names,
    col_types = readr::cols(.default = readr::col_double(),
                            date_str = readr::col_character()),
    show_col_types = FALSE,
    progress = FALSE
  )

  # Normalise: trim names, convert date, divide percent values by 100.
  names(df) <- trimws(names(df))
  df$date <- lubridate::ymd(df$date_str)
  if (any(is.na(df$date))) {
    stop(sprintf("Failed to parse %d date strings in %s",
                 sum(is.na(df$date)), basename(zip_path)),
         call. = FALSE)
  }

  numeric_cols <- setdiff(names(df), c("date_str", "date"))
  for (col in numeric_cols) {
    df[[col]] <- df[[col]] / 100
  }

  df[, c("date", numeric_cols)]
}

# ---- Pipeline ---------------------------------------------------------------

dir.create(here::here("data"), showWarnings = FALSE, recursive = TRUE)

factors_zip <- fetch_zip(URL_FACTORS, CACHE_DIR, CACHE_MAX_AGE_DAYS)
momentum_zip <- fetch_zip(URL_MOMENTUM, CACHE_DIR, CACHE_MAX_AGE_DAYS)

factors_raw <- read_kf_daily(factors_zip)
momentum_raw <- read_kf_daily(momentum_zip)

# Standardise column names: strip whitespace from header tokens like "Mom   ".
names(momentum_raw) <- trimws(names(momentum_raw))
mom_col <- setdiff(names(momentum_raw), "date")
if (length(mom_col) != 1L) {
  stop(sprintf("Expected 1 momentum column, got: %s",
               paste(mom_col, collapse = ", ")),
       call. = FALSE)
}
momentum_raw <- dplyr::rename(momentum_raw, mom = !!mom_col)

# Rename factor columns to snake_case.
factors_raw <- dplyr::rename(
  factors_raw,
  mkt_rf = `Mkt-RF`,
  smb = SMB,
  hml = HML,
  rf = RF
)

ff <- dplyr::inner_join(factors_raw, momentum_raw, by = "date") |>
  dplyr::filter(date >= DATE_START, date <= DATE_END) |>
  dplyr::select(date, mkt_rf, smb, hml, mom, rf) |>
  dplyr::arrange(date)

stopifnot(!any(is.na(ff$date)))
stopifnot(all(vapply(ff[, -1], is.numeric, logical(1))))

saveRDS(ff, OUT_PATH)

# ---- Summary ----------------------------------------------------------------

cat(sprintf(
  "ff_factors_daily.rds: %d rows | %s to %s | mean(mkt_rf)=%.6f | mean(rf)=%.6f\n",
  nrow(ff),
  format(min(ff$date), "%Y-%m-%d"),
  format(max(ff$date), "%Y-%m-%d"),
  mean(ff$mkt_rf),
  mean(ff$rf)
))
