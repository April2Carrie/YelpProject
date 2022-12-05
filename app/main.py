import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from string import punctuation
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk import ngrams
from itertools import chain
from nltk import FreqDist
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from wordcloud import WordCloud

st.set_page_config(layout="wide")

st.markdown("""
<style>
div[data-testid="metric-container"] {
   background-color: rgba(28, 131, 225, 0.1);
   border: 1px solid rgba(28, 131, 225, 0.1);
   padding: 5% 5% 5% 10%;
   border-radius: 5px;
   color: rgb(30, 103, 119);
   overflow-wrap: break-word;
}

/* breakline for metric text         */
div[data-testid="metric-container"] > label[data-testid="stMetricLabel"] > div {
   overflow-wrap: break-word;
   white-space: break-spaces;
   color: black;
}
</style>
"""
, unsafe_allow_html=True)


# load data to the app 
review_data = pd.read_csv("data/app_data.csv")
review_data.drop_duplicates(subset=['review_id','date','user_id'],inplace=True) 
review_data.set_index('Unnamed: 0')
business_name = np.unique(review_data['name'])
postal_code = np.unique(review_data['postal_code'])

# set sidebar for this app
with st.sidebar:
    postal_select = st.sidebar.selectbox(
    "Choose postal_code",
    postal_code
)
    business_select = st.sidebar.selectbox(
    "Choose Restaturant",
    np.unique(review_data['name'][review_data['postal_code']==postal_select])
)

#  sentiment scores
avg_stars = review_data['stars'][review_data['name']==business_select].mean()
avg_senti = review_data['sentiment_score'][review_data['name']==business_select].mean()

#review count
count_rev = review_data['text'][review_data['name']==business_select].count()


# set header for this app
header = st.container()
with header:
	st.title('Recommendation for Chinese Restaturant in Philadelphia')
	st.text('You can choose the business name in the left side bar and gain some analysis based on that.')

tab1, tab2, tab3, tab4 = st.tabs(["Basic Information", "Topic Model Visualization","Sentiment Analysis", "Meat Dishes Recommendation"])

# location of the business restarant
lat = np.unique(np.array(review_data['latitude'][review_data['name']==business_select]))
lon = np.unique(np.array(review_data['longitude'][review_data['name']==business_select]))
map_data = pd.DataFrame({'lat':lat,'lon':lon})

with tab1:
	col1, col2, col3 = st.columns(3)
	col1.metric("Overall Sentiment Scores", avg_senti )
	col2.metric("Average Stars", avg_stars)
	col3.metric("Number of reviews",count_rev)
	st.map(map_data)

# category sentiment score plot
from itertools import chain

# return list from series of \n-seperated lines
def chainer(s):
    return list(chain.from_iterable(s.str.split('\n')))

# calculate lengths of splits
lens = review_data['text'].str.split('\n').map(len)

# create new data frames, repeating or chaining as appropriate
review_segment = pd.read_csv("data/segment_data.csv")
service_data = review_segment[(review_segment['text'].str.contains('service|wait'))&(review_data['name']==business_select)]
food_data = review_segment[(review_segment['text'].str.contains('food|taste|dish'))&(review_data['name']==business_select)]
service_score = service_data['sentiment_score'].groupby(service_data['business_name']).mean()
food_score = food_data['sentiment_score'].groupby(food_data['business_name']).mean()
price_data = review_segment[(review_segment['text'].str.contains('price'))&(review_data['name']==business_select)]
price_score = price_data['sentiment_score'].groupby(price_data['business_name']).mean()
X = ["Service","Food","Price"]
y_service = service_score.values[0] if service_score.values.size !=0 else 0
y_food = food_score.values[0] if food_score.values.size !=0 else 0
y_price = price_score.values[0] if price_score.values.size !=0 else 0
y = [y_service, y_food, y_price]
df = pd.DataFrame({"Category":X,"Sentiment Score":y})
fig = plt.figure(figsize=(7, 3))
sns.barplot(data=df, x="Category", y="Sentiment Score")

# generate tfidf
from nltk.corpus import stopwords
stop_words = stopwords.words('english')

# remove stopwords
def remove_stopwords(data):
    review = data.apply(lambda x: ' '.join([y for y in x.split() if len(y)>2]))
    review_new = review.apply(lambda x: ' '.join([y for y in x.split() if y not in stop_words]))
    review_new = review_new.apply(str.lower)
    return review_new

review_new = remove_stopwords(review_data['text'])
review_final =  remove_stopwords(review_data['text'][review_data['name']==business_select])
X_review = review_final
y = review_data['sentiment_cag'][review_data['name']==business_select]
tfidf = TfidfVectorizer(ngram_range=(2,3),stop_words = 'english',max_df = 0.30)
X_tfidf = tfidf.fit_transform(X_review)
word = tfidf.get_feature_names_out()


# Train Logistic Model
X_train, X_test, y_train, y_test = train_test_split(X_tfidf, y, random_state=0)

def text_reg(model,coef_show=1):
    ml = model.fit(X_train, y_train)
    acc = ml.score(X_test, y_test)
    print ('Model Accuracy: {}'.format(acc))
    
    if coef_show == 1: 
        coef = ml.coef_.tolist()[0]
        coeff_df = pd.DataFrame({'Word' : word, 'Coefficient' : coef})
        coeff_df = coeff_df.sort_values(['Coefficient', 'Word'], ascending=[0, 1])
        return coeff_df
    

coeff_df = pd.DataFrame(text_reg(LogisticRegression()))

positive = coeff_df.head(20).to_string(index = False)
negative = coeff_df.tail(20).to_string(index = False)


with tab3:
	with st.container():
		col1, col2 = st.columns(2)
		with col1:
			col1.pyplot(fig)
		with col2:
			col2.markdown("The plot in the left gives the average sentiment scores in different categories.")

	
	with st.container():
		col1, col2 = st.columns(2)
		with col1:
			col1.write("**Positive Key Words** :thumbsup:")
		with col2:
			col2.write("**Negative Key Words** :thumbsdown:")

	with st.container():
		col1, col2 = st.columns(2)
		with col1:
			col1.text(positive)
		with col2:
			col2.text(negative)

meat_data = review_segment[(review_segment['text'].str.contains('chicken|fish|chick|pork|beef'))&(review_data['name']==business_select)]
model = LogisticRegression()
tfidf_meat = TfidfVectorizer(ngram_range=(2,3),stop_words = 'english',max_df = 0.7)
X_meat = tfidf_meat.fit_transform(meat_data['text'])
word_meat = pd.Series(tfidf_meat.get_feature_names_out())[pd.Series(tfidf_meat.get_feature_names_out()).str.contains('chicken|fish|chick|pork|beef')]
meat_index = word_meat.index
word = pd.Series(tfidf_meat.get_feature_names_out())
ml_meat = model.fit(X_meat, meat_data['sentiment_cag'])
coef = ml_meat.coef_.tolist()[0]
coef_meat = [coef[i] for i in meat_index]
coeff_df = pd.DataFrame({'Word' : word_meat, 'Coefficient' : coef_meat})
coeff_df = coeff_df.sort_values(['Coefficient', 'Word'], ascending=[0, 1])
positive = coeff_df.head(10).to_string(index = False)
negative = coeff_df.tail(10).to_string(index = False)

with tab4:
	with st.container():
		col1, col2 = st.columns(2)
		with col1:
			col1.write("**Dishes most liked** :yum:")
		with col2:
			col2.write("**Dishes need to imrove** 	:disappointed:")


	with st.container():
		col1, col2 = st.columns(2)
		with col1:
			col1.text(positive)
		with col2:
			col2.text(negative)















