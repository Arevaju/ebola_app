################################################################################
# Server Script for the Shiny Application
# Author(s):  Arevalo, J. - Randbee
################################################################################
library("plyr")
library("dplyr")

shinyServer(function(input, output, session) { 

########## Input Datasets#############
# ########## Data for Charts#############
passData0 <- reactive({   
    data <- read.table("./www/data.csv", sep = ",", check.names=FALSE,dec = ",", header= TRUE)
    data$Date <- as.Date(data$Date, "%m/%d/%y")
    data$Value <- round(as.integer(data$Value), 2) 
    data <- data[data$Country %in% input$country_filter0&data$Date %in% seq.Date(input$datara0[1],input$datara0[2], by ="days"),] 
})
###########Data for map ##################
passData <- reactive({   
  data <-  read.csv("./www/data12.csv", sep = ",", check.names=FALSE,dec = ".", header= TRUE)
  data$latitude <- jitter(data$latitude)
  data$longitude <- jitter(data$longitude)
  data$Code <- formatC(data$Code, width=5, format="d", flag="0")
  row.names(data) <- data$Code
  data <- data[data$Country %in% input$country_filter1,] 
})
########################################################################
##################LIST OF OUTPUTS#######################################
########################################################################
output$line0<- renderChart2({
  a <- rCharts:::Highcharts$new()  
  a$chart(type='line')
  data2 <- ddply(passData0(), .(Date, Category), numcolwise(sum, na.rm = TRUE)) 
  data2 <- na.omit( transform(data2, Date = as.character(format(as.Date(Date),'%m/%d/%y'))) )
  a <- hPlot(x = "Date", y = "Value", group= "Category", data = data2)       
  a$colors('rgba(240,195, 14, .5)', 'rgba(98,166, 10, .5)','rgba(240,81, 51, .5)',  'rgba(0,143, 190, .5)', 'rgba(99,93, 155, .5)', 'rgba(116,102, 67, .5)', 'rgba(42,54, 70, .5)')          
  a$xAxis(categories = data2, labels =list( crop = FALSE, overflow = FALSE, step = 3.5, align = "right", rotation = -90  ))
  a$title(text = "Ebola cases daily")
  a$exporting (enable = TRUE)     
  a$legend (verticalAlign = 'bottom',layout = 'horizontal', margin = 20)
  return(a) 
})
############################################################################ 
### Multi-Year charts output indicator 2  
 output$pie1<- renderChart2({
   a <- rCharts:::Highcharts$new()  
   data1 <- ddply(passData0(), .(Category), numcolwise(sum, na.rm = TRUE))   
   a <- hPlot(Value ~ Category, data = data1, type = 'pie') 
   a$colors('rgba(240,195, 14, .5)', 'rgba(98,166, 10, .5)','rgba(240,81, 51, .5)',  'rgba(0,143, 190, .5)', 'rgba(99,93, 155, .5)', 'rgba(116,102, 67, .5)', 'rgba(42,54, 70, .5)')    
   a$tooltip (cursor = 'pointer', enableMouseTracking = TRUE, hideDelay = 1)
   a$exporting (enable = TRUE)     
   a$title(text = "Ebola number of cases")
   a$legend (verticalAlign = 'bottom',layout = 'horizontal', margin = 20)
   return(a) 
 })
############################################
#############################################
output$pie2<- renderChart2({
  a <- rCharts:::Highcharts$new()  
  data3 <- ddply(passData0(), .(Sources), numcolwise(sum, na.rm = TRUE)) 
  a <- hPlot(Value ~ Sources, data = data3, type = 'pie')
  a$colors('rgba(240,195, 14, .5)', 'rgba(98,166, 10, .5)','rgba(240,81, 51, .5)',  'rgba(0,143, 190, .5)', 'rgba(99,93, 155, .5)', 'rgba(116,102, 67, .5)', 'rgba(42,54, 70, .5)')   
  a$tooltip (cursor = 'pointer', enableMouseTracking = TRUE, hideDelay = 1)
  a$exporting (enable = TRUE)     
  a$title(text = "Data providers")
  a$legend (verticalAlign = 'bottom',layout = 'horizontal', margin = 20)
  return(a) 
})
####################################################################################
##########################################################
output$line1<- renderChart2({
  a <- rCharts:::Highcharts$new()  
  data2 <- ddply(passData0(), .(Category), numcolwise(sum, na.rm = TRUE))
  a$title(text = "Ebola Category distribution by country")
  a <- hPlot(Value ~ Category, color = "Category", data = data2,  type = 'bar')
  a$colors('rgba(240,195, 14, .5)', 'rgba(98,166, 10, .5)','rgba(240,81, 51, .5)',  'rgba(0,143, 190, .5)', 'rgba(99,93, 155, .5)', 'rgba(116,102, 67, .5)', 'rgba(42,54, 70, .5)')   
  a$title(text = "Characterization of cases")
  a$tooltip (cursor = 'pointer', enableMouseTracking = TRUE, hideDelay = 1)
  a$exporting (enable = TRUE)     
  return(a) 
})
#######################################  
### Data table output##################
#######################################
output$data_table = renderDataTable({
  data <-  read.csv("./www/data12.csv", sep = ",", check.names=FALSE,dec = ".", header= TRUE)
})
output$downloadData <- downloadHandler(
  filename = 'data.csv',
  content = function(file) {
    write.csv(data <-  read.csv("./www/data12.csv", sep = ",", check.names=FALSE,dec = ".", header= TRUE), file, row.names=FALSE)
  }
)
######################################
#######Leaflet map ##################
map <- createLeafletMap(session, "map")
session$onFlushed(once=TRUE, function() {
  paintObs <- observe({
    sizeBy <- input$size
    map$clearShapes()
    map$addCircle(
      passData()[['latitude']],
      passData()[['longitude']],
      (passData()[[sizeBy]]* 10),
      passData()[['Code']],
      list(
        weight=2.5,
        # fill=TRUE,
        fillColor = "yellow",
        color='#c51b8a'
      )
    )
  })   
  session$onSessionEnded(paintObs$suspend)
})
# Show a popup at the given location

showCodePopup <- function(Code, lat, lng) {
  selectedZip <- passData()[passData()[['Code']] == Code,]
  content <- as.character(tagList(
    tags$strong(HTML(sprintf("%s, %s",selectedZip$Localite, selectedZip$Country))), tags$br() ,                    
    sprintf("Cases: %s", selectedZip[,3]), tags$br(),
    sprintf("Confirmed cases: %s", selectedZip[,4]), tags$br(),
    sprintf("New cases: %s", selectedZip[,6]), tags$br(),
    sprintf("Probable cases: %s", selectedZip[,7]), tags$br(),
    sprintf("Suspected cases: %s", selectedZip[,8]),tags$br(),
    sprintf("Deaths: %s", selectedZip$Deaths)
  ))
  map$showPopup(lat, lng, content, Code)
} 
# When map is clicked, show a popup with city info
clickObs <- observe({
  map$clearPopups()
  event <- input$map_shape_click
  if (is.null(event))
    return()
  
  isolate({
    showCodePopup(event$id, event$lat, event$lng)
  })
})
session$onSessionEnded(clickObs$suspend)
})