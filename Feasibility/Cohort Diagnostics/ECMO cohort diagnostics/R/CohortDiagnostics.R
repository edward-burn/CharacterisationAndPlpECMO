# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of DiagECMO
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Get the list of cohort groups
#'
#' @return
#' A character vector of cohort group names included in this package.
#' 
#' @export
getCohortGroups <- function() {
  pathToCsv <- system.file("settings", "CohortGroups.csv", package = "DiagECMO")
  cohortGroups <- readr::read_csv(pathToCsv, col_types = readr::cols())
  return(cohortGroups$cohortGroup)
}

#' Execute the cohort diagnostics
#'
#' @details
#' This function executes the cohort diagnostics.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param databaseId           A short string for identifying the database (e.g.
#'                             'Synpuf').
#' @param databaseName         The full name of the database (e.g. 'Medicare Claims
#'                             Synthetic Public Use Files (SynPUFs)').
#' @param databaseDescription  A short description (several sentences) of the database.
#' @param createCohorts        Create the cohortTable table with the exposure and outcome cohorts?
#' @param runInclusionStatistics      Generate and export statistic on the cohort incusion rules?
#' @param runIncludedSourceConcepts   Generate and export the source concepts included in the cohorts?
#' @param runOrphanConcepts           Generate and export potential orphan concepts?
#' @param runTimeDistributions        Generate and export cohort time distributions?
#' @param runBreakdownIndexEvents     Generate and export the breakdown of index events?
#' @param runIncidenceRates      Generate and export the cohort incidence rates?
#' @param runCohortOverlap            Generate and export the cohort overlap?
#' @param runCohortCharacterization   Generate and export the cohort characterization?
#' @param minCellCount         The minimum number of subjects contributing to a count before it can be included 
#'                             in packaged results.
#'
#' @export
runCohortDiagnostics <- function(connectionDetails,
                                 cdmDatabaseSchema,
                                 cohortDatabaseSchema = cdmDatabaseSchema,
                                 cohortTable = "cohort",
                                 oracleTempSchema = cohortDatabaseSchema,
                                 outputFolder,
                                 databaseId = "Unknown",
                                 databaseName = "Unknown",
                                 databaseDescription = "Unknown",
                                 cohortGroups = getCohortGroups(),
                                 createCohorts = TRUE,
                                 runInclusionStatistics = TRUE,
                                 runIncludedSourceConcepts = TRUE,
                                 runOrphanConcepts = TRUE,
                                 runTimeDistributions = TRUE,
                                 runBreakdownIndexEvents = TRUE,
                                 runIncidenceRates = TRUE,
                                 runCohortOverlap = TRUE,
                                 runCohortCharacterization = TRUE,
                                 minCellCount = 5) {
  if (!file.exists(outputFolder)){
    dir.create(outputFolder, recursive = TRUE)
  }
  if (!is.null(getOption("fftempdir")) && !file.exists(getOption("fftempdir"))) {
    warning("fftempdir '", getOption("fftempdir"), "' not found. Attempting to create folder")
    dir.create(getOption("fftempdir"), recursive = TRUE)
  }
  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "cohortDiagnosticsLog.txt"))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT"))
  
  pathToCsv <- system.file("settings", "CohortGroups.csv", package = "DiagECMO")
  temp <- readr::read_csv(pathToCsv, col_types = readr::cols())
  cohortGroups <- temp[temp$cohortGroup %in% cohortGroups, ]
  rm(temp)
  if (nrow(cohortGroups) == 0) {
    stop("No valid cohort groups seleted") 
  }
  cohortGroups$outputFolder <- file.path(outputFolder, cohortGroups$cohortGroup)
  lapply(cohortGroups$outputFolder[!file.exists(cohortGroups$outputFolder)], dir.create, recursive = TRUE)
  cohortGroups$incrementalFolder <- file.path(cohortGroups$outputFolder, "RecordKeeping")
  cohortGroups$inclusionStatisticsFolder <- file.path(cohortGroups$outputFolder, "InclusionStatistics")
  cohortGroups$exportFolder <- file.path(cohortGroups$outputFolder, "Export")
  
  if (createCohorts) {
    for (i in 1:nrow(cohortGroups)) {
      ParallelLogger::logInfo("Creating cohorts for cohort group ", cohortGroups$cohortGroup[i])
      CohortDiagnostics::instantiateCohortSet(connectionDetails = connectionDetails,
                                              cdmDatabaseSchema = cdmDatabaseSchema,
                                              cohortDatabaseSchema = cohortDatabaseSchema,
                                              cohortTable = cohortTable,
                                              oracleTempSchema = oracleTempSchema,
                                              packageName = "DiagECMO",
                                              cohortToCreateFile = cohortGroups$fileName[i],
                                              createCohortTable = TRUE,
                                              generateInclusionStats = TRUE,
                                              inclusionStatisticsFolder = cohortGroups$inclusionStatisticsFolder[i],
                                              incremental = TRUE,
                                              incrementalFolder = cohortGroups$incrementalFolder[i])
      
    }
  }
  
  for (i in 1:nrow(cohortGroups)) {
    ParallelLogger::logInfo("Running cohort diagnostics for cohort group", cohortGroups$cohortGroup[i])
    CohortDiagnostics::runCohortDiagnostics(packageName = "DiagECMO",
                                            cohortToCreateFile = cohortGroups$fileName[i],
                                            connectionDetails = connectionDetails,
                                            cdmDatabaseSchema = cdmDatabaseSchema,
                                            oracleTempSchema = oracleTempSchema,
                                            cohortDatabaseSchema = cohortDatabaseSchema,
                                            cohortTable = cohortTable,
                                            inclusionStatisticsFolder = cohortGroups$inclusionStatisticsFolder[i],
                                            exportFolder = cohortGroups$exportFolder[i],
                                            databaseId = databaseId,
                                            databaseName = databaseName,
                                            databaseDescription = databaseDescription,
                                            runInclusionStatistics = runInclusionStatistics,
                                            runIncludedSourceConcepts = runIncludedSourceConcepts,
                                            runOrphanConcepts = runOrphanConcepts,
                                            runTimeDistributions = runTimeDistributions,
                                            runBreakdownIndexEvents = runBreakdownIndexEvents,
                                            runIncidenceRate = runIncidenceRates,
                                            runCohortOverlap = runCohortOverlap,
                                            runCohortCharacterization = runCohortCharacterization,
                                            minCellCount = minCellCount,
                                            incremental = TRUE,
                                            incrementalFolder = cohortGroups$incrementalFolder[i])
  }

  # Combine zip files -------------------------------------------------------------------------------
  ParallelLogger::logInfo("Combining zip files")
  zipName <- file.path(outputFolder, paste0("AllResults_", databaseId, ".zip"))
  files <- list.files(cohortGroups$exportFolder, pattern = ".*\\.zip$", full.names = TRUE)
  oldWd <- setwd(outputFolder)
  on.exit(setwd(oldWd), add = TRUE)
  DatabaseConnector::createZipFile(zipFile = zipName, files = files)
  ParallelLogger::logInfo("Results are ready for sharing at:", zipName)
  
  ParallelLogger::logFatal("Done")
}