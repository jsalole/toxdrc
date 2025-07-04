run_toxdrc <- function(.dataset,
                       .Conc,
                       .Response,
                       .IDcols = NULL,
                       .Rep = NULL,
                       .removeoutliers = TRUE,
                       .cvflag = TRUE,
                       .solventcheck = TRUE,
                       .blankcorrect = TRUE,
                       .normalizeresponse = TRUE,
                       .averageresponse = TRUE,
                       .validityflag_lvl = 0.1,
                       .cvflag_lvl = 30,
                       .toxic_lvl = 0.7,
                       .if_nontoxic = c("skip", "continue"),
                       .EDx = 0.5,
                       .EDargs = NULL,
                       .return_type = c("separate", "combined")) {
  
  source("~/Desktop/Research/toxdrc/remove_outliers.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/cv_flag.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/solvent_check.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/blank_correct_response.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/normalize_response.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/log_concs.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/average_response.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/is_toxic.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/my_mselect.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/safe_drm.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/fit_models.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/hormesis_validity.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/get_model_concs.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/select_best_model.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/extract_metadata.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/red_button.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/red_button_NT.R", echo=TRUE)
  source("~/Desktop/Research/toxdrc/model_estimates.R", echo=TRUE)
  
  .if_nontoxic <- match.arg(.if_nontoxic)
  .return_type <- match.arg(.return_type)
  
  split_list <- split(.dataset, interaction(.dataset[.IDcols], drop = TRUE))

  results_list <- lapply(names(split_list), function(name) {
    subset <- split_list[[name]]
    result <- list(dataset = subset)
    
    print(result$dataset)
    
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
    
    result <- is_toxic(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result)
    
    if (!result$is_toxic && .if_nontoxic == "skip") {
      result <- extract_metadata(dataset = result$dataset, list_obj = result, ID_cols = .IDcols)
      result$metadata <- red_button_NT(metadata = result$metadata, EDx = .EDx)
      result$ID <- name
      result$metadata$is_toxic <- result$is_toxic
      return(result)
    }
  

    result <- log_concs(dataset = result$dataset, Conc = {{.Conc}}, list_obj = result)
    log_Conc <- rlang::sym("log_Conc")
    
    result <- fit_models(dataset = result$dataset, log_Conc = {{log_Conc}}, Response = {{.Response}}, list_obj = result)
    
    result$dataset <- get_model_concs(dataset = result$dataset, model_df = result$model_df)
    model_Conc <- rlang::sym("model_Conc")
    
    print(str(result$dataset))
    
    result <- select_best_model(dataset = result$dataset, model_Conc = model_Conc, model_df = result$model_df, Response = {{.Response}}, list_obj = result)
    
    print("hello")
    
    result <- extract_metadata(dataset = result$dataset, list_obj = result, ID_cols = c(.IDcols, "Model"))
    
    # Set default EDargs if not provided
    if (is.null(.EDargs)) {
      .EDargs <- list(
        type = "absolute",
        interval = "delta",
        level = 0.95,
        lref = 0,
        uref = 100
      )
    }
    
    result <- model_estimates(
      dataset = result$dataset,
      model = result$dr_model,
      metadata = result$metadata,
      list_obj = result,
      EDx = .EDx,
      EDargs = .EDargs
    )
    
    result$metadata$is_toxic <- result$is_toxic
    
    result$ID <- name
    return(result)
  })
  
  names(results_list) <- names(split_list)
  
  if (.return_type == "combined") {
    combined_metadata <- dplyr::bind_rows(lapply(results_list, function(x) x$metadata))
    return(combined_metadata)
  } else {
    return(results_list)
  }
}


