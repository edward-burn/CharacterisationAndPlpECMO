

# fix to runOrphanConcepts on develop branch of CohortDiagnostics
# devtools::install_github("OHDSI/CohortDiagnostics", ref = "develop")

# Load the package
library(DiagECMO)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "C:/FFtemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()


# Details for connecting to the server:
# connectionDetails <-

# For Oracle: define a schema that can be used to emulate temp tables:
# oracleTempSchema <- NULL

# # Details specific to the database:
# cdmDatabaseSchema <- 
# cohortDatabaseSchema <- 
# cohortTable <- 
# databaseId <- 
# databaseName <- 
# databaseDescription<-
# 
# outputFolder<- 


# Use this to run the cohorttDiagnostics. The results will be stored in the diagnosticsExport subfolder of the outputFolder. This can be shared between sites.
runCohortDiagnostics(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortTable = cohortTable,
                     oracleTempSchema = oracleTempSchema,
                     outputFolder = outputFolder,
                     databaseId = databaseId,
                     databaseName = databaseName,
                     databaseDescription = databaseDescription,
                     createCohorts = TRUE,
                     runInclusionStatistics = FALSE,
                     runIncludedSourceConcepts = FALSE,
                     runOrphanConcepts = FALSE, 
                     runTimeDistributions = FALSE,
                     runBreakdownIndexEvents = FALSE,
                     runIncidenceRates = FALSE,
                     runCohortOverlap = FALSE,
                     runCohortCharacterization = FALSE,
                     minCellCount = 0)

# To view the results:
# Optional: if there are results zip files from multiple sites in a folder, this merges them, which will speed up starting the viewer:
CohortDiagnostics::preMergeDiagnosticsFiles(file.path(outputFolder, "diagnosticsExport"))

# Use this to view the results. Multiple zip files can be in the same folder. If the files were pre-merged, this is automatically detected: 
CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnosticsExport"))


# To explore a specific cohort in the local database, viewing patient profiles:
CohortDiagnostics::launchCohortExplorer(connectionDetails = connectionDetails,
                                        cdmDatabaseSchema = cdmDatabaseSchema,
                                        cohortDatabaseSchema = cohortDatabaseSchema,
                                        cohortTable = cohortTable,
                                        cohortId = 123)
# Where 123 is the ID of the cohort you wish to inspect.
