library(dplyr)
library(httr)

source("R/functions.R")


results <- scrape_all_pages()

readr::write_csv(results, paste0("output/2024_ottawa_summer_camps_",Sys.Date(),".csv"))
