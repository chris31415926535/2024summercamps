
scrape_page <- function (page_num) {
  
  page_info <- paste0('{\"order_by\":\"Name\",\"page_number\":',page_num,',\"total_records_per_page\":20}')
  
  result <- httr::POST("https://anc.ca.apm.activecommunities.com/ottawa/rest/activities/list?locale=en-US",
                       body='{"activity_search_pattern":{"skills":[],"time_after_str":"","days_of_week":null,"activity_select_param":2,"center_ids":[],"time_before_str":"","open_spots":null,"activity_id":null,"activity_category_ids":[],"date_before":"","min_age":null,"date_after":"","activity_type_ids":[],"site_ids":[],"for_map":false,"geographic_area_ids":[],"season_ids":[],"activity_department_ids":[],"activity_other_category_ids":["8"],"child_season_ids":[],"activity_keyword":"","instructor_ids":[],"max_age":null,"custom_price_from":"","custom_price_to":""},"activity_transfer_pattern":{}}',
                       ,
                       httr::add_headers(
                         .headers=c(
                           "accept" =  "*/*",
                           "accept-language" = "en-CA,en-GB;q=0.9,en-US;q=0.8,en;q=0.7",
                           "content-type" =  "application/json;charset=utf-8",
                           "flyio-debug" =  "doit",
                           "page_info" = page_info
                         ))
  )
  
  
  resultjson <- httr::content(result, encoding="utf-8", type="text/json")  
  resultparsed <- jsonlite::fromJSON(resultjson)
  return(resultparsed)
  
}


process_page <- function(page_data){
  dplyr::as_tibble(page_data$body$activity_items)
}

get_total_pages <- function() {
  pageinfo <- scrape_page(1)
  num_pages <- pageinfo$headers$page_info$total_page
  return (num_pages)
}

scrape_all_pages <- function(){
  message("Finding total number of pages...")
  num_pages <- get_total_pages()
  message("There are ", num_pages, " pages in total.")
  
  pb <- progress::progress_bar$new(total = num_pages)
  results_list <- list()  
  for (i in 1:num_pages) {
    pb$tick()
    
    page_data <- scrape_page(i)
    results_list[[i]] <- page_data
  }
  
  save(results_list, file=paste0("output/results_raw_",Sys.Date(),".Rdata"))
  
  results_df <- purrr::map_df(results_list, process_page)
  results_final <- results_df |>
    dplyr::mutate(location = location$label) |>
    dplyr::select(-action_link, -fee, -urgent_message, -age_min_week, -age_min_month, 
                  -age_max_week, -age_max_month, -item_type, -num_of_sub_activities, 
                  -sub_activity_ids, -show_new_flag, -only_one_day, -already_enrolled,
                  -dplyr::starts_with("search_from"), -show_wish_list, -parent_activity,
                  -dplyr::starts_with("allow"), -wish_list_id, -max_grade, -min_grade,
                  -date_range_description) |>
    dplyr::select(name, ages, location, dplyr::everything())
  
  return(results_final)
}
