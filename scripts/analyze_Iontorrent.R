# Goal IonTorrent data

wd <- "/cephfs/abteilung4/deneke/Projects/assembly_qc/hackathon/graphhealth/"

library(dplyr)
library(ggplot2)
library(yaml)

#analysisdir <- "/cephfs/abteilung4/deneke/Projects/assembly_qc/analysis/aquamis_contamination"

analysisdir <- file.path(wd,"data/IonTorrent_benchmark")

yaml_files <- list.files(analysisdir, pattern = "yaml", full.names = T)

length(yaml_files)


unlist(read_yaml(myyaml))

data.frame(
  rbind(unlist(read_yaml(myyaml))), stringsAsFactors = F
)


gfastats <- lapply(yaml_files, function(myyaml){
  sample <- sub(".gfa.yaml","",basename(myyaml))
  
  data <- data.frame(
    rbind(unlist(read_yaml(myyaml))), stringsAsFactors = F
  ) %>% mutate(sample=sample) %>% relocate(sample)
  
  return(data)
  
}) %>% bind_rows() %>% as_tibble()

gfastats <- gfastats %>% mutate(across(starts_with("Number"),as.numeric))
#gfastats %>% mutate(across(!starts_with("sample"),as.numeric))

gfastats <- gfastats %>% mutate(sequencer = ifelse(grepl("Illumina",sample),"Illumina","IonTorrent")) %>% relocate(sequencer,.after = "sample")
colnames(gfastats)

gfastats_wide <- 
gfastats %>% 
  mutate(strain = sub("Illumina_|IonTorrent_","",sample)) %>%
  select(strain,sequencer,Number.of.dead.ends) %>%
  tidyr::pivot_wider(names_from = sequencer, values_from = Number.of.dead.ends, names_prefix = "dead_ends_") #%>%

gfastats_wide
gfastats_wide %>%
  mutate(across(starts_with("dead_ends_"),as.numeric)) %>%
  filter(dead_ends_IonTorrent < 100) %>%
  ggplot(aes(x=dead_ends_Illumina,y=dead_ends_IonTorrent)) +
  geom_abline(slope=1, intercept = 0) + 
  geom_jitter(width = 0.1, height = 0.1)

ggsave(file.path(analysisdir,"dead_ends_IonTorrent_vs_Illumina.png"))

write.table(gfastats, file.path(analysisdir,"assembly_stats.tsv"), row.names = F, quote = F, sep = "\t")
