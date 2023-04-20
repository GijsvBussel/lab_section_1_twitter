# plot_twitter_network.R
#
# Contributors:
#
# What this file does:
#   * Transforms returned Twitter data into a network of connections
#   * Plots retweet and Mentions networks

# --- Libraries --- #
library(readr)     # read/write files
library(dplyr)     # data manip
library(tidyr)     # data manip
library(tidygraph) # network data
library(ggraph)    # network viz

# --- Load Data --- #
tweets <-
    read_rds("smwa-computing-lecture-twitter-networks/data/tweets.Rds")

# --- Retweet Network --- #
# Connect users who retweet each other

# Filter for retweets
rt <- 
    tweets %>%
    filter(is_retweet == TRUE)    

colnames(rt)
# We need screen_name and retweet_screen_name only
# (and only the distinct pairs, since we don't care
# how many times A retweets B)
# These are the edges of our network 

rt_edge <-
    rt %>%
    select(from = screen_name, 
           to = retweet_screen_name) %>%
    distinct()                                      # removes duplicates

# ok so there's a lot of connections here...
# lets reduce the sample size to make things a little easier

to_counts <-
    rt_edge %>%
    group_by(to) %>%
    count() %>%
    arrange(desc(n))

from_counts <-
    rt_edge %>%
    group_by(from) %>%
    count() %>%
    arrange(desc(n))

# lets keep folks who have >= 3 retweets

from_filter <- 
    from_counts %>%
    filter(n >= 3)

rt_edge_small <-
    rt_edge %>%
    filter(from %in% from_filter$from)

# turn edgelist into a network graph object
rt_graph <- 
    as_tbl_graph(
        rt_edge_small, 
        directed = FALSE
    )

# Plot
# the purpose is trying to visualize connections and get a sense of which nodes may be influential / have a high amount of connectedness ... 
#we'll come back to these ideas in the last couple of weeks where we look for influential nodes and also splitting up a network into 'communities'
ggraph(rt_graph, layout = 'fr') + 
    geom_edge_link(alpha = 0.2, color = "red") +           # alpha of 1 means totally black, alpha of 0 is transparent
    geom_node_point(shape = 0, size = 3, color = "blue") +
    geom_node_text(aes(label = name), size = 5, repel = TRUE) +
    theme_graph()                           # to get white background

rt_graph %>%
    mutate(influence = centrality_authority()) %>%
    ggraph(layout = 'fr') +                 # layout options; dh, kk, star, tree, gem, fr , drl ...
    geom_node_point(aes(size=influence)) +
    geom_edge_link(alpha = 0.2, color = 'red') +
    scale_edge_width_discrete(range = c(2,1)) +
    theme_graph()

# Final Graph

rt_graph %>%
    mutate(influence = centrality_authority()) %>%                          # create influence variable
    ggraph(layout = 'fr') +                                                 # layout options; dh, kk, star, tree, gem, fr , drl ...
    geom_node_point(aes(size=influence), color = 'blue') +                  # make nodes represent influence
    geom_edge_link(alpha = 0.2, color = 'red') +                            # add edges
    geom_node_text(aes(label = name), size = 5, repel = TRUE) +             # add text, twitter handle
    scale_edge_width_discrete(range = c(2,1)) +                             # rearrange
    theme_graph() +                                                         # white background
    ggtitle('Luka Modric Retweets', subtitle = "Network based on data from April 2022")         # titles
        


# Save
ggsave("retweet_network.pdf")

# --- Mentions Network --- #

mnt <- 
    tweets %>%
    select(from = screen_name, 
           to = mentions_screen_name
    ) %>%
    filter(to != "NA")

# looking at that data frame we see that to can take multiple values
# if more than one person is mentioned. Let's unnest that

mnt <- 
    mnt %>%
    unnest_longer(to) %>%
    distinct()

# if a user is writing a thread, then they mention themselves
# lets remove that too

mnt <-
    mnt %>%
    filter(from != to)

# ok so there's a lot of connections here...
# lets reduce the sample size to make things a little easier

to_counts <-
    mnt %>%
    group_by(to) %>%
    count() %>%
    arrange(desc(n))

from_counts <-
    mnt %>%
    group_by(from) %>%
    count() %>%
    arrange(desc(n))

# lets keep folks who mention at least 3 distinct people
from_filter <- 
    from_counts %>%
    filter(n >= 3)

mnt_small <-
    mnt %>%
    filter(from %in% from_filter$from)

# Convert to a network graph
mnt_grph <- as_tbl_graph(mnt_small)

# Plot it

ggraph(mnt_grph, 
       layout = 'fr'
) +
    geom_node_point() +
    geom_edge_link(alpha = 0.2) +
    theme_graph()

# Plot w/ a different
ggraph(mnt_grph, 
       layout = "linear", 
       circular = TRUE
) +
    geom_node_point() +
    geom_edge_link(alpha = 0.2) +
    theme_void()

# Save
ggsave("mentions_network.pdf")
