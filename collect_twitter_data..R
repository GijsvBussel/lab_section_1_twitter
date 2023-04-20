# collect_twitter_data.R
#
# Contributors:
#
# What this file does:
#   * Uses rtweet to harvest twitter data
#   * Shows various options available to restrict collection

# --- Libraries --- #
library(rtweet)  # Twitter API
library(readr)   # read/write files

#--- Basic API Usage ---#

# simplest thing we can do
# Remark: Luka Modric was trending after a brilliant assist in the Champions League game against Chelsea.

tweets <- 
    search_tweets('#modric')

# what are the defaults? Look at help
?search_tweets

# relax some defaults
# increase number of tweets
tweets <- 
    search_tweets(
        '#modric',
        n = 1000
    )

# modric or lukamodric
tweets <- 
    search_tweets(
        '#modric OR lukamodric',
        n = 2000
    )

# must include real madrid?
tweets <- 
    search_tweets(
        '(#modric OR lukamodric) AND #realmadrid',
        n = 2000
    )

# --- Filtering the Search --- #

# no retweets?
tweets <- 
    search_tweets(
        '(#modric OR lukamodric) AND #realmadrid',
        n = 2000,
        include_rts = FALSE
    )

# only english?
tweets <- 
    search_tweets(
        '(#modric OR lukamodric) AND #realmadrid',
        n = 2000,
        include_rts = FALSE,
        lang = "en"
    )

# and only in US?
## with a Google Maps API code (might cost$)
geo_us <- lookup_coords("US")
?lookup_coords

tweets <- 
    search_tweets(
        '(#modric OR lukamodric) AND #realmadrid',
        n = 2000,
        include_rts = FALSE,
        lang = "en",
        geo = geo_us
    )

write_rds(geo_us, "data/geo_us.Rds")

# but students can's access Google Map API...
# we stored the geo code in a file 'data/us_geo.json'

geo_us2 <- read_rds("data/geo_us.Rds")
tweets2 <- 
    search_tweets(
        '(#modric OR lukamodric) AND #realmadrid',
        n = 2000,
        include_rts = FALSE,
        lang = "en",
        geo = geo_us2
    )

# --- For network Visualization --- #
# back to a bigger data set with retweets so we can play 
# with the network
tweets <- 
    search_tweets(
        '(#modric OR lukamodric)',
        n = 5000,
        lang = "en",
    )

# --- Saving the data --- #
# dont save as csv as some columns are nested lists!
# csv doesn't handle that
# We could clean it up, but I prefer not to unless I need to 
# share the file with someone who is not gonna process the dataset
# with R

write_rds(tweets, "data/tweets.Rds")
