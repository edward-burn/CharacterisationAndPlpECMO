
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
         "Results_hospital_charge_datamaster", "Results_CCAE", "Results_MDCD", "Results_Panther",
         "Results_Premier" )
title.names<-c("CUIMC", "OPTUM",
               "Hospital CDM", "CCAE", "MDCD", "PanTher",  "PHD")
# cohort diagnostics -----
#CohortDiagnostics::launchDiagnosticsExplorer(folder.cohortDiagnostics.results)

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
for(i in 1:length(names)){
  img1 <- readPNG(file.path(working.figs_tables,
                      paste0(names[i],".inlusion.png")))
title1<-textGrob(title.names[i], gp=gpar(fontsize = 10,fontface="bold"))
plot1<-grid.arrange(rasterGrob(img1),
             top = title1,
             padding = unit(1, "line"))
ggsave(file.path(working.figs_tables,
                      paste0(names[i],".inlusion1.png")),
          plot1)

img<- image_read(file.path(working.figs_tables,
                      paste0(names[i],".inlusion1.png")))
img<-image_crop(img, geometry_area(625, 1343, 575))

image_write(img, file.path(working.figs_tables,
                     paste0(names[i],".inlusion1.png")))
}



# # combine plots
# length(names)
# plot1 <- readPNG(file.path(working.figs_tables,
#                       paste0(names[1],".inlusion1.png")))
# plot2 <- readPNG(file.path(working.figs_tables,
#                       paste0(names[2],".inlusion1.png")))
# plot3 <- readPNG(file.path(working.figs_tables,
#                       paste0(names[3],".inlusion1.png")))
# plot4 <- readPNG(file.path(working.figs_tables,
#                       paste0(names[4],".inlusion1.png")))
# plot<-grid.arrange(rasterGrob(plot1),
#              rasterGrob(plot2),
#              rasterGrob(plot3),
#              rasterGrob(plot4),
#              nrow=1) 
# ggsave(paste0(final.figs_tables,  
#               "/inclusion_flow_charts.png"), 
#        plot)


# Table 1: Patient characteristics -----


# some differences in vars recorded ....
# so will do these one by one ....
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





# CCAE
table.1.ccae<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[4],"_plots_tables", ".zip")), 
             "table.1.csv"),
             col.names=c("Characteristic", "CCAE"),
             stringsAsFactors = FALSE)
table.1.ccae.bin<-table.1.ccae[1:66,]
  
table.1.ccae.cont<-table.1.ccae[69:92,]
#age
table.1.ccae.cont<-data.frame(
Characteristic=c(
  "Age (median [IQR])",
  "Charlson score (median [IQR])",
  "Hospital Frailty Risk Score (median [IQR])"),
CCAE=c(
# age
paste0(table.1.ccae.cont[14,2], " [", table.1.ccae.cont[13,2], " to ",  table.1.ccae.cont[15,2], "]"),
# charlson
paste0(table.1.ccae.cont[6,2], " [", table.1.ccae.cont[5,2], " to ",  table.1.ccae.cont[7,2], "]"),
# hopital fraility
paste0(table.1.ccae.cont[22,2], " [", table.1.ccae.cont[21,2], " to ",  table.1.ccae.cont[23,2], "]")
))

table.1.ccae.bin$Characteristic<-
c(paste0(table.1.ccae.bin$Characteristic[1], " (%)"  ),
 table.1.ccae.bin$Characteristic[2],
  paste0(table.1.ccae.bin$Characteristic[3:27], " (%)"  ),
  table.1.ccae.bin$Characteristic[28],
  paste0(table.1.ccae.bin$Characteristic[29:37], " (%)"  ),
  table.1.ccae.bin$Characteristic[38],
  paste0(table.1.ccae.bin$Characteristic[39:46], " (%)"  ),
  table.1.ccae.bin$Characteristic[47],
  paste0(table.1.ccae.bin$Characteristic[48:66], " (%)"  ))


table.1.ccae<-rbind(table.1.ccae.bin,
      table.1.ccae.cont)
rm(table.1.ccae.bin, table.1.ccae.cont)





