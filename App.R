# Код, который выполняется перед запуском сервера для создания необходимых переменных,
# импорта библиотек и т.д

# Импорт библиотек
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(scales)

# Чтение данных
df <- read.csv("forFBpost.csv", sep = ';')

# Переименуем все колонки в один стиль
names(df) <- c("City", "Year", "Fact", "Model",
               "Low_bound", "High_bound")


# Для работы с настоящим оставим только данные с 2000 - 2023
present_df <- subset(df, Year %in% 2000:2023)
# Заменим пропуски на средние значения
res <- (present_df$High_bound + present_df$Low_bound) / 2
present_df$Fact <- ifelse(is.na(present_df$Fact), res, present_df$Fact)


# Общая тема оформления для всех графиков
my_theme <- theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
                  axis.title.y = element_text(size = 14),
                  axis.title.x = element_text(size = 14),
                  axis.text.x = element_text(size = 10),
                  axis.text.y = element_text(size = 10))


# Графики
# График 1 - Топ 10 самых населенных городов
res <- aggregate(Fact ~ City, df, FUN = max)
res <- res[order(res$Fact, decreasing = T), ][1:10, ]

graph_1 <- ggplot(res, aes(x = reorder(City, -Fact), y = Fact)) + 
  geom_bar(stat = "identity", fill = 4) + 
  ggtitle("Топ 10 самых населеленных городов России") + 
  my_theme + 
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, face = "bold"),
        axis.text.y = element_blank()) + 
  geom_text(aes(label=Fact), vjust=-0.3, size=3) +
  ylab("Количество населения")


# График 2 - Топ 10 самых маленьких городов
res <- aggregate(Fact ~ City, df, FUN = max)
res <- res[order(res$Fact, decreasing = F), ][1:10, ]

graph_2 <- ggplot(res, aes(x = reorder(City, -Fact), y = Fact)) + 
  geom_bar(stat = "identity", fill = "darkgreen", alpha = 0.5) + 
  ggtitle("Топ 10 самых маленьких городов России") + 
  my_theme + 
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, face = "bold"),
        axis.text.y = element_blank()) + 
  geom_text(aes(label=Fact), vjust=-0.3, size=3) +
  ylab("Количество населения")


ui <- shinyUI(
  dashboardPage(
    # Header
    dashboardHeader(title = "My Dashboard"),
    
    # Sidebar
    dashboardSidebar(
      sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard"),
        menuItem("Raw Data", tabName = "raw_data") 
      )
    ),
    
    # Body
    dashboardBody(
      tabItems(
        tabItem(tabName = "dashboard",
                fluidRow(
                  box(plotOutput("top_10_cities_high")),
                  box(plotOutput("top_10_cities_low"))
                ),
                fluidRow(
                  box(plotOutput("fact_trend"), width = 100)
                ),
                fluidRow(
                  h2("Ниже построен аналогичный график тренда для одного города"),
                  box(plotOutput("fact_trend_one_city")),
                  box(textInput("city", label = "Укажите город:", value = "Москва")),
                  box(textInput("color", label = "Укажите цвет графика", value = 4))
                )
        ),
        tabItem(tabName = "raw_data",
                h1("Данные населения с 2000-2023 год"),
                sliderInput("row_number", label = "Выберите кол-во строк для отображения данных:", min = 1, max = 50, value = 10),
                tableOutput("data")
        )
      )
    )
  )
)

server <- shinyServer(function(input, output){
  
  # Создаем график 1
  output$top_10_cities_high <- renderPlot(
    graph_1
  )
  
  # Создаем график 2
  output$top_10_cities_low <- renderPlot(
    graph_2
  )
  
  # Отрисовка данных городов за 2000-2023 годы
  output$data <- renderTable(present_df[1:input$row_number, ])
  
  # Создаем график 3 (Для всех городов)
  output$fact_trend <- renderPlot(
    # Изменение демографии населения по годам
    ggplot(present_df, aes(Year, Fact)) + 
      stat_summary(fun.y = "sum", geom = "point", colour = "red", size = 2, na.rm = T) + 
      stat_summary(fun.y = "sum", geom = "line", colour = "red", size = 1, na.rm = T) + 
      scale_x_continuous(breaks= pretty_breaks()) + 
      my_theme + 
      ggtitle("Изменение общей демографии с 2000 года до 2023") + 
      xlab("Год") + ylab("Количество")
  )
  
  # Создаем график 4 (Для одного города)
  output$fact_trend_one_city <- renderPlot(
    ggplot(subset(present_df, City == input$city ), aes(Year, Fact)) + 
      stat_summary(fun.y = "sum", geom = "point", colour = input$color, size = 2, na.rm = T) + 
      stat_summary(fun.y = "sum", geom = "line", colour = input$color, size = 1, na.rm = T) + 
      scale_x_continuous(breaks= pretty_breaks()) + 
      my_theme + 
      ggtitle("Изменение демографии с 2000 года до 2023") + 
      xlab("Год") + ylab("Количество")
  )
})


# Run the application ----------------------------------------------------------
shinyApp(ui = ui, server = server)