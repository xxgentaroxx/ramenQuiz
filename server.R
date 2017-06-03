library(shiny)
library(leaflet)
library(ggplot2)
library(rhandsontable)
csvread <- read.csv("quiz.csv", stringsAsFactors = FALSE)
distance <- sqrt((139.70709-csvread$long)^2+(35.70565-csvread$lat)^2)
csvraw <- cbind(csvread, distance)

shinyServer(function(input, output, session) {
  
  output$fullmap <- renderLeaflet({
    input$submit
    input$add
    leaflet(csvraw[csvraw$star>=input$star,]) %>% addTiles() %>% setView(mean(csvraw$long), mean(csvraw$lat), zoom = 16) %>% 
      addMarkers(~long,~lat,label=~kana)
  })
  
  output$shoptable <- renderTable({
    input$submit
    input$add
    csvraw[,c("shop","kana","star")][csvraw$star>=input$star,]
  },striped=TRUE)
  
  output$searchselect <- renderUI({
    input$submit
    input$add
    selectInput("select",
                "Shop",
                csvraw$shop)
  })
  
  output$searchimage <- renderUI({
    input$submit
    input$add
    img(src=csvraw$image[csvraw$shop==input$select], height="100%")
  })
  
  observeEvent(input$gonext,{
    input$submit
    input$add
    songList <- sample(1:nrow(csvraw))[1]
    csv <- csvraw[songList,]
    output$image <- renderUI({
      img(src=csv$image, width="100%")
    })
    
    output$map <- renderLeaflet({
      input$submit
      input$add
      leaflet(csv) %>% addTiles() %>% setView(csv$long, csv$lat, zoom = 18) %>% 
        addMarkers(~long,~lat,popup=~shop)
    })  
  })
  
  output$hist <- renderPlot({
    input$submit
    input$add
    if(input$radio==TRUE){csvraw<-csvraw[csvraw$star<=10,]}
    ggplot(csvraw, aes(star)) + geom_histogram(bins =input$width)
  })
  
  output$dist <- renderPlot({
    input$submit
    input$add
    if(input$radio==TRUE){csvraw<-csvraw[csvraw$star<=10,]}
    ggplot(csvraw, aes(star, distance, color=kana, size = 4)) + geom_point() + 
      ylab("Distance") + guides(size=FALSE, color=FALSE)
  })
  
  output$hover <- renderTable({
    input$submit
    input$add
    if(input$radio==TRUE){csvraw<-csvraw[csvraw$star<=10,]}
    brushedPoints(csvraw, input$brush)
  })
  
  output$edit <- renderRHandsontable({
    input$add
    rhandsontable(csvread[-1]) %>% 
      hot_col("lat", format = "0.0000") %>% 
      hot_col("long", format = "0.0000")
  })
  
  observeEvent(input$submit,{
    csvsub <- hot_to_r(input$edit)
    csvread <<- cbind(csvread[1], csvsub)
    write.csv(csvread, "quiz.csv", row.names=FALSE)
    distance <<- sqrt((139.70709-csvread$long)^2+(35.70565-csvread$lat)^2)
    csvraw <<- cbind(csvread, distance)
    showNotification("Edit Complete!", type="message")
  })
  
  observeEvent(input$add,{
    if(!is.null(input$file)){
      file.copy(input$file$datapath, paste0("www/",input$image))
      csvup <- data.frame(shop=input$shop, kana=input$kana, image=input$image, lat=input$lat, long=input$long, star=input$stars)
      csvread <<- rbind(csvread, csvup)
      write.csv(csvread, "quiz.csv", row.names=FALSE)
      distance <<- sqrt((139.70709-csvread$long)^2+(35.70565-csvread$lat)^2)
      csvraw <<- cbind(csvread, distance)
      showNotification("Upload Complete!", type="message")
    }
  })

})
