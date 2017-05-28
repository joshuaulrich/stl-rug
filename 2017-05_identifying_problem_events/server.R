# This is the server logic of a Shiny web application
# shiny::runApp(display.mode = "showcase")
options(shiny.reactlog = TRUE)  # press CTRL F3

library(shiny)
library(DT)

shinyServer(function(input, output) {

  values <- reactiveValues(probabilities = data.frame())
    
#  freqTopCount_Filtered <- reactive({ as.maritx(na.omit(freqTopCount[,input$brwyline])) })
  output$freqTopCount =  DT::renderDataTable({
#    freqTopCount_Filtered
    freqTopCount <- faultCodeFrequency(Data, input$brwyline)
    freqTopCount[, input$brwyline] <- scales::percent(freqTopCount[, input$brwyline])
    freqTopCount 
  }, options = list(paging = FALSE, searching = FALSE)
  , rownames = TRUE, caption = "Top 5: Frequency")
  
  output$freqTopPctDowntime = DT::renderDataTable({
    freqTopPctDowntime <- faultCodePctTotalTime(Data, input$brwyline)
    freqTopPctDowntime[, input$brwyline] <- scales::percent(freqTopPctDowntime[, input$brwyline])
    freqTopPctDowntime 
  }, options = list(paging = FALSE, searching = FALSE)
  , rownames = TRUE, caption = "Top 5: % of Down Time")
  
  output$freqTopDowntime = DT::renderDataTable({
    freqTopDowntime <- faultCodeTotalTime(Data, input$brwyline)
  }, options = list(paging = FALSE, searching = FALSE)
  , rownames = TRUE, caption = "Top 5: Total Down Time")
  
  output$avgTop = DT::renderDataTable({
    avgTop <- faultCodeAverageTime(Data, input$brwyline)
  }, options = list(paging = FALSE, searching = FALSE)
  , rownames = TRUE, caption = "Top 5: Average Down Time")
  
  output$medTop = DT::renderDataTable({
    medTop <- faultCodeMedianTime(Data, input$brwyline)
  }, options = list(paging = FALSE, searching = FALSE)
  , rownames = TRUE, caption = "Top 5: Median Down Time")  

  output$text <- renderText({
    paste("Input text is:", input$faultCode, " ", input$brwyline, " ", input$depth)
  })
  
  observeEvent(input$Submit, {
    sequences <- faultCodeSequences(Data,input$faultCode, input$brwyline, input$depth)

    sequences <- unique(sequences) # List of unique sequences.
    BRWYLine <- as.data.frame(Data[which(Data[, 15] == input$brwyline),])
    # Create lags.
    for (i in 1:input$depth) {
      BRWYLine[,paste0('lag',i)] <- xts::lag.xts(BRWYLine$Fault_Code, i)
    }

    stats <- data.frame(n=integer(),prob=numeric())
    probabilities <- data.frame(seq=character(),n=integer(),probability=numeric())
    for (i in seq_along(sequences)) {
      seq <- sequences[[i]]
      stats <- faultCodeProbabilities(BRWYLine,input$faultCode,seq,input$depth)

      probabilities <- rbind(probabilities,data.frame(seq,stats$n,stats$prob))
    }
    
    values$probabilities <- probabilities
    
  })

  output$probabilities = DT::renderDataTable({
    probs <- DT::datatable(values$probabilities, rownames = FALSE,
                           caption = paste("Probablity the Sequence will lead to Fault Code", input$faultCode),
                           options = list(paging = FALSE, searching = FALSE, columnDefs = list(list(className = 'dt-right', targets = 2, type = "num-fmt"))))
    DT::formatPercentage(probs, "stats.prob")
  })  
})