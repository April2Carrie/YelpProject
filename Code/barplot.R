library(dplyr)
library(stringr)

library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(dplyr)
library(text2vec)
library(tm)
library(ggplot2)

#change file address in your pc
review=read.csv("Data/review_chinsese_philadelphia.csv")
#typeof(review$text[1]) character
#typeof(review$stars) integer

################################################################################
# NLP preprocessing, same part copied from discoversession
review_bus <- read.csv("Data/review_business_combined.csv")
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

# show and decide what food we want to explore from the top most words in review

features <- textstat_frequency(DFM, 200)
features$feature

starsbar=function(word,review){ # shows real proportion
  #fill in the word you want to show in barplot.
  #Review is a dataframe with text and stars column
  #warning: can only apply to df with columns named stars and text
  # choose the subset reviews containing the word
  review_sub <- review %>% filter(str_detect(text,word))
  # group by star and plot
  tmp <- review_sub %>% group_by(stars) %>% tally()
  barplt=barplot(height=tmp$n/sum(tmp$n),names=1:5,xlab='stars',ylab='counting percentage',main=word,col="lightblue1",border="dodgerblue3",width = 1,space=0.5)
  #show the proportion of stars among all reviews containing the word
  return(barplt)
}

starsbar1=function(word,review){# shows relative proportion, compared to star distribution
  #fill in the word you want to show in barplot.
  #Review is a dataframe with text and stars column
  # choose the subset reviews containing the word
  tmp1 <- review %>% group_by(stars) %>% tally()
  tmp1$n/sum(tmp1$n)
  review_sub <- review %>% filter(str_detect(text,word))
  # group by star and plot
  tmp <- review_sub %>% group_by(stars) %>% tally()
  barplt=barplot(height=(tmp$n/sum(tmp$n))/(tmp1$n/sum(tmp1$n)),names=1:5,xlab='stars',ylab='counting percentage',main=word,width = 1,space=0.5)
  #tmp$n/sum(tmp$n) height tmp divided by tmp1 is to eliminate the distribution of stars itself. It shows whether a feature shows more in low/high stars
  return(barplt)
}

#plot all review stars
tmp <- review %>% group_by(stars) %>% tally()
barplot(height=tmp$n/sum(tmp$n),names=1:5,xlab='stars',ylab='counting percentage',main='all stars',col="lightblue1",border="dodgerblue3",width = 1,space=0.5)

#plot proportion star barplots

par(mfrow = c(3,4))
words=c('meat', 'duck', 'fish', 'chicken', 'pork', 'beef','shrimp', 'egg')
for(i in words){
  starsbar(i,review)
}

par(mfrow = c(3,4))
words=c('tofu', 'oil', 'sushi', 'dumplings', 'noodles', 'sauce', 'rolls', 'broth', 'rice', 'tea')
for(i in words){
  starsbar(i,review)
}

par(mfrow = c(3,4))
#other features
words=c("service","spicy","flavor","bad","wait","long", 'hot', 'sweet', 'delicious', 'nice' ,'dim')
for(i in words){
  starsbar(i,review)
}

# relative proportion star barplots

par(mfrow = c(3,4))
words=c('meat', 'duck', 'fish', 'chicken', 'pork', 'beef','shrimp', 'egg')
for(i in words){
  starsbar1(i,review)
}

par(mfrow = c(3,4))
words=c('tofu', 'oil', 'sushi', 'dumplings', 'noodles', 'sauce', 'rolls', 'broth', 'rice', 'tea')
for(i in words){
  starsbar1(i,review)
}

par(mfrow = c(3,4))
#other features
words=c("service","spicy","flavor","bad","wait","long", 'hot', 'sweet', 'delicious', 'nice' ,'dim')
for(i in words){
  starsbar1(i,review)
}