import pandas as pd
########################################read data########################################
# business_json_path = './yelp_dataset_2022/business.json'
# df_b = pd.read_json(business_json_path, lines=True)
# df_b.head()

review_json_path = './yelp_dataset_2022/review.json'
df_r = pd.read_json(review_json_path, lines=True)
df_r.head()

# Using groupby() and count()
# check sample in each state
# df2 = df_b.groupby(['state'])['state'].count()
df2 = df_b.groupby(['city','state'])['city'].count()
tmp = df2['city','state'].unique()
tmp.sort()

# select Chinese restaurants
df3 = df_b.loc[(df_b['categories'].str.contains('Chinese')) & (df_b['categories'].str.contains('Restaurant'))]
df3.groupby(['state'])['state'].count()
tmp.sort()