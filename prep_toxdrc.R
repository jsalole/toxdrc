prep_toxdrc <- function (.dataset,
                         .Conc,
                         .Response,
                         .IDcols = NULL,
                         .removeoutliers = TRUE,
                         .cvflag = TRUE,
                         .solventcheck = TRUE,
                         .blankcorrect = TRUE,
                         .normalizeresponse = TRUE,
                         .averageresponse = TRUE,
                         .validityflag_lvl = 0.1,
                         .cvflag_lvl = 30,
                         return_type = c("separate", "combined")) {
  
  return_type <- match.arg(return_type)
  
  # First: split and name the list
  split_list <- split(.dataset, interaction(.dataset[.IDcols], drop = TRUE))
  
  # Then: apply processing with naming
  results_list <- lapply(names(split_list), function(name) {
    subset <- split_list[[name]]
    result <- list(dataset = subset)
    
    if (.removeoutliers) {
      result <- remove_outliers(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result)
    }
    
    if (.cvflag) {
      result$dataset <- cv_flag(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, flag_lvl = .cvflag_lvl)
      .IDcols <- c(.IDcols, "Note")
    }
    
    if (.solventcheck) {
      result <- solvent_check(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result, flag_lvl = .validityflag_lvl)
      .IDcols <- c(.IDcols, "Validity")
    }
    
    if (.blankcorrect) {
      result <- blank_correct_response(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result)
      .Response <- rlang::sym("c_response")
    }
    
    if (.normalizeresponse) {
      result <- normalize_response(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result)
      .Response <- rlang::sym("normalized_response")
    }
    
    if (.averageresponse) {
      result <- average_response(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, keep_cols = .IDcols, list_obj = result)
      .Response <- rlang::sym("mean_response")
    }
    
    result$ID <- name
    return(result)
  })
  
  names(results_list) <- names(split_list)
  
  if (return_type == "combined") {
    combined_dataset <- dplyr::bind_rows(lapply(results_list, function(x) x$dataset))
    return(combined_dataset)
  } else {
    return(results_list)
  }
}

