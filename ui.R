################################################################################
# UI Script for the Shiny Application
# Author(s):  Arevalo, J. - Randbee
################################################################################
library("shiny")
library("rCharts")
library("plyr")
library(leaflet)
# Choices for drop-downs
vars <- c(
  "Cases" = "Cases",
  "Confirmed cases" = "Confirmed cases",
  "Deaths" = "Deaths",
  "New cases" = "New cases",
  "Probable cases" = "Probable cases",
  "Suspected cases" = "Suspected cases"
)
shinyUI(navbarPage("Ebola Dashboard Tool", id="nav", fluid = TRUE, inverse = TRUE, collapsible = TRUE, 
              
      tabPanel("Interactive map",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")
                                ),
                                
                                leafletMap("map", width="100%", height="100%",
                                           initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                                           initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
                                           options=list(
                                             # center = c(37.45, -93.85),
                                             center = c(-2.36, 5.01),
                                             zoom = 5,
                                             # bounds = L.latLngBounds(southWest, northEast);
                                             # [[[-19.7960419655,-0.3878463878],[-19.7960419655,32.105843779],[15.9412689209,32.105843779],[15.9412689209,-0.3878463878],[-19.7960419655,-0.3878463878]]]
                                             maxBounds = list(list(-15.8,-18.74), list(25.94,26.75)) # Show AFRICA ONLY
                                             # maxBounds = list(list(20.961329,-10.92981), list(20.908902,-23.80481)) # Show AFRICA ONLY
                                             #     maxBounds = list(list(15.961329,-129.92981), list(52.908902,-56.80481)) # Show US only
                                           )
                                ),
                                
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                              top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = "auto",
                                              
                                              h2("Data Filters"),
                                              selectInput(inputId = 'country_filter1',
                                                          multiple = TRUE,
                                                          label = (HTML("<b>Select the country of interest:</b>")), 
                                                          choices =  c(Guinea = 'Guinea', Liberia = 'Liberia',Mali = 'Mali', 'Sierra Leone' = 'Sierra Leone', Nigeria = 'Nigeria', Senegal = 'Senegal'),
                                                          selected = c("Mali",'Guinea', 'Liberia')),
                                              selectInput("size", "Size", vars, selected = "Deaths")
                                ),
                                
                                tags$div(id="cite",
                                         'Data source by OCHA ROWCA downloaded from the Humanitarian Data Exchange Portal on Dec 16, 2014. 
                                         The data is displayed in the map as reported by WHO'
                                )
                                )
                            ),          
  tabPanel("Distribution Charts",  
#  wellPanel( 
#     div(class="span4", img(src="logo_randbee.png", height = 300, width = 350,  bg = 'transparent')
#     ),
   
   div(class="row", 
       div(class="span3",
           selectInput(inputId = 'country_filter0',
                       multiple = TRUE,
                       label = (HTML("<b>Select the country of interest:</b>")), 
                       choices =  c(Guinea = 'Guinea', Liberia = 'Liberia',Mali = 'Mali', 'Sierra Leone' = 'Sierra Leone', Nigeria = 'Nigeria', Senegal = 'Senegal'),
                       selected = c("Mali"))               
       ),  
       # column(6,
       div(class="span3",
           dateRangeInput (inputId ="datara0",
                           label = (HTML("<b>Date range:</b>")),
                           start = "2014-03-24",
                           end = "2014-11-19")

       )
       
       
       
   #)
   ),
 div(class="row", 
       div(class="span8", 
               showOutput ("line0", "highcharts")
        ), 
        
      div(class="span8", 
               showOutput ("pie1", "highcharts")
        )),
 div(class="row", 
      div(class="span9",  
       # column(6,
               showOutput ("pie2", "highcharts")
        ), 
      div(class="span9", 
               showOutput ("line1", "highcharts")
        ))
),
    tabPanel("Table Ranking", dataTableOutput("data_table"), downloadButton('downloadData', 'Download')), 
    tabPanel("About", 
             HTML("<br> Data source updated by <a href = 'https://data.hdx.rwlabs.org/dataset/rowca-ebola-cases#' target='_blank'>OCHA ROWCA</a> every working day."),
             HTML("<br><br>"),
             HTML("Application developed by <a href = 'http://randbe.es' target='_blank'>Randbee Consultants inspired by Joe Cheng.</a>") 
             )  
  )
)

