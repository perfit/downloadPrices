#!/usr/bin/Rscript
#
# Download prices for calculating portfolio value
#
# Create .csv files with dates and prices
#
#
require(RMySQL)
require(quantstrat)
require(PerformanceAnalytics)

from = "2008-01-01"
to = Sys.Date()
options(width = 120)

# Write the symbols to the default files
putSymbols<-function(symbols)
{
  dbSendQuery(con, "TRUNCATE prices;")
  for (symbol in symbols)
     {
     print(paste("Symbol: ", symbol))
     my.df <- data.frame(ticker=symbol, eval(parse(text=symbol)))
     colnames(my.df) <- tolower(sub(pattern=paste0(symbol, "."),
                            "", names(my.df), fixed=TRUE))
     dbWriteTable(con, "prices", my.df, overwrite=FALSE, append=TRUE,
        row.names=TRUE)
     }
}

# Connect to the local database
con <- dbConnect(MySQL(), user="downloadPrices",
   password="downloadPricesPassword",
   dbname="portfolio",
   
   host="localhost")

# Look up the symbols from the portfolio
symbols <- dbGetQuery(con, "SELECT ticker FROM tickers")$ticker

# Get the symbols
options(getSymbols.warning4.0=FALSE)
getSymbols(symbols, from = from, to = to, auto.assign=TRUE)
putSymbols(symbols)

# Clean up by disconnecting the database
dbDisconnect(con)
