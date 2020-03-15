
library(CohortDiagnosticsECMO)


# setup
options(fftempdir = "C:/fftemp")

connectionDetails <- Eunomia::getEunomiaConnectionDetails("c:/temp/cdm.sqlite")
cdmDatabaseSchema <- "main"
cohortDatabaseSchema <- "main"
oracleTempSchema <- NULL
cohortTable <- "ECMO"
databaseId <- "Eunomia"

outputFolder<- here::here("results")

#connectionDetails <-
# cdmDatabaseSchema <- "omop"
# oracleTempSchema <- NULL
# cohortDatabaseSchema <- "results"
# cohortTable <- "ECMO"
# databaseId <- "SIDIAP"

CohortDiagnostics::createCohortTable(
  connectionDetails,
  cohortDatabaseSchema,
  cohortTable,
  createInclusionStatsTables = FALSE,
  resultsDatabaseSchema = cohortDatabaseSchema,
  cohortInclusionTable = paste0(cohortTable, "_inclusion"),
  cohortInclusionResultTable = paste0(cohortTable, "_inclusion_result"),
  cohortInclusionStatsTable = paste0(cohortTable, "_inclusion_stats"),
  cohortSummaryStatsTable = paste0(cohortTable, "_summary_stats")
)

CohortDiagnostics::instantiateCohort(
  connectionDetails,
  cdmDatabaseSchema,
  oracleTempSchema ,
  cohortDatabaseSchema ,
  cohortTable ,
  cohortJson = "inst/cohorts/ECMO.json",
  cohortSql = "inst/sql/sql_server/ECMO.sql",
  cohortId = 1,
  generateInclusionStats = FALSE,
  resultsDatabaseSchema = cohortDatabaseSchema,
  cohortInclusionTable = paste0(cohortTable, "_inclusion"),
  cohortInclusionResultTable = paste0(cohortTable, "_inclusion_result"),
  cohortInclusionStatsTable = paste0(cohortTable, "_inclusion_stats"),
  cohortSummaryStatsTable = paste0(cohortTable, "_summary_stats")
)


runCohortDiagnostics(
  packageName = "CohortDiagnosticsECMO",
  cohortToCreateFile = here("inst", "exposureCohorts.csv"),
  connectionDetails = connectionDetails,
  cdmDatabaseSchema,
  oracleTempSchema,
  cohortDatabaseSchema,
  cohortTable,
  inclusionStatisticsFolder = outputFolder,
  exportFolder=outputFolder,
  databaseId,
  databaseName = databaseId,
  databaseDescription = "",
  runInclusionStatistics = FALSE,
  runIncludedSourceConcepts = FALSE,
  runOrphanConcepts = FALSE,
  runTimeDistributions = FALSE,
  runBreakdownIndexEvents = FALSE,
  runIncidenceRate = FALSE,
  runCohortOverlap = FALSE,
  runCohortCharacterization = FALSE,
  minCellCount = 0
)

runCohortDiagnostics(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortTable = cohortTable,
                     oracleTempSchema = oracleTempSchema,
                     outputFolder = outputFolder,
                     databaseId = databaseId,
                     databaseName = databaseId,
                     databaseDescription = "",
                     runInclusionStatistics = FALSE,
                     createCohorts = TRUE,
                     minCellCount = 5)




CohortDiagnostics::createCohortTable(connectionDetails = connectionDetails,
                  cohortDatabaseSchema = cohortDatabaseSchema,
                  cohortTable = cohortTable)

inclusionStatisticsFolder <- outputFolder

instantiateCohortSet(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     oracleTempSchema = oracleTempSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortTable = cohortTable,
                     baseUrl = baseUrl,
                     cohortSetReference = cohortSetReference,
                     generateInclusionStats = TRUE,
                     inclusionStatisticsFolder = inclusionStatisticsFolder)


