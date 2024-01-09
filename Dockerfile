#docker image that works fine with R version:4.3.2
FROM rocker/shiny-verse:4.3.2

#creates a new directory and moves us into that directory
RUN mkdir /app
WORKDIR /app

#copies our files into our new directory
COPY App.R App.R
COPY forFBpost.csv forFBpost.csv

#these are the packages used in our source code. They need to be installed separately into the dockerfile
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('scales', repos='http://cran.rstudio.com/')"

#port we use to view our app. (localhost:3838)
EXPOSE 3838

#entrypoint to execute the container
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]