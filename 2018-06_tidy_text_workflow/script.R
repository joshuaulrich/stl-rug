library(bigrquery)
library(tidyverse)

project <- "my-first-project-184914"

sql <- "#legacySQL
 SELECT
   stories.title AS title,
   stories.text AS text
 FROM
   [bigquery-public-data:hacker_news.full] AS stories
 WHERE
   stories.deleted IS NULL
 LIMIT
   250000"

hacker_news_raw <- query_exec(sql, project = project, max_pages = Inf)

library(stringr)

hacker_news_text <- hacker_news_raw %>%
  as_tibble() %>%
  mutate(title = na_if(title, ""),
         text = coalesce(title, text)) %>%
  select(-title) %>%
  mutate(text = str_replace_all(text, "&quot;|&#x2F;", "'"),    ## hex encoding
         text = str_replace_all(text, "&#x2F;", "/"),           ## more hex
         text = str_replace_all(text, "<a(.*?)>", " "),         ## links 
         text = str_replace_all(text, "&gt;|&lt;", " "),        ## html yuck
         text = str_replace_all(text, "<[^>]*>", " "),          ## mmmmm, more html yuck
         postID = row_number())

#write.csv(hacker_news_text, "hacker_news.csv", row.names = FALSE, col.names = TRUE)
hacker_news_text <- read.csv("hacker_news.csv", stringsAsFactors = FALSE)

library(tidytext)

unigram_probs <- hacker_news_text %>%
  unnest_tokens(word, text) %>%
  count(word, sort = TRUE) %>%
  mutate(p = n / sum(n))

unigram_probs

library(widyr)

tidy_skipgrams <- hacker_news_text %>%
  unnest_tokens(ngram, text, token = "ngrams", n = 8) %>%
  mutate(ngramID = row_number()) %>% 
  unite(skipgramID, postID, ngramID) %>%
  unnest_tokens(word, ngram)

tidy_skipgrams

skipgram_probs <- tidy_skipgrams %>%
  pairwise_count(word, skipgramID, diag = TRUE, sort = TRUE) %>%
  mutate(p = n / sum(n))

normalized_prob <- skipgram_probs %>%
  filter(n > 20) %>%
  rename(word1 = item1, word2 = item2) %>%
  left_join(unigram_probs %>%
              select(word1 = word, p1 = p),
            by = "word1") %>%
  left_join(unigram_probs %>%
              select(word2 = word, p2 = p),
            by = "word2") %>%
  mutate(p_together = p / p1 / p2)

normalized_prob %>% 
  filter(word1 == "facebook") %>%
  arrange(-p_together)

normalized_prob %>% 
  filter(word1 == "scala") %>%
  arrange(-p_together)

pmi_matrix <- normalized_prob %>%
  mutate(pmi = log10(p_together)) %>%
  cast_sparse(word1, word2, pmi)

pmi_matrix@x[is.na(pmi_matrix@x)] <- 0

library(irlba)

pmi_svd <- irlba(pmi_matrix, 256, maxit = 1e3)

word_vectors <- pmi_svd$u
rownames(word_vectors) <- rownames(pmi_matrix)

library(broom)

search_synonyms <- function(word_vectors, selected_vector) {
  
  similarities <- word_vectors %*% selected_vector %>%
    tidy() %>%
    as_tibble() %>%
    rename(token = .rownames,
           similarity = unrowname.x.)
  
  similarities %>%
    arrange(-similarity)    
}

facebook <- search_synonyms(word_vectors, word_vectors["facebook",])
facebook

haskell <- search_synonyms(word_vectors, word_vectors["haskell",])
haskell


mystery_product <- word_vectors["iphone",] - word_vectors["apple",] + word_vectors["google",]
search_synonyms(word_vectors, mystery_product)

mystery_product <- word_vectors["iphone",] - word_vectors["apple",] + word_vectors["amazon",]
search_synonyms(word_vectors, mystery_product)