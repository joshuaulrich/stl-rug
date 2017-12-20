# W. Krekeler
# 2017.12.11
#
# test RDSTK
# purposely did not use rmarkdown

# -- import code base (some may not be used; copy paste efficiency)
library(ggplot2)
library(dplyr)
library(tidyr)
library(rjson) # fromJSON
library(RDSTK) # datascienctoolkit
# make sure to vagrant up on the dstk 0.51 box before the next line!
options("RDSTK_api_base"="http://localhost:8080")

# -- import
fileName <- list()
fileName$declarationPath <- 'C:/data/case2-declaration_of_independence' 
fileName$declaration <- file.path( fileName$declarationPath, 'declaration_of_independence.txt' )


fileHan <- file( fileName$declaration )
textDeclaration <- readLines(fileHan)
close(fileHan)


# there are better tools for sentiment; see NRC Sentiment tools; syuzhet::get_nrc_sentiment()
text2sentiment(textDeclaration)
bySentenceSentiment <- unlist( lapply( textDeclaration, text2sentiment))
plot( bySentenceSentiment )


text2times(textDeclaration)
bySentenceTimesList <- lapply( textDeclaration, text2times)
bySentenceTimesListL <- unlist( lapply(bySentenceTimesList, length ))
bySentenceTimesList[which(bySentenceTimesListL > 0 )]


# text2people fails, unclear why because did not investigate error
text2people(textDeclaration)
bySentencePeopleList <- lapply( textDeclaration, text2people)
bySentencePeopleListL <- unlist( lapply(bySentencePeopleList, length ))
bySentencePeopleList[which(bySentencePeopleListL > 0 )]
