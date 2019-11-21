# downloadPrices

Maintain a local mySQL database of historical stock prices.

Package includes the following:
* portfolio.sql to create users, tables and indecies;
* R lang source, downloadPrices.R to download price history from yahoo; and 
* LibreOffice BASIC macro, getPrice.xba, to implement the
* getPrice(<ticker>, <date>) function.

The tool requires the following prerequisite software:
* R lang (with the RMySQL, quantstrat, PerformaceAnalytics packages).
* mariadb (with the mysql-connector-java-x.x.x-bin.jar

