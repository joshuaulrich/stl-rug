library(tm.plugin.webmining)
library(purrr)
library(stringr)

company <- c("Microsoft", "Apple", "Google", "Amazon", "Facebook",
             "Twitter", "IBM", "Yahoo", "Netflix")
symbol <- c("MSFT", "AAPL", "GOOG", "AMZN", "FB", "TWTR", "IBM", "YHOO", "NFLX")

download_articles <- function(symbol) {
  WebCorpus(YahooFinanceSource(symbol))
}

stock_articles <- data.frame(company = company,
                             symbol = symbol) %>%
  mutate(corpus = map(symbol, download_articles))

str(stock_articles, max  = 2)

stock_tokens <- stock_articles %>%
  unnest(map(corpus, tidy)) %>%
  unnest_tokens(word, text) %>%
  select(company, datetimestamp, word, id, heading)

stock_tf_idf <- stock_tokens %>%
  count(company, word) %>%
  filter(!str_detect(word, "\\d+")) %>%
  bind_tf_idf(word, company, n) %>%
  arrange(-tf_idf)

top_stock_tf_idf <- stock_tf_idf %>%
  group_by(company) %>%
  top_n(n = 5, wt = tf_idf) %>%
  arrange(company, desc(tf_idf)) %>%
  ungroup()

ggplot(top_stock_tf_idf, aes(x = reorder(word, tf_idf), tf_idf, fill = "company")) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ company, scales = "free") +
  xlab("Word") +
  ylab("tf_idf")

