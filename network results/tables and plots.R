
# packages -----
library(dplyr)
library(zip)
library(DiagrammeR)
library(htmltools)
library(webshot)
library(magick)
library(png)
library(grid)
library(gridExtra)
library(ggplot2)


# folders -----
folder.cohortDiagnostics.results<-"C:/Users/Ed/Dropbox/OHDSI/covid/ECMO/GitHub/CharacterisationAndPlpECMO/network results/cohort diagnostics"
folder.table_1_output<-"C:/Users/Ed/Dropbox/OHDSI/covid/ECMO/GitHub/CharacterisationAndPlpECMO/network results/table 1 output"
working.figs_tables<-"C:/Users/Ed/Dropbox/OHDSI/covid/ECMO/GitHub/CharacterisationAndPlpECMO/network results/working figures and tables"
final.figs_tables<-"C:/Users/Ed/Dropbox/OHDSI/covid/ECMO/GitHub/CharacterisationAndPlpECMO/network results/final figures and tables"




# Data sources ----
names<-c("Results_CUIMC", "Results_optumDod",
         "Results_hospital_charge_datamaster" )
title.names<-c("CUIMC", "OPTUM",
               "Hospital Charge Datamaster")
# cohort diagnostics -----
# CohortDiagnostics::launchDiagnosticsExplorer(
#   "C:/Users/Ed/Dropbox/OHDSI/covid/ECMO/network results/cohort diagnostics")

# Figure: Study inclusion flowchart  -----
# flow charts
for(i in 1:length(names)){

inclusion<-read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[i], ".zip")), "inclusion_rule_stats.csv"))


flowchart<-"digraph flowchart {

# node definitions with substituted label text
node [fontname = Helvetica, shape = rectangle,  width = 0.05, height = 0.225]
tab1 [label = 'ECMO  (n: n.ecmo)']
tab2 [label = 'Age 18 or older  (n: n.age)']
tab3 [label = 'With 30 days of prior history (n: n.prior)']
tab4 [label = 'With ARDS (n: n.ARDS)']
tab5 [label = 'No transplant (n: n.trans)']
tab6 [label = 'No lung disease (n: n.lung)']
tab7 [label = 'No chest trauma (n: n.chest)']
tab8 [label = 'No pneumonectomy (n: n.pneum)']
tab9 [label = 'No pulmonary embolism (n: n.pe)']
tab10 [label = 'No cardiac procedure (n: n.card)']
tab11 [label = 'With pneumonia (n: n.pneu)']

# edge definitions with the node IDs
tab1 -> tab2 -> tab3 -> tab4 -> tab5-> tab6 -> tab7 -> tab8-> tab9 -> tab10 -> tab11;
}"

grViz(flowchart)


start.n<- as.numeric(inclusion %>% 
  filter(cohort_id==1) %>% 
  select(total_subjects))
flowchart<-gsub("n.ecmo", start.n , flowchart)

#age18
age18<-as.numeric(inclusion %>% 
  filter(cohort_id==1) %>% 
  select(remain_subjects))
flowchart<-gsub("n.age", age18 , flowchart)


# rest from  cohort_id 4
inclusion<-inclusion %>%
  filter(cohort_id==4) %>%
  select("rule_name", "remain_subjects")

inclusion$remain_subjects<- ifelse(
  inclusion$remain_subjects== "-10",
  paste0("\u2264", "10"),
  as.character(inclusion$remain_subjects))


flowchart<-gsub("n.prior", inclusion$remain_subjects[1] , flowchart)
flowchart<-gsub("n.ARDS", inclusion$remain_subjects[2] , flowchart)
flowchart<-gsub("n.trans", inclusion$remain_subjects[4] , flowchart)
flowchart<-gsub("n.lung", inclusion$remain_subjects[5] , flowchart)
flowchart<-gsub("n.chest", inclusion$remain_subjects[6] , flowchart)
flowchart<-gsub("n.pneum", inclusion$remain_subjects[8] , flowchart)
flowchart<-gsub("n.pe", inclusion$remain_subjects[9] , flowchart)
flowchart<-gsub("n.card", inclusion$remain_subjects[10] , flowchart)
flowchart<-gsub("n.pneu", inclusion$remain_subjects[11] , flowchart)

