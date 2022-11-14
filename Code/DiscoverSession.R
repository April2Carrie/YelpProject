library(readr)
library(dplyr)
library(jsonlite)
library(parallel)
setwd("~/STAT628/M3G19")
################################################################################
# load data
# business <- read_csv("STAT628/M3G19/Data/business.csv")
# business <- business[,2:length(business)]
business_c <- read_csv("STAT628/M3G19/Data/business_chinese.csv")
business_c <- business_c[,2:length(business_c)]
################################################################################
# Overview of Chinese Business

## Count business
tmp <- business_c %>% group_by(city,state) %>% tally()
write.csv(tmp, file = "chinese_city.csv")

tmp <- business_c %>% group_by(state) %>% tally()
write.csv(tmp, file = "./Data/chinese_state.csv")

## Count Review
tmp <- business_c %>% group_by(city,state) %>%
  count(city, wt = review_count)%>%
  arrange(desc(n))
write.csv(tmp, file = "./Data/chinese_city_review.csv")

tmp <- business_c %>% group_by(state) %>%
  count(state, wt = review_count)%>%
  arrange(desc(n))
write.csv(tmp, file = "./Data/chinese_state_review.csv")
################################################################################
# Choose businesses in Philadelphia, PA
business_c_p <- business_c %>% filter((state=="PA") & (city=="Philadelphia"))
# write.csv(business_c_p, file = "./Data/business_chinese_philadelphia.csv")
business_id_p <- business_c_p$business_id
# write.csv(business_id, file = "./Data/business_id.csv")
################################################################################
# Choose review related to business above
get_review <- stream_in(file("./yelp_dataset_2022/review.json"),pagesize = 10000)
# write.csv(get_review, file = "./Data/review.csv")

review_c_p <- data.frame()
# run parallel for filtering, 1000 rows each
r <- mclapply(1:round(nrow(get_review)/1000), function(i){
  tmp <- get_review[(1000*(i-1)+1):(1000*i),] %>% filter(business_id %in% business_id_p)
}, mc.cores = 20)
# for (i in 1:round(nrow(get_review)/1000)){
#   review_c_p <- rbind(review_c_p, r[[i]])
# }
# tmp <- get_review[(round(nrow(get_review)/1000)*1000+1):(nrow(get_review)),] %>% filter(business_id %in% business_id_p)
# review_c_p <- rbind(review_c_p, tmp)
write.csv(review_c_p, file = "./Data/review_chinsese_philadelphia.csv")
################################################################################
# select columns
business_c_p <- read_csv("./Data/business_chinese_philadelphia.csv")
business_c_p <- business_c_p[,2:length(business_c_p)]
# for each business, only keep business_id, stars, review_count, is_open, attributes, hours
business_c_p <- business_c_p %>% select(business_id,stars,review_count,is_open,attributes,hours)

review_c_p <- read_csv("./Data/review_chinsese_philadelphia.csv")
review_c_p <- review_c_p[,2:length(review_c_p)]
review_c_p <- review_c_p %>% select(review_id,business_id,stars,useful,funny,cool,text)

# merge to 1 data set
review_bus <- merge(business_c_p,review_c_p,by=c("business_id"))
colnames(review_bus)[2] <- "bus_star"
colnames(review_bus)[8] <- "rev_star"
# write.csv(review_bus, file = "./Data/review_business_combined.csv")
################################################################################
rm(list=ls())
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(dplyr)
library(text2vec)
library(tm)
library(ggplot2)
################################################################################
# NLP preprocessing
review_bus <- read_csv("./Data/review_business_combined.csv")
review_bus <- review_bus[,2:13]
construct_corpus<- function(df){
  corp<-corpus(df, text_field = "text")
  docnames(corp) <- df$review_id
  return(corp)
}

data_cleaning <- function(Corp){
  # tokenize corpus removing unnecessary (i.e. semantically uninformative) elements
  toks <- tokens(Corp, remove_punct=T, remove_symbols=T, remove_url = T, 
                 split_tags=T, remove_separators=T)# , remove_numbers=T
  # clean out stopwords and words with 1 character (alphabets)
  toks_nostop <- tokens_select(toks, pattern = c(stopwords("en")), 
                               selection = "remove", min_nchar=1)
  return(toks_nostop)
}
corp <- construct_corpus(df=review_bus)
tmp <- data_cleaning(Corp=corp)
# build a dfm to summarize the usage of words in each document
DFM <- dfm(tmp)
textplot_wordcloud(DFM, color = rainbow(10),max_size=7, min_size =.5)
# find 50 topwords
features_DFM <- textstat_frequency(DFM, 50)
# Sort by reverse frequency order
features_DFM$feature <- with(features_DFM, reorder(feature, -frequency))
ggplot(features_DFM, aes(x = feature, y = frequency)) +
  geom_point() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 