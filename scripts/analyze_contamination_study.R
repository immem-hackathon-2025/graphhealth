# analyze aquamis contamination study

library(dplyr)
library(ggplot2)
library(yaml)

analysisdir <- "/cephfs/abteilung4/deneke/Projects/assembly_qc/analysis/aquamis_contamination"




yaml_files <- list.files(analysisdir, pattern = "yaml", full.names = T)

gfastats <- lapply(yaml_files, function(myyaml){
  sample <- sub(".gfa.yaml","",basename(myyaml))
  
  data <- data.frame(
    rbind(unlist(read_yaml(myyaml)))
  ) %>% mutate(sample=sample) %>% relocate(sample)
  
  return(data)
  
}) %>% bind_rows() %>% as_tibble()

# ---
working_dir2 <- "/cephfs/abteilung4/deneke/Projects/aquamis_contamination_evaluation"
aquamis_stats.file <- file.path(working_dir2,"summary_data/fda_data/aquamis_Ec/reports/report_stats.tsv")
metadata.file <- file.path(working_dir2,"summary_data/fda_data/metadata_Ec.tsv")
#bakcharak_summary.file <- file.path(working_dir2,"summary_data/fda_data/bakcharak_Ec/results/summary/summary_all.tsv")
# load aquamis report

aquamis_stats <- read.delim(aquamis_stats.file, stringsAsFactors = F, as.is = T)

# load metadata
metadata <- read.delim(metadata.file, stringsAsFactors = F, as.is = T) %>% as_tibble()
metadata$distance <- sub("-",".",metadata$distance)


# ---

gfastats <- gfastats %>% as_tibble()

gfastats <- left_join(gfastats,metadata,by=c("sample"))

colnames(gfastats)

# export
write.table(gfastats, file.path(analysisdir,"assembly_stats.tsv"), row.names = F, quote = F, sep = "\t")



# plot

class(gfastats$Number.of.dead.ends)

gfastats %>%
  mutate(Number.of.dead.ends = as.numeric(as.character(Number.of.dead.ends))) %>%
  ggplot(aes(x=mixing_ratio,y=Number.of.dead.ends, color=distance)) +
  #geom_point() +
  geom_jitter(width = 1) +
  facet_wrap(~contam_type, ncol=1)


ggsave(file.path(analysisdir,"Number.of.dead.ends_vs_contamination.mixing.ratio.png"))


colnames(gfastats)
gfastats %>% count(distance)
  
gfastats %>%
  mutate(Number.of.bubbles = as.numeric(as.character(Number.of.bubbles))) %>%
  ggplot(aes(x=mixing_ratio,y=Number.of.bubbles, color=distance)) +
  #geom_point() +
  geom_jitter(width = 1) +
  facet_wrap(~contam_type, ncol=1)

ggsave(file.path(analysisdir,"Number.of.bubbles.ends_vs_contamination.mixing.ratio.png"))


colnames(gfastats)
X11()
gfastats %>%
  filter(contam_type == "intra_species") %>%
  mutate(Number.of.bubbles = as.numeric(as.character(Number.of.bubbles))) %>%
  mutate(Number.of.contigs = as.numeric(as.character(Number.of.contigs))) %>%
  mutate(Number.of.dead.ends = as.numeric(as.character(Number.of.dead.ends))) %>%
  mutate(mixing_ratio = as.character(mixing_ratio)) %>%
  ggplot(aes(x=Number.of.contigs,y=Number.of.dead.ends, color=mixing_ratio)) +
  #geom_point() +
  geom_jitter(width = 1) +
  facet_wrap(~distance, ncol=1)


ggsave(file.path(analysisdir,"Number.of.bubbles.ends_vs_contig.number_intracontamination.png"))
