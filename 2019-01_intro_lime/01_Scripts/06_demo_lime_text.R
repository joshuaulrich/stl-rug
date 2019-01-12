library(text2vec)
library(xgboost)

data(train_sentences)
data(test_sentences)

get_matrix <- function(text) {
  it <- itoken(text, progressbar = FALSE)
  create_dtm(it, vectorizer = hash_vectorizer())
}

dtm_train = get_matrix(train_sentences$text)

xgb_model <- xgb.train(list(max_depth = 7, eta = 0.1, objective = "binary:logistic",
                            eval_metric = "error", nthread = 1),
                       xgb.DMatrix(dtm_train, label = train_sentences$class.text == "OWNX"),
                       nrounds = 50)

sentences <- head(test_sentences[test_sentences$class.text == "OWNX", "text"], 1)
explainer <- lime(train_sentences$text, xgb_model, get_matrix)

# The explainer can now be queried interactively:

interactive_text_explanations(explainer)

explanation_text <- lime::explain(test_sentences$text[1:4], explainer, n_labels = 1, n_features = 5)

plot_text_explanations(explanation_text)
plot_features(explanation_text)