grViz(flowchart, height = '100%', width = '100%') %>% html_print(viewer=NULL) %>%
   webshot(file.path(working.figs_tables,
                     paste0(names[i],".inlusion.png")),
           zoom=2)

# remove whitespace
img<- image_read(file.path(working.figs_tables,
                     paste0(names[i],".inlusion.png")))

img<-image_crop(img, geometry_area(850, 1529, 600))

image_write(img, file.path(working.figs_tables,
                     paste0(names[i],".inlusion.png")))

}


# add title and combine plots 
img1 <- readPNG(file.path(working.figs_tables,
                      paste0(names[1],".inlusion.png")))
title1<-textGrob(title.names[1], gp=gpar(fontsize = 10,fontface="bold"))
plot1<-grid.arrange(rasterGrob(img1),
             top = title1,
             padding = unit(1, "line"))
ggsave(file.path(working.figs_tables,
                      paste0(names[1],".inlusion1.png")),
          plot1)

img<- image_read(file.path(working.figs_tables,
                      paste0(names[1],".inlusion1.png")))
img<-image_crop(img, geometry_area(700, 1343, 550))

image_write(img, file.path(working.figs_tables,
                     paste0(names[1],".inlusion1.png")))


#
img2 <- readPNG(file.path(working.figs_tables,
                      paste0(names[2],".inlusion.png")))
title2<-textGrob(title.names[2], gp=gpar(fontsize = 10,fontface="bold"))
plot2<-grid.arrange(rasterGrob(img2),
             top = title2,
             padding = unit(1, "line"))
ggsave(file.path(working.figs_tables,
                      paste0(names[2],".inlusion1.png")),
          plot2)
img<- image_read(file.path(working.figs_tables,
                      paste0(names[2],".inlusion1.png")))
img<-image_crop(img, geometry_area(700, 1343, 550))
image_write(img, file.path(working.figs_tables,
                     paste0(names[2],".inlusion1.png")))


img3 <- readPNG(file.path(working.figs_tables,
                      paste0(names[3],".inlusion.png")))
title2<-textGrob(title.names[3], gp=gpar(fontsize = 10,fontface="bold"))
plot2<-grid.arrange(rasterGrob(img3),
             top = title2,
             padding = unit(1, "line"))
ggsave(file.path(working.figs_tables,
                      paste0(names[3],".inlusion1.png")),
          plot2)
img<- image_read(file.path(working.figs_tables,
                      paste0(names[3],".inlusion1.png")))
img<-image_crop(img, geometry_area(700, 1343, 550))
image_write(img, file.path(working.figs_tables,
                     paste0(names[3],".inlusion1.png")))


#
plot1 <- readPNG(file.path(working.figs_tables,
                      paste0(names[1],".inlusion1.png")))
plot2 <- readPNG(file.path(working.figs_tables,
                      paste0(names[2],".inlusion1.png")))
plot3 <- readPNG(file.path(working.figs_tables,
                      paste0(names[3],".inlusion1.png")))
plot<-grid.arrange(rasterGrob(plot1),
             rasterGrob(plot2),
             rasterGrob(plot3),
             nrow=1) 
ggsave(paste0(final.figs_tables,  
              "/inclusion_flow_charts.png"), 
       plot)


# Table 1: Patient characteristics -----


# some differences in vars recorded ....
table.1.CUIMC<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[1],"_plots_tables", ".zip")), 
             "table.1.csv"),
             col.names=c("Characteristic", "CUIMC"),
             stringsAsFactors = FALSE)
table.1.CUIMC.bin<-table.1.CUIMC[1:57,]
  
