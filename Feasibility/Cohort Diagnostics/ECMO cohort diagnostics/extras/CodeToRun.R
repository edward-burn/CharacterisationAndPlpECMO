
# make sure you have the following OHDSI packages installed
# devtools::install_github("OHDSI/DatabaseConnector")
# devtools::install_github("OHDSI/FeatureExtraction)
# devtools::install_github("OHDSI/CohortDiagnostics")

# some extra packages are also required for this study
#install.packages("zip")
#install.packages("DiagrammeR")
#install.packages("htmltools")
#install.packages("webshot")


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


# Run the cohorttDiagnostics followed by an extra file for plots and tables 
#The results will be stored in the diagnosticsExport subfolder of the outputFolder. 
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
                     minCellCount = 10)
source(file.path("extras","table 1.R"))

# for a given dataset you will have two zip files with results ready to share
# first with generic cohort diagnostics,
# second with a study specific tables and figures
