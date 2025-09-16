# analyze long read downsampling

# Goal IonTorrent data

wd <- "/cephfs/abteilung4/deneke/Projects/assembly_qc/hackathon/graphhealth/"

library(dplyr)
library(ggplot2)
library(yaml)


analysisdir <- file.path(wd,"data/longread_downsampling")

yaml_files <- list.files(analysisdir, pattern = "yaml", full.names = T)

length(yaml_files)


gfastats <- lapply(yaml_files, function(myyaml){
  sample <- sub(".gfa.yaml","",basename(myyaml))
  
  data <- data.frame(
    rbind(unlist(read_yaml(myyaml))), stringsAsFactors = F
  ) %>% mutate(sample=sample) %>% relocate(sample)
  
  return(data)
  
}) %>% bind_rows() %>% as_tibble()

gfastats <- gfastats %>% mutate(across(starts_with("Number"),as.numeric))

# infer depth from sample name
gfastats <- 
gfastats %>% 
  #select(sample) %>%
  tidyr::separate_wider_delim(cols=sample,names = c("strain","depth_x"), delim = "_") %>%
  mutate(depth=as.numeric(sub("x$","",depth_x))) %>%
  mutate(depth_category = case_when(
    depth == 10 ~ "10" ,
    depth == 20 ~ "20" ,
    depth == 30 ~ "30" ,
    depth > 30 ~ ">30" ,
    .default = "other"
  ))

write.table(gfastats, file.path(analysisdir,"assembly_stats.tsv"), row.names = F, quote = F, sep = "\t")


colnames(gfastats)
gfastats %>%
  #count(depth_category)
  
  ggplot(aes(x=depth_category,y=Number.of.dead.ends)) + 
  geom_boxplot()


gfastats %>%
  filter(depth <=30) %>%
  ggplot(aes(x=Number.of.contigs,y=Number.of.dead.ends,color=depth_category)) +
  geom_jitter() + 
  theme(legend.position = "bottom")