table.1.CUIMC.cont<-table.1.CUIMC[60:83,]
#age
table.1.CUIMC.cont<-data.frame(
Characteristic=c(
  "Age (median [IQR])",
  "Charlson score (median [IQR])",
  "Hospital Frailty Risk Score (median [IQR])"),
CUIMC=c(
# age
paste0(table.1.CUIMC.cont[14,2], " [", table.1.CUIMC.cont[13,2], " to ",  table.1.CUIMC.cont[15,2], "]"),
# charlson
paste0(table.1.CUIMC.cont[6,2], " [", table.1.CUIMC.cont[5,2], " to ",  table.1.CUIMC.cont[7,2], "]"),
# hopital fraility
paste0(table.1.CUIMC.cont[22,2], " [", table.1.CUIMC.cont[21,2], " to ",  table.1.CUIMC.cont[23,2], "]")
))

table.1.CUIMC.bin$Characteristic<-
c(paste0(table.1.CUIMC.bin$Characteristic[1], " (%)"  ),
 table.1.CUIMC.bin$Characteristic[2],
  paste0(table.1.CUIMC.bin$Characteristic[3:22], " (%)"  ),
  table.1.CUIMC.bin$Characteristic[23],
  paste0(table.1.CUIMC.bin$Characteristic[24:32], " (%)"  ),
  table.1.CUIMC.bin$Characteristic[33],
  paste0(table.1.CUIMC.bin$Characteristic[34:38], " (%)"  ),
  table.1.CUIMC.bin$Characteristic[39],
  paste0(table.1.CUIMC.bin$Characteristic[40:57], " (%)"  ))


table.1.CUIMC<-rbind(table.1.CUIMC.bin,
      table.1.CUIMC.cont)
rm(table.1.CUIMC.bin, table.1.CUIMC.cont)





# optum
table.1.optum<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[2],"_plots_tables", ".zip")), 
             "table.1.csv"),
             col.names=c("Characteristic", "optum"),
             stringsAsFactors = FALSE)
table.1.optum.bin<-table.1.optum[1:67,]
  
table.1.optum.cont<-table.1.optum[70:93,]
#age
table.1.optum.cont<-data.frame(
Characteristic=c(
  "Age (median [IQR])",
  "Charlson score (median [IQR])",
  "Hospital Frailty Risk Score (median [IQR])"),
optum=c(
# age
paste0(table.1.optum.cont[14,2], " [", table.1.optum.cont[13,2], " to ",  table.1.optum.cont[15,2], "]"),
# charlson
paste0(table.1.optum.cont[6,2], " [", table.1.optum.cont[5,2], " to ",  table.1.optum.cont[7,2], "]"),
# hopital fraility
paste0(table.1.optum.cont[22,2], " [", table.1.optum.cont[21,2], " to ",  table.1.optum.cont[23,2], "]")
))

table.1.optum.bin$Characteristic<-
c(paste0(table.1.optum.bin$Characteristic[1], " (%)"  ),
 table.1.optum.bin$Characteristic[2],
  paste0(table.1.optum.bin$Characteristic[3:27], " (%)"  ),
  table.1.optum.bin$Characteristic[28],
  paste0(table.1.optum.bin$Characteristic[29:37], " (%)"  ),
  table.1.optum.bin$Characteristic[38],
  paste0(table.1.optum.bin$Characteristic[39:47], " (%)"  ),
  table.1.optum.bin$Characteristic[48],
  paste0(table.1.optum.bin$Characteristic[49:67], " (%)"  ))


table.1.optum<-rbind(table.1.optum.bin,
      table.1.optum.cont)
rm(table.1.optum.bin, table.1.optum.cont)





# datamaster
table.1.datamaster<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[3],"_plots_tables", ".zip")), 
             "table.1.csv"),
             col.names=c("Characteristic", "datamaster"),
             stringsAsFactors = FALSE)
table.1.datamaster.bin<-table.1.datamaster[1:61,]
  
table.1.datamaster.cont<-table.1.datamaster[64:87,]
#age
table.1.datamaster.cont<-data.frame(
Characteristic=c(
  "Age (median [IQR])",
  "Charlson score (median [IQR])",
  "Hospital Frailty Risk Score (median [IQR])"),
datamaster=c(
# age
paste0(table.1.datamaster.cont[14,2], " [", table.1.datamaster.cont[13,2], " to ",  table.1.datamaster.cont[15,2], "]"),
# charlson
paste0(table.1.datamaster.cont[6,2], " [", table.1.datamaster.cont[5,2], " to ",  table.1.datamaster.cont[7,2], "]"),
# hopital fraility
paste0(table.1.datamaster.cont[22,2], " [", table.1.datamaster.cont[21,2], " to ",  table.1.datamaster.cont[23,2], "]")
))

table.1.datamaster.bin$Characteristic<-
c(paste0(table.1.datamaster.bin$Characteristic[1], " (%)"  ),
 table.1.datamaster.bin$Characteristic[2],
  paste0(table.1.datamaster.bin$Characteristic[3:23], " (%)"  ),
  table.1.datamaster.bin$Characteristic[24],
  paste0(table.1.datamaster.bin$Characteristic[25:33], " (%)"  ),
  table.1.datamaster.bin$Characteristic[34],
  paste0(table.1.datamaster.bin$Characteristic[35:41], " (%)"  ),
  table.1.datamaster.bin$Characteristic[42],
  paste0(table.1.datamaster.bin$Characteristic[43:61], " (%)"  ))


table.1.datamaster<-rbind(table.1.datamaster.bin,
      table.1.datamaster.cont)
rm(table.1.datamaster.bin, table.1.datamaster.cont)



#combine

# some missing...
# table.1.optum %>% 
# anti_join(table.1.datamaster,
#           by="Characteristic")
# 
# table.1.optum %>% 
# anti_join(table.1.CUIMC,
#           by="Characteristic")


table.1<- table.1.optum %>% 
          inner_join(table.1.datamaster,
              by="Characteristic")
table.1<- table.1 %>% 
          inner_join(table.1.CUIMC,
              by="Characteristic")


# 
table.1<-rbind(table.1[56,],
table.1[1,],
table.1[57:58,],
table.1[2:55,])


# reduce
table.1<-table.1 %>% 
  filter(Characteristic %in%
        c("Age (median [IQR])",
          "Gender: female (%)",
          "Charlson score (median [IQR])",
          "Hospital Frailty Risk Score (median [IQR])",
          "Medical history: General",
          "  Atrial fibrillation (%)",
          "  Acute respiratory disease (%)",
          "  Cerebrovascular disease (%)",
          "  Chronic liver disease (%)",
          "  Chronic obstructive lung disease (%)",
          "  Gastroesophageal reflux disease (%)",
          "  Gastrointestinal hemorrhage (%)",
          "  Heart disease (%)",
          "  Heart failure (%)",
          "  Hyperlipidemia (%)",
          "  Hypertensive disorder (%)",
          "  Malignant neoplastic disease (%)",
          "  Peripheral vascular disease (%)",
          "  Pneumonia (%)",
          "  Renal impairment (%)",
          "  Urinary tract infectious disease (%)",
          "  Venous thrombosis (%) ") )

table.1<-table.1 %>% 
  select(Characteristic,
         CUIMC, optum, datamaster)

table.1<-rbind(
  data.frame(
Characteristic="n",
CUIMC=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[1], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects)),
optum=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[2], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects)),
datamaster=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[3], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects))),
table.1)

save(table.1, 
     file = paste0(final.figs_tables, "/table.1.Rdata"))

# Appendix table 1s ----

table.1.CUIMC.age_30.day_comparison<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[1],"_plots_tables", ".zip")), 
             "table.1.age_30.day_comparison.csv"),
             col.names=c("Characteristic", "CUIMC_included_ECMO",  "CUIMC_all_ECMO", "SMD"),
             stringsAsFactors = FALSE)
table.1.CUIMC.age_30.day_comparison 