runCohortDiagnostics(
  packageName = "CohortDiagnosticsECMO",
#  cohortToCreateFile = "./data", #here("data", "exposureCohorts1.csv"),
 # cohortSetReference = NULL,
  connectionDetails = connectionDetails,
  cdmDatabaseSchema,
  oracleTempSchema ,
  cohortDatabaseSchema,
  cohortTable,
  cohortIds = NULL,
  inclusionStatisticsFolder = here("results"),
  exportFolder=here("results"),
  databaseId,
  databaseName = databaseId,
  databaseDescription = "",
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = FALSE,
  runOrphanConcepts = FALSE,
  runTimeDistributions = FALSE,
  runBreakdownIndexEvents = FALSE,
  runIncidenceRate = FALSE,
  runCohortOverlap = FALSE,
  runCohortCharacterization = FALSE,
  minCellCount = 0
)

#baseUrl <- "http://10.80.192.24:8080/WebAPI"



# ROhdsiWebApi::insertCohortDefinitionSetInPackage(
#   fileName = here("data", "exposureCohorts1.csv"),
#   "http://10.80.192.24:8080/WebAPI",
#   jsonFolder = "json",
#   sqlFolder = "sql",
#   rFileName = "R/CreateCohorts.R",
#   insertTableSql = TRUE,
#   insertCohortCreationR = FALSE,
#   generateStats = FALSE,
#   "CohortDiagnosticsECMO"
# )

#
# trace(CohortDiagnostics, edit=TRUE)
#
# environment(loadCohortsFromPackage)
#
#
# loadCohortsFromPackage
# runCohortDiagnostics(
#   packageName = "CohortDiagnosticsECMO",
#   cohortToCreateFile = "./data", #here("data", "exposureCohorts1.csv"),
#  # cohortSetReference = NULL,
#   connectionDetails = connectionDetails,
#   cdmDatabaseSchema,
#   oracleTempSchema ,
#   cohortDatabaseSchema,
#   cohortTable,
#   cohortIds = NULL,
#   inclusionStatisticsFolder = here("results"),
#   exportFolder=here("results"),
#   databaseId,
#   databaseName = databaseId,
#   databaseDescription = "",
#   runInclusionStatistics = TRUE,
#   runIncludedSourceConcepts = FALSE,
#   runOrphanConcepts = FALSE,
#   runTimeDistributions = FALSE,
#   runBreakdownIndexEvents = FALSE,
#   runIncidenceRate = FALSE,
#   runCohortOverlap = FALSE,
#   runCohortCharacterization = FALSE,
#   minCellCount = 0
# )
#
#
#
#
# #cohortSetReference <- read.csv(here("data", "exposureCohorts.csv"),sep=";")
# createCohortTable(connectionDetails = connectionDetails,
#                   cohortDatabaseSchema = cohortDatabaseSchema,
#                   cohortTable = cohortTable)
#
# instantiateCohortSet(connectionDetails = connectionDetails,
#                      cdmDatabaseSchema = cdmDatabaseSchema,
#                      oracleTempSchema = oracleTempSchema,
#                      cohortDatabaseSchema = cohortDatabaseSchema,
#                      cohortTable = cohortTable,
#                      baseUrl = baseUrl,
#                      cohortSetReference = cohortSetReference,
#                      generateInclusionStats = TRUE,
#                      inclusionStatisticsFolder = here("results"))
#
# runCohortDiagnostics(baseUrl = baseUrl,
#                      cohortSetReference = cohortSetReference,
#                      connectionDetails = connectionDetails,
#                      cdmDatabaseSchema = cdmDatabaseSchema,
#                      oracleTempSchema = oracleTempSchema,
#                      cohortDatabaseSchema = cohortDatabaseSchema,
#                      cohortTable = cohortTable,
#                      inclusionStatisticsFolder = inclusionStatisticsFolder,
#                      exportFolder = here("results"),
#                      databaseId = databaseId,
#                      runInclusionStatistics = TRUE,
#                      runIncludedSourceConcepts = TRUE,
#                      runOrphanConcepts = TRUE,
#                      runTimeDistributions = TRUE,
#                      runBreakdownIndexEvents = TRUE,
#                      runIncidenceRate = TRUE,
#                      runCohortOverlap = TRUE,
#                      runCohortCharacterization = TRUE,
#                      minCellCount = 5)
#
# preMergeDiagnosticsFiles("C:/temp/allZipFiles")
# launchDiagnosticsExplorer("C:/temp/allZipFiles")
