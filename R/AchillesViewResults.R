#' @title fetchAchillesHeelResult
#'
#' @description
#' \code{fetchAchillesHeelResult} retrieves the AchillesHeel results for the AChilles analysis to identify potential data quality issues.
#' 
#' @details
#' AchillesHeel is a part of the Achilles analysis aimed at identifying potential data quality issues. It will list errors (things
#' that should really be fixed) and warnings (things that should at least be investigated).
#'
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param resultsSchema		Name of database schema containing the Achilles descriptive statistics. 
#' 
#' @return A table listing all identified issues 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   fetchAchillesHeelResult(connectionDetails, "scratch")
#' }
#' @export
fetchAchillesHeelResult <- function (connectionDetails, resultsSchema){
  connectionDetails$schema = resultsSchema
  conn <- connect(connectionDetails)
  
  sql <- "SELECT * FROM ACHILLES_HEEL_results"
  issues <- dbGetQuery(conn,sql)
  
  dummy <- dbDisconnect(conn)
  
  issues
}

#' @title fetchAchillesAnalysisResults
#'
#' @description
#' \code{fetchAchillesAnalysisResults} returns the results for one Achilles analysis Id.
#' 
#' @details
#' See \code{data(analysesDetails)} for a list of all Achilles analyses and their Ids.
#'
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param resultsSchema  	Name of database schema containing the Achilles descriptive statistics. 
#' @param analysisId   A single analysisId
#' 
#' @return An object of type \code{achillesAnalysisResults}
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   fetchAchillesAnalysisResults(connectionDetails, "scratch",106)
#' }
#' @export
fetchAchillesAnalysisResults <- function (connectionDetails, resultsSchema, analysisId){
  connectionDetails$schema = resultsSchema
  conn <- connect(connectionDetails)
  
  sql <- "SELECT * FROM ACHILLES_analysis WHERE analysis_id = @analysisId"
  sql <- renderSql(sql,analysisId = analysisId)$sql
  analysisDetails <- dbGetQuery(conn,sql)
  
  sql <- "SELECT * FROM ACHILLES_results WHERE analysis_id = @analysisId"
  sql <- renderSql(sql,analysisId = analysisId)$sql
  analysisResults <- dbGetQuery(conn,sql)
  
  if (nrow(analysisResults) == 0){
    sql <- "SELECT * FROM ACHILLES_results_dist WHERE analysis_id = @analysisId"
    sql <- renderSql(sql,analysisId = analysisId)$sql
    analysisResults <- dbGetQuery(conn,sql)
  }
  
  colnames(analysisDetails) <- toupper(colnames(analysisDetails))
  colnames(analysisResults) <- toupper(colnames(analysisResults))
  
  for (i in 1:5){
    stratumName <- analysisDetails[,paste("STRATUM",i,"NAME",sep="_")]
    if (is.na(stratumName)){
      analysisResults[,paste("STRATUM",i,sep="_")] <- NULL
    } else {
      colnames(analysisResults)[colnames(analysisResults) == paste("STRATUM",i,sep="_")] <- toupper(stratumName)
    }
  }
  
  dummy <- dbDisconnect(conn)
  
  result <- list(analysisId = analysisId,
                 analysisName = analysisDetails$ANALYSIS_NAME,
                 analysisResults = analysisResults)
  class(result) <- "achillesAnalysisResults"
  result
}
