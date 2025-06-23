prep_toxdrc <- function (.dataset,
                         .Conc,
                         .Response,
                         .IDcols = NULL,
                         .Rep = NULL,
                         .removeoutliers = c(TRUE, FALSE),
                         .cvflag = c(TRUE, FALSE),
                         .solventcheck = c(TRUE, FALSE),
                         .blankcorrect = c(TRUE, FALSE),
                         .normalizeresponse = c(TRUE, FALSE),
                         .averageresponse = c(TRUE, FALSE),
                         .validityflag_lvl = 0.1,
                         .cvflag_lvl = 30) {
  .removeoutliers <- match.arg(.removeoutliers)
  .cvflag <- match.arg(.cvflag)
  .checksolvent <- match.arg(.checksolvent)
  .blankcorrect <- match.arg(.blankcorrect)
  .normalizeresponse <- match.arg(.normalizeresponse)
  .averageresponse <- match.arg(.normalizeresponse)
  
  
  
  
  if (.removeoutliers) {
    result <- remove_outliers(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result)
  }
  
  if (.cvflag) {
    result$dataset <- cv_flag(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, flag_lvl = cvflag_lvl)
    IDcols <- c(IDcols, "Note")
  }
  
  if (.solventcheck) {
    result <- solvent_check(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result, flag_lvl = validity_flag)
    IDcols <- c(IDcols, "Validity")
  }
  
  if (.blankcorrect) {
    result <- blank_correct_response(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result)
    Response <- rlang::sym("c_response")  
  }
  
  if (.normalizeresponse) {
    result <- normalize_response(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, list_obj = result)
    Response <- rlang::sym("normalized_response")  
  }
  
  if (.averageresponse) {
    result <- average_response(dataset = result$dataset, Conc = {{.Conc}}, Response = {{.Response}}, keep_cols = IDcols, list_obj = result)
    Response <- rlang::sym("mean_response")  
  }
}
                      

  
