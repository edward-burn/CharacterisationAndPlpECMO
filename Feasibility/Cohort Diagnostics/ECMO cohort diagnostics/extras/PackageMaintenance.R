# Copyright 2019 Observational Health Data Sciences and Informatics
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

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("DiagECMO")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
shell("rm extras/DiagECMO.pdf")
shell("R CMD Rd2pdf ./ --output=extras/DiagECMO.pdf")


# Insert cohort definitions from ATLAS into package -----------------------
cohortGroups <- read.csv("inst/settings/CohortGroups.csv")
for (i in 1:nrow(cohortGroups)) {
  ParallelLogger::logInfo("* Importing cohorts in group: ", cohortGroups$cohortGroup[i], " *")
  ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = file.path("inst", cohortGroups$fileName[i]),
                                                   baseUrl = Sys.getenv("baseUrl"),
                                                   insertTableSql = TRUE,
                                                   insertCohortCreationR = FALSE,
                                                   generateStats = TRUE,
                                                   packageName = "DiagECMO")
}
unlink("inst/cohorts/InclusionRules.csv")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("DiagECMO")
