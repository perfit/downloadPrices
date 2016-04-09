#
# createPortfolio.sql
#
# Written by Michael Perfit    April 9, 2016
#
# The portfolio database is a local database of price data that is easily 
# queried from LibreOffice calc by using the function getPrice(<symbol>, <date>).
#
#  CREATE DATABASE portfolio;
#
# Price data is downloaded from yahoo with downloadPrices.go and stored in the database.
CREATE USER 'downloadPrices'@'localhost' IDENTIFIED BY 'downloadPricesPassword';
GRANT SELECT, INSERT, UPDATE ON portfolio.prices TO 'downloadPrices'@'localhost';
GRANT SELECT ON portfolio.tickers TO 'downloadPrices'@'localhost';

# Price data is lookup up with getPrice(<ticker>,<date>).
CREATE USER 'getPrice'@'localhost' IDENTIFIED BY 'getPricePassword';
GRANT SELECT ON portfolio.prices TO 'getPrice'@'localhost';

# This table lists all the ticker symbols for which price data will be gathered.
DROP TABLE IF EXISTS tickers;
CREATE TABLE tickers (
  id       INTEGER SERIAL DEFAULT VALUE PRIMARY KEY,
  ticker   CHAR(8) NOT NULL,
  description CHAR(255)
);

# It should be indexed by the ticker symbol.
DROP INDEX IF EXISTS ticker_index ON tickers;
CREATE UNIQUE INDEX ticker_index ON tickers (
     ticker
  );

# Insert the tickers into the database.  
INSERT INTO tickers VALUES (1, "VV", "Vanguard S&P 500 Index (ETF)");
INSERT INTO tickers VALUES (2, "IVE", "Vanguard S&P 500 Value Index (ETF)");
INSERT INTO tickers VALUES (3, "IJK", "iShares S&P MidCap 400 Growth (ETF)");
INSERT INTO tickers VALUES (4, "IJJ", "iShares S&P MidCap 400 Value (ETF)");
INSERT INTO tickers VALUES (5, "IJT", "iShares S&P SmallCap 600 Growth (ETF)");
INSERT INTO tickers VALUES (6, "IJS", "iShares S&P SmallCap 600 Value (ETF)");
INSERT INTO tickers VALUES (7, "RWR", "SPDR Dow Jones REIT ETF");
INSERT INTO tickers VALUES (8, "QRACX", "Search Results Oppenheimer Commodity Strategy Total Return Fund Class C");
INSERT INTO tickers VALUES (9, "DBC", "PowerShares DB Com Indx Trckng Fund (ETF)");
INSERT INTO tickers VALUES (10, "IAU", "iShares Gold Trust (ETF)");
INSERT INTO tickers VALUES (11, "VWILX", "Vanguard International Growth Fund Admiral Shares");
INSERT INTO tickers VALUES (12, "VTRIX", "Vanguard International Value Fund Investor Shares");
INSERT INTO tickers VALUES (13, "VINEX", "Vanguard International Explorer Fund Investor Shares");
INSERT INTO tickers VALUES (14, "UDN", "PowerShares DB US Dollar Bearish ETF");
INSERT INTO tickers VALUES (15, "BAC", "Bank of America");
INSERT INTO tickers VALUES (16, "VTV", "Vanguard Value ETF");
INSERT INTO tickers VALUES (17, "VOT", "Vanguard Mid-Cap Growth ETF");
INSERT INTO tickers VALUES (18, "VOE", "Vanguard Mid-Cap Value ETF");
INSERT INTO tickers VALUES (19, "VBR", "Vanguard Small-Cap Value ETF");
INSERT INTO tickers VALUES (20, "VNQ", "Vanguard REIT ETF");
INSERT INTO tickers VALUES (21, "EFA", "iShares MSCI EAFE (EFA)");
INSERT INTO tickers VALUES (22, "EFV", "iShares MSCI EAFE Value");
INSERT INTO tickers VALUES (23, "EEM", "iShares MSCI Emerging Markets");
INSERT INTO tickers VALUES (24, "IWM", "iShares Russell 2000");
INSERT INTO tickers VALUES (25, "QRAAX", "Oppenheimer Commodity Strat Total Ret A ");
INSERT INTO tickers VALUES (26, "OKS", "ONEOK Partners, L.P.");
INSERT INTO tickers VALUES (27, "OIBAX", "Oppenheimer International Bond A");
INSERT INTO tickers VALUES (28, "PFN", "PIMCO Income Strategy Fund II ");
INSERT INTO tickers VALUES (29, "SPY", "SPDR S&P 500 ETF");
INSERT INTO tickers VALUES (30, "^VIX", "Volatility S&P Index");
INSERT INTO tickers VALUES (31, "^SP500TR", "S&P 500 (TR) Index");

# This table stores the historical stock prices. 
DROP TABLE IF EXISTS prices;
CREATE TABLE prices (
  id          INTEGER  AUTO_INCREMENT NOT NULL UNIQUE PRIMARY KEY,
  ticker      CHAR(8)  NOT NULL,
  trans_date  DATE NOT NULL,
  open        DECIMAL(7, 2) UNSIGNED NOT NULL,
  high        DECIMAL(7, 2) UNSIGNED NOT NULL,
  low         DECIMAL(7, 2) UNSIGNED NOT NULL,
  close       DECIMAL(7, 2) UNSIGNED NOT NULL,
  volume      INTEGER UNSIGNED NOT NULL,
  adj_close   DECIMAL(7, 2) NOT NULL,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  );
  
# Index for retrieval by the function getPrice(<symbol>, <date>)
DROP INDEX IF EXISTS price_index ON prices;
CREATE UNIQUE INDEX price_index ON prices (trans_date, ticker);