#Exercise 3
#Create a data frame of "Custs”
#ID as distinct numerical values
#Income is normal distribution M:250000 and SD:75000
#Gender 60% are Male in the sample HINT: runif and ifelse

help(rnorm)
normal_income = rnorm(10, mean=250000, sd= 75000)
View(normal_income)

id<- c(1:100)
#generating random number - incomes
income<-rnorm(100, mean=250000, sd= 75000)

#generating with another constraint - first 60 - Males and rest 40 females using function repeat
help("repeat")

gender <-c(rep("F",100))
i<-sample(1:100,100, replace = FALSE) #100 unique integers, if true was written, numbers would repeat themselves
for(q in 1:100) {
  
  if(gender[i[q]]=="F" && q<=40){
    
  }
  
  else{
    gender[i[q]]<-c("M")
  }
}

gender
table(gender)
