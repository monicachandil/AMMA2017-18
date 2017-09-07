#Exercise 1
# 1. Use "women" dataframe in package 'datasets'. Find the number of women with height more than average, but weight less than average.
#
# 2. Create a data frame of 15 Indian cities and their Create a data frame of 15 Indian cities and their population size. You could refer cities and population from this page: http://worldatlas.com/articles/the-biggest-cities-in-india.html
#

install.packages("data.table")
install.packages("datasets")

mean.height<-mean(women$height)
mean.weights<-mean(women$weight)
women_df<-subset(women, women$height > mean.height & women$weight < mean.weights)
help("subset")
View(women_df)

#Method2

result= women(women$height>mean(mean$height) & women$weight<mean(mean$weight),)
nrow(result)

#Exercise 2: to read a page we have to create an HTML file of it

install.packages("xtable")
city_link = ("http://www.worldatlas.com/articles/the-biggest-cities-in-india.html")
city_file = read_html(city_link) 
#All the pages have to be converted into an html version
city_table = html_nodes(city_file, "table")
city_table_final <- html_table(city_table[1], fill= TRUE) #fill-true transfer all the data of the table into the table
View(city_table_final)
city.data=data.frame(city_table_final)
View(city.data)

#Method 2

install.packages("rvest")
install.packages("xml2")
library("xml2")
library("rvest")
city_link = "http://www.worldatlas.com/articles/the-biggest-cities-in-india.html"
city_file=read_html(city_link)
city_table=html_nodes(city_file,"table")
city_table_final<-html_table(city_table[1],fill=TRUE)
View(city_table_final)
