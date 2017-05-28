# This is the user-interface definition of a Shiny web application.

library(shiny)
library(ggplot2)

shinyUI(fluidPage(
  pageWithSidebar(
    headerPanel("Machine Code Analysis"),
    sidebarPanel(
      selectInput("brwyline", label = h4("1) Choose brewery line to see Fault Code summary statistics:"), unique(Data$BRWYLine)),
      br(),
      br(),
      div(id='myDiv', class='simpleDiv',
          h4('2) Enter your sequence search inputs below.')),
      textInput("faultCode", label = h4("Enter fault code:"), value = ""),
      textInput("depth", label = h4("Enter sequence depth:"), value = ""),
      actionButton("Submit", label = "Submit"),
      verbatimTextOutput("text")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Summary Statistics",
          fluidRow(
            column(2,dataTableOutput("freqTopCount")),
            column(2,dataTableOutput("freqTopPctDowntime")),
            column(2,dataTableOutput("freqTopDowntime"))
          ),
          fluidRow(
            column(2,dataTableOutput("avgTop")),
            column(2,dataTableOutput("medTop"))
          )
        ),
        tabPanel('Sequence Probabilities',
          dataTableOutput("probabilities")
        )
      )
    )
  )
))