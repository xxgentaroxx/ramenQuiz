library(shiny)
library(leaflet)
library(rhandsontable)
csvraw <- read.csv("quiz.csv", stringsAsFactors = FALSE, fileEncoding = "CP932")

shinyUI(navbarPage("Ramen Quiz", theme = "http://bootflat.github.io/css/site.min.css", inverse = TRUE,
  tabPanel("Map", icon = icon("map-o"),
           sliderInput("star",
                       "Minimum Stars",
                       1,10,1,
                       animate = animationOptions()),
           leafletOutput("fullmap", height = 800),
           tableOutput("shoptable")
           ),
  tabPanel("View", icon = icon("search"),
           uiOutput("searchselect"),
           uiOutput("searchimage")),
  tabPanel("Quiz", icon = icon("question-circle-o"),
           fluidRow(
             column(6,
                    uiOutput("image")
             ),
             column(6,
                    leafletOutput("map", height = 800)
             )
           ),
           actionButton("gonext","Next", class="btn-primary")
           ),
  tabPanel("Graph", icon = icon("bar-chart"),
           checkboxInput("radio",
                         "Exclude Over 10"),
           numericInput("width",
                       "Number of Bins",
                       5, 1),
           plotOutput("hist"),
           plotOutput("dist", brush = "brush"),
           tableOutput("hover")),
  tabPanel("Edit", icon = icon("pencil-square-o"),
           rHandsontableOutput("edit"),
           HTML("<br>"),
           actionButton("submit","Submit",icon("refresh"), class="btn-danger")),
  tabPanel("Upload", icon = icon("upload"),
           fileInput("file", "Upload Image", accept=c(".jpg",".jpeg")),
           textInput("shop", "Shop Name"),
           textInput("kana", "Kana"),
           textInput("image", "Image Name (with extension)"),
           numericInput("lat", "Latitude", 0, step=0.00001),
           numericInput("long", "Longitude", 0, step=0.00001),
           numericInput("stars", "Stars", 1),
           actionButton("add","Add Shop",icon("plus"), class="btn-warning"))
  
))
