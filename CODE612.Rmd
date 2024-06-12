````{R}
#installs libraries
library(DBI)
library(dbplyr)
library(dplyr)
library(duckdb)
library(duckplyr)
library(tidyr)
library(tidyselect)
library(tibble)
library(RSQLite)
````



````{R}
#creates a database connection to cl.db which is the unzipped db file with deeds as the table
#db file
con=dbConnect(duckdb(),"cl.db")

#takes the database connection and turns it into a tibble 
fullData= tbl(con, "deeds")
#print(fullData)



#filters data to show how many deeds each state has at least listed 
StateData= fullData |> group_by(`DEED SITUS STATE - STATIC`) |> summarize(n = n())
#print(StateData)

#filters data to show how many deeds each state has at least listed 
CountyData= fullData|> group_by(`DEED SITUS COUNTY - STATIC`,`DEED SITUS STATE - STATIC`)|> summarize(n = n())
#print(CountyData)


# Here I realized that the county may be listed, but the state may not be but not the converse as I have seen with previous tests 
SANDDATA=fullData |> filter(`DEED SITUS COUNTY - STATIC`=="SAN DIEGO")
#print(SANDDATA)

apnData= (fullData |> group_by(`DEED SITUS STATE - STATIC`) |> filter(`APN SEQUENCE NUMBER`!="NA")|> summarize(n = n()))
#print(apnData)

#apnData= left_join(apnData,StateData,by="DEED SITUS STATE - STATIC")
#apnData= apnData |> rename("APN Present" = `n.x`, "Total Deeds" = `n.y` )
#apnData= apnData |> mutate("% missing"= 100* (1-(`APN Present`)/(`Total Deeds`)))
#print(apnData)

#creates tibble for each column and reports the missingness 
tibbleCreator= function(column) {
#turns column into variable rather than string
column=as.name(column)
#filters entire data by state and disregards NA values and gives the total number of deeds per state satisfying the condition
data = (fullData |> group_by(`DEED SITUS STATE - STATIC`) |>filter(column !="NA") |> summarize(n = n()))
#the above table is now being appended to the right by the total # of deeds per state 
data  = left_join(data, StateData, by="DEED SITUS STATE - STATIC")
#column1=paste0(column," Present") doesn't do anything so I manually change the column name outside the function
#@ANGELA, do you have an idea of how to change the column name within the function 
data= data |> rename(column1= `n.x`, "Total Deeds" = `n.y`)
#changes column names 
options(scipen = 999)
#takes out scientific notation, QUESTION SHOULD I ROUND OR NOT TO 2 DIGITS?
data= data |> mutate("% missing"= 100* (1-((`column1`)/(`Total Deeds`)))) 
#Now gives the missingness 
return(data)
}


# checks missingness of APN Sequence Number by state 
#tibbleCreator("APN SEQUENCE NUMBER")
#data=tibbleCreator("APN SEQUENCE NUMBER")
#data =data |> rename("APN SEQUENCE NUMBER Present" = `column1`) 
#print(data)


# checks missingness of city by state 
#tibbleCreator("DEED SITUS CITY - STATIC")
#data=tibbleCreator("DEED SITUS CITY - STATIC")
#data =data |> rename("DEED SITUS CITY - STATIC Present" = `column1`) 
#print(data)


### IMPORTANT IF WE KNOW THE STATE OF THE DEED WE WILL ALWAYS KNOW THE COUNTY OF THE DEED BUT NOT THE CONVERSE
# checks missingness of county by state 
#tibbleCreator("DEED SITUS COUNTY - STATIC")
#data=tibbleCreator("DEED SITUS COUNTY - STATIC")
#data =data |> rename("DEED SITUS COUNTY - STATIC Present" = `column1`) 
#print(data)


# checks missingness of zipcode by state 
#tibbleCreator( "DEED SITUS ZIP CODE - STATIC")
#data=tibbleCreator( "DEED SITUS ZIP CODE - STATIC")
#data =data |> rename( "DEED SITUS ZIP CODE - STATIC Present" = `column1`) 
#print(data)

# checks missingness of Sale Amount by state 
#tibbleCreator(  "SALE AMOUNT")
#data=tibbleCreator(  "SALE AMOUNT")
#data =data |> rename(  "SALE AMOUNT Present" = `column1`) 
#print(data)

# checks missingness of Sale Derived Rate by state"
#tibbleCreator("SALE DERIVED DATE")
#data=tibbleCreator("SALE DERIVED DATE")
#data =data |> rename( "SALE DERIVED DATE Present" = `column1`) 
#print(data)

# checks missingness of Sale Derived Date by state"
#tibbleCreator("SALE DERIVED RECORDING DATE")
#data=tibbleCreator( "SALE DERIVED RECORDING DATE")
#data =data |> rename(  "SALE DERIVED RECORDING DATE Present" = `column1`) 
#print(data)

# checks missingness of Land Use Code by state"
#tibbleCreator("LAND USE CODE - STATIC")
#data=tibbleCreator("LAND USE CODE - STATIC")
#data =data |> rename(  "LAND USE CODE - STATIC Present" = `column1`) 
#print(data)

# checks missingness of build year by state"
#tibbleCreator("ACTUAL YEAR BUILT - STATIC")
#data=tibbleCreator("ACTUAL YEAR BUILT - STATIC")
#data =data |> rename("ACTUAL YEAR BUILT - STATIC Present" = `column1`) 
#print(data)





#disconnects in order to avoid garbage collecting 
dbDisconnect(con)


````