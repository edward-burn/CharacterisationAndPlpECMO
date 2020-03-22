
#install.packages("zip")
library(zip)

# make sure latest version of CohortDiagnostics is installed 
# devtools::install_github("OHDSI/CohortDiagnostics")

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
                     runInclusionStatistics = TRUE,
                     runIncludedSourceConcepts = TRUE,
                     runOrphanConcepts = FALSE, 
                     runTimeDistributions = TRUE,
                     runBreakdownIndexEvents = TRUE,
                     runIncidenceRates = FALSE,
                     runCohortOverlap = FALSE,
                     runCohortCharacterization = TRUE,
                     minCellCount = 5)

# add bespoke table and figures to results folder
zip::zip_list(file.path(outputFolder, "diagnosticsExport", 
                        paste0("Results_", databaseId, ".zip")))$filename
# nb if this list of files includat any "table.1" please manually delete these from the
# zipped results folder
source(file.path("extras","CodeToRun plots and tables.R"))


# To view the results:
CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnosticsExport"))