# mdcd
table.1.mdcd<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[5],"_plots_tables", ".zip")), 
             "table.1.csv"),
             col.names=c("Characteristic", "mdcd"),
             stringsAsFactors = FALSE)
table.1.mdcd.bin<-table.1.mdcd[1:64,]
  
table.1.mdcd.cont<-table.1.mdcd[67:90,]
#age
table.1.mdcd.cont<-data.frame(
Characteristic=c(
  "Age (median [IQR])",
  "Charlson score (median [IQR])",
  "Hospital Frailty Risk Score (median [IQR])"),
mdcd=c(
# age
paste0(table.1.mdcd.cont[14,2], " [", table.1.mdcd.cont[13,2], " to ",  table.1.mdcd.cont[15,2], "]"),
# charlson
paste0(table.1.mdcd.cont[6,2], " [", table.1.mdcd.cont[5,2], " to ",  table.1.mdcd.cont[7,2], "]"),
# hopital fraility
paste0(table.1.mdcd.cont[22,2], " [", table.1.mdcd.cont[21,2], " to ",  table.1.mdcd.cont[23,2], "]")
))

table.1.mdcd.bin$Characteristic<-
c(paste0(table.1.mdcd.bin$Characteristic[1], " (%)"  ),
 table.1.mdcd.bin$Characteristic[2],
  paste0(table.1.mdcd.bin$Characteristic[3:27], " (%)"  ),
  table.1.mdcd.bin$Characteristic[28],
  paste0(table.1.mdcd.bin$Characteristic[29:37], " (%)"  ),
  table.1.mdcd.bin$Characteristic[38],
  paste0(table.1.mdcd.bin$Characteristic[39:44], " (%)"  ),
  table.1.mdcd.bin$Characteristic[45],
  paste0(table.1.mdcd.bin$Characteristic[46:64], " (%)"  ))


table.1.mdcd<-rbind(table.1.mdcd.bin,
      table.1.mdcd.cont)
rm(table.1.mdcd.bin, table.1.mdcd.cont)










# panther
table.1.panther<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[6],"_plots_tables", ".zip")), 
             "table.1.csv"),
             col.names=c("Characteristic", "panther"),
             stringsAsFactors = FALSE)
table.1.panther.bin<-table.1.panther[1:66,]
  
table.1.panther.cont<-table.1.panther[69:90,]
#age
table.1.panther.cont<-data.frame(
Characteristic=c(
  "Age (median [IQR])",
  "Charlson score (median [IQR])",
  "Hospital Frailty Risk Score (median [IQR])"),
panther=c(
# age
paste0(table.1.panther.cont[14,2], " [", table.1.panther.cont[13,2], " to ",  table.1.panther.cont[15,2], "]"),
# charlson
paste0(table.1.panther.cont[6,2], " [", table.1.panther.cont[5,2], " to ",  table.1.panther.cont[7,2], "]"),
# hopital fraility
paste0(table.1.panther.cont[22,2], " [", table.1.panther.cont[21,2], " to ",  table.1.panther.cont[23,2], "]")
))

table.1.panther.bin$Characteristic<-
c(paste0(table.1.panther.bin$Characteristic[1], " (%)"  ),
 table.1.panther.bin$Characteristic[2],
  paste0(table.1.panther.bin$Characteristic[3:27], " (%)"  ),
  table.1.panther.bin$Characteristic[28],
  paste0(table.1.panther.bin$Characteristic[29:37], " (%)"  ),
  table.1.panther.bin$Characteristic[38],
  paste0(table.1.panther.bin$Characteristic[39:46], " (%)"  ),
  table.1.panther.bin$Characteristic[47],
  paste0(table.1.panther.bin$Characteristic[48:66], " (%)"  ))


table.1.panther<-rbind(table.1.panther.bin,
      table.1.panther.cont)
rm(table.1.panther.bin, table.1.panther.cont)









# premier
table.1.premier<-read.csv2(unz(
             file.path(folder.table_1_output,
             paste0(names[7],"_plots_tables", ".zip")), 
             "table.1.csv"),
             col.names=c("Characteristic", "premier"),
             stringsAsFactors = FALSE)
table.1.premier.bin<-table.1.premier[1:64,]
  
