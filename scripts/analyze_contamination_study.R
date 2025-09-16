# analyze aquamis contamination study

library(dplyr)
library(ggplot2)
library(yaml)

analysisdir <- "/cephfs/abteilung4/deneke/Projects/assembly_qc/analysis/aquamis_contamination"

yaml_files <- list.files(analysisdir, pattern = "yaml", full.names = T)
#myyaml <- yaml_files[1] 


gfastats <- lapply(yaml_files, function(myyaml){
  sample <- sub(".gfa.yaml","",basename(myyaml))
  
  data <- data.frame(
    rbind(unlist(read_yaml(myyaml)))
  ) %>% mutate(sample=sample) %>% relocate(sample)
  
  return(data)
  
}) %>% bind_rows()




