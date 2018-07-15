By: Dennis Chandler

Text Mining has become a treasure trove of data with current Natural Language
Processing (NLP) techniques and the hardware to runt them. These techniques
provide semantics, topics, and other features for complex analysis in diverse
areas including image-tagging, market-segmentation, and dynamic word-
embeddings. There are several R packages such as
[tm](https://cloud.r-project.org/package=tm),
[topicmodels](https://cloud.r-project.org/package=topicmodels), [quanteda](https://cloud.r-project.org/package=quanteda),
[SnowballC](https://cloud.r-project.org/package=SnowballC), and many others
that perform NLP tasks, but have their own specific quirks and formats. The
[tidytext](https://cloud.r-project.org/package=tidytext) package, by Julia
Silge and David Robinson 'provides functions and supporting data sets to allow conversion of text to and from tidy formats, and to switch seamlessly between tidy tools and existing text mining packages.'

This presentation will be a high-level review of the package and how it
integrates with various other packages to simplify NLP workflows. I will work
through several simple examples of the key functions and then work through an
extended example of using the functions, in combination with some other
packages, to create word-embeddings similar to
[word2vec](https://code.google.com/archive/p/word2vec/) and
[GloVe](https://nlp.stanford.edu/projects/glove/) without using neural
networks, but by just counting words and some linear algebra.

## Notes

Presentation of TidyText and Word2Vec Alternative

* `script.R` is the full analysis for Word2Vec Alternative
* `corpus_script.R` is test analysis
* `debug.R` and `head.R` are files for presentation format
* `rpres.md` is the Markdown presentation
* `word_vectors` is too large to host on GitHub, but email me if you would like a copy