table.1.premier.cont<-table.1.premier[67:90,]
#age
table.1.premier.cont<-data.frame(
Characteristic=c(
  "Age (median [IQR])",
  "Charlson score (median [IQR])",
  "Hospital Frailty Risk Score (median [IQR])"),
premier=c(
# age
paste0(table.1.premier.cont[14,2], " [", table.1.premier.cont[13,2], " to ",  table.1.premier.cont[15,2], "]"),
# charlson
paste0(table.1.premier.cont[6,2], " [", table.1.premier.cont[5,2], " to ",  table.1.premier.cont[7,2], "]"),
# hopital fraility
paste0(table.1.premier.cont[22,2], " [", table.1.premier.cont[21,2], " to ",  table.1.premier.cont[23,2], "]")
))

table.1.premier.bin$Characteristic<-
c(paste0(table.1.premier.bin$Characteristic[1], " (%)"  ),
 table.1.premier.bin$Characteristic[2],
  paste0(table.1.premier.bin$Characteristic[3:27], " (%)"  ),
  table.1.premier.bin$Characteristic[28],
  paste0(table.1.premier.bin$Characteristic[29:37], " (%)"  ),
  table.1.premier.bin$Characteristic[38],
  paste0(table.1.premier.bin$Characteristic[39:45], " (%)"  ),
  table.1.premier.bin$Characteristic[46],
  paste0(table.1.premier.bin$Characteristic[47:64], " (%)"  ))


table.1.premier<-rbind(table.1.premier.bin,
      table.1.premier.cont)
rm(table.1.premier.bin, table.1.premier.cont)








#combine

# some missing...
# table.1.optum %>% 
# anti_join(table.1.datamaster,
#           by="Characteristic")
# 
# table.1.optum %>% 
# anti_join(table.1.CUIMC,
#           by="Characteristic")
# table.1.optum %>%
# anti_join(table.1.ccae,
#           by="Characteristic")
# table.1.optum %>%
# anti_join(table.1.mdcd,
#           by="Characteristic")
# table.1.optum %>%
# anti_join(table.1.panther,
#           by="Characteristic")

table.1<- table.1.optum %>% 
          inner_join(table.1.datamaster,
              by="Characteristic")

table.1<- table.1 %>% 
          inner_join(table.1.CUIMC,
              by="Characteristic")
table.1<- table.1 %>% 
          inner_join(table.1.ccae,
              by="Characteristic")
table.1<- table.1 %>% 
          inner_join(table.1.mdcd,
              by="Characteristic")
table.1<- table.1 %>% 
          inner_join(table.1.panther,
              by="Characteristic")
table.1<- table.1 %>% 
          inner_join(table.1.premier,
              by="Characteristic")


# 
table.1<-rbind(table.1[55,],
table.1[1,],
table.1[56:57,],
table.1[2:54,])



# reduce
table.1<-table.1 %>% 
  filter(Characteristic %in%
        c("Age (median [IQR])",
          "Gender: female (%)",
          "Charlson score (median [IQR])",
        #  "Hospital Frailty Risk Score (median [IQR])",
       #   "Medical history: General",
          "  Atrial fibrillation (%)",
        #  "  Acute respiratory disease (%)",
          "  Cerebrovascular disease (%)",
          "  Chronic liver disease (%)",
          "  Chronic obstructive lung disease (%)",
          "  Gastroesophageal reflux disease (%)",
        #  "  Gastrointestinal hemorrhage (%)",
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
         CUIMC, optum, CCAE,datamaster, mdcd, panther, premier)

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
CCAE=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[4], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects)),
datamaster=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[3], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects)),
mdcd=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[5], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects)),
panther=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[6], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects)),
premier=as.numeric(read.csv(unz(
             file.path(folder.cohortDiagnostics.results,
             paste0(names[7], ".zip")), "inclusion_rule_stats.csv")) %>% 
  filter(cohort_id==3) %>% 
  filter(rule_name=="No cardiac procedure") %>% 
  select(remain_subjects))),
table.1)

save(table.1, 
     file = paste0(final.figs_tables, "/table.1.Rdata"))


