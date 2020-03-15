
library(CohortDiagnostics)
library(here)


# setup
#connectionDetails <-
#cdmDatabaseSchema <- "omop"
#oracleTempSchema <- NULL
#cohortDatabaseSchema <- "results"
#cohortTable <- "ECMO"
#databaseId <- "SIDIAP"

#baseUrl <- "http://10.80.192.24:8080/WebAPI"

ROhdsiWebApi::insertCohortDefinitionSetInPackage(
  fileName = here("data", "exposureCohorts1.csv"),
  "http://10.80.192.24:8080/WebAPI",
  jsonFolder = "json",
  sqlFolder = "sql",
  rFileName = "R/CreateCohorts.R",
  insertTableSql = TRUE,
  insertCohortCreationR = FALSE,
  generateStats = FALSE,
  "CohortDiagnosticsECMO"
)


trace(CohortDiagnostics, edit=TRUE)

environment(loadCohortsFromPackage)


loadCohortsFromPackage
runCohortDiagnostics(
  packageName = "CohortDiagnosticsECMO",
  cohortToCreateFile = "./data", #here("data", "exposureCohorts1.csv"),
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




#cohortSetReference <- read.csv(here("data", "exposureCohorts.csv"),sep=";")
createCohortTable(connectionDetails = connectionDetails,
                  cohortDatabaseSchema = cohortDatabaseSchema,
                  cohortTable = cohortTable)

instantiateCohortSet(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     oracleTempSchema = oracleTempSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortTable = cohortTable,
                     baseUrl = baseUrl,
                     cohortSetReference = cohortSetReference,
                     generateInclusionStats = TRUE,
                     inclusionStatisticsFolder = here("results"))

runCohortDiagnostics(baseUrl = baseUrl,
                     cohortSetReference = cohortSetReference,
                     connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     oracleTempSchema = oracleTempSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortTable = cohortTable,
                     inclusionStatisticsFolder = inclusionStatisticsFolder,
                     exportFolder = here("results"),
                     databaseId = databaseId,
                     runInclusionStatistics = TRUE,
                     runIncludedSourceConcepts = TRUE,
                     runOrphanConcepts = TRUE,
                     runTimeDistributions = TRUE,
                     runBreakdownIndexEvents = TRUE,
                     runIncidenceRate = TRUE,
                     runCohortOverlap = TRUE,
                     runCohortCharacterization = TRUE,
                     minCellCount = 5)

preMergeDiagnosticsFiles("C:/temp/allZipFiles")
launchDiagnosticsExplorer("C:/temp/allZipFiles")
