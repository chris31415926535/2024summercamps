library(dplyr)
library(httr)

source("R/functions.R")


results <- scrape_all_pages()

results_summeronly <- results |>
  dplyr::mutate(date_start = lubridate::ymd(date_range_start), 
                date_end = lubridate::ymd(date_range_end),
                .before=1) |>
  dplyr::filter(date_start > lubridate::ymd("2024-07-01"),
                date_end < lubridate::ymd("2024-09-01")) |>
  dplyr::select(-date_start, -date_end)

readr::write_csv(results, paste0("output/2024_ottawa_events_all_",Sys.Date(),".csv"))

readr::write_csv(results_summeronly, paste0("output/2024_ottawa_summer_camps_",Sys.Date(),".csv"))
