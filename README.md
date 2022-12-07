# YelpProject
Project for UW-Madison STAT 628 Module 3 - Group 19. Explore Yelp data and give useful feed back for business owners.

Link to our [Shiny app](https://yuxin468-yelp-analysis-main-ykhpce.streamlit.app/).

## Code

Store all the codes to load, preprocess and analysis data.

- [DiscoverSession.R](https://github.com/April2Carrie/YelpProject/blob/main/Code/DiscoverSession.R) 
Contains code for data selection, tokenization, cleaning and code for creating wordcloud and showing top 50 words with their frequencies.

- [SentimentAnalysis.ipynb](https://github.com/April2Carrie/YelpProject/blob/main/Code/SentimentAnalysis.ipynb) 
Contains code for primary sentiment analysis.

- [json_to_csv_converter.py](https://github.com/April2Carrie/YelpProject/blob/main/Code/json_to_csv_converter.py) 
Use pandas to read pandas.json to pandas.dataframe, check the samples in each state.

- [Bigrams.ipynb](https://github.com/April2Carrie/YelpProject/blob/main/Code/Bigrams.ipynb) Code for data cleaning and constructing LDA model.

- [TFIDF_Logisticreg.ipynb](https://github.com/April2Carrie/YelpProject/blob/main/Code/TFIDF_Logisticreg.ipynb) Code for complementing logistic regression after using TF-IDF to select words.

- [barplot.R](https://github.com/April2Carrie/YelpProject/blob/main/Code/barplot.R) Code for creating barplots.

## Data

Stores the data less than 25M.

- [business_chinese_philadelphia.csv](https://github.com/April2Carrie/YelpProject/blob/main/Data/business_chinese_philadelphia.csv) 
Business selected for Chinese restaurants in Philadelphia.

- [review_chinsese_philadelphia.csv](https://github.com/April2Carrie/YelpProject/blob/main/Data/review_chinsese_philadelphia.csv)
Reviews selected for Chinese restaurants in Philadelphia.

- [review_final.csv](https://github.com/April2Carrie/YelpProject/blob/main/Data/review_final.csv)
Reviews after selection.

Data archiving ldamodel for faster loading is preserved. They are all large datasets.

Contact [Carrie](https://github.com/April2Carrie) for large datasets.

## Plots

- [50topwords.png](https://github.com/April2Carrie/YelpProject/blob/main/Plots/50topwords.png) 50 most frequent words in the cleaned reviews.

- [wordcloud.png](https://github.com/April2Carrie/YelpProject/blob/main/Plots/wordcloud.png) Wordcloud for howing the most frequent words.
 
- [TFIDF.png](https://github.com/April2Carrie/YelpProject/blob/main/Plots/TFIDF.png) Distrbution of nonzero TF-IDF scores.

- [barplot](https://github.com/April2Carrie/YelpProject/tree/main/Plots/barplot) All the barplots created.

## Results

- [ldavis_prepared_3.html](https://github.com/April2Carrie/YelpProject/blob/main/Results/ldavis_prepared_3.html) LDA model for both unigrams and bigrams.

- [ldavis_prepared_bi_3.html](https://github.com/April2Carrie/YelpProject/blob/main/Results/ldavis_prepared_bi_3.html) LDA model only using bigrams.

- [ldavis_prepared_3ytynqOUb3hjKeJfRj5Tshw.html](https://github.com/April2Carrie/YelpProject/blob/main/Results/ldavis_prepared_3ytynqOUb3hjKeJfRj5Tshw.html) LODA model for business "Reading Terminal Market" that has the most comments in Philadelpia.

## app

- [main.py](https://github.com/April2Carrie/YelpProject/blob/main/app/main.py) Code for creating our Shiny app.
