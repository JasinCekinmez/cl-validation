````{R}
# cl-validation
For code written to do assessments of deeds data over Summer 2024

con = dbConnect(duckdb(),"/projects/SHARKEY/corelogic_pu/CorelogicDeeds/2023Update/cl.db")
NC= dbGetQuery(con, "SELECT * FROM deeds")
#df = as_tibble(NC)
dbDisconnect(con)



````