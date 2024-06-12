````{R}
#installs library 
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
con=dbConnect(duckdb(),"cl.db")


fullData= tbl(con, "deeds")


NCdata= fullData |> filter(`DEED SITUS STATE - STATIC` == "NC") #|> collect()

print(NCdata)

dbDisconnect(con)


````