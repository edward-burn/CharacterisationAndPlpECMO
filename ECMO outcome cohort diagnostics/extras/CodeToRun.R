## Make sure to install all dependencies (not needed if already done):
# install.packages("SqlRender")
# install.packages("DatabaseConnector")
# install.packages("ggplot2")
# install.packages("ParallelLogger")
# install.packages("readr")
# install.packages("tibble")
# install.packages("dplyr")
# install.packages("RJSONIO")
# install.packages("devtools")
# devtools::install_github("OHDSI/FeatureExtraction")
# devtools::install_github("OHDSI/ROhdsiWebApi")
# devtools::install_github("OHDSI/CohortDiagnostics")


# Load the package
library(OutcomesECMO)

# Optional: specify where the temporary files (used by the ff package) will be created:
#options(fftempdir = "s:/FFtemp")

# Maximum number of cores to be used:
#maxCores <- parallel::detectCores()


# Details for connecting to the server:
#connectionDetails <- DatabaseConnector::createConnectionDetails()



# Details specific to the database:
# outputFolder <- ""
# cdmDatabaseSchema <- ""
# cohortDatabaseSchema <- ""
# cohortTable <- ""
# databaseId <- ""
# databaseName <- ""
# databaseDescription <-  ""

#oracleTempSchema <- NULL # For Oracle: define a schema that can be used to emulate temp tables:



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
                     runOrphanConcepts = TRUE,
                     runTimeDistributions = TRUE,
                     runBreakdownIndexEvents = TRUE,
                     runIncidenceRates = TRUE,
                     runCohortOverlap = TRUE,
                     runCohortCharacterization = TRUE,
                     minCellCount = 10)

# To view the results
#CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnosticsExport"))



