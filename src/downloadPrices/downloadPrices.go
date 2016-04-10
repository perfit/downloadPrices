/*
 *  downloadPrices.go
 *
 *  Written by Michael Perfit April 9, 2016
 *
 */

package main

import (
	"encoding/csv"
	"fmt"
	"github.com/ziutek/mymysql/mysql"
	_ "github.com/ziutek/mymysql/thrsafe" // Thread safe engine
	"log"
	"net/http"
	"sync"
	"time"
)

const url string = "http://real-chart.finance.yahoo.com/table.csv?s=%s&a=04&b=29&c=1986&d=%02d&e=%02d&f=%04d&g=d&ignore=.csv"

var t time.Time = time.Now().Local().AddDate(0, 0, -1) // Yesterday
var db mysql.Conn
var stmt mysql.Stmt
var client *http.Client
var wg *sync.WaitGroup

func main() {
	log.Println("downloadPrices started.")

	// Open the database.
	db = mysql.New("tcp", "", "localhost:3306", "downloadPrices", "downloadPricesPassword", "portfolio")
	err := db.Connect()
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Query the Database for the list of stock tickers
	rows, res, err := db.Query("SELECT * FROM tickers")
	if err != nil {
		log.Fatal(err)
	}

	field_no := res.Map("ticker")
	tickers := make([]string, len(rows))
	for i, row := range rows {
		tickers[i] = row.Str(field_no)
	}

	// Get a client to access the web
	client = &http.Client{}

	// Prepare the SQL statement to insert/update the prices.
	stmt, err = db.Prepare(
		"INSERT INTO prices (ticker, trans_date, open, high, low, close, volume, adj_close) VALUES (?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE open=?, high=?, low=?, close=?, volume=?, adj_close=?")
	if err != nil {
		log.Fatal(err)
	}

	// Download the data and update the database in parallel because it is easy.
	wg = new(sync.WaitGroup)
	for _, ticker := range tickers {
		wg.Add(1)
		go doSymbol(ticker, 5)
	}
	wg.Wait()
	log.Println("Normal successful completion.")
}

// Download a single stock's data (runs in parallel with copies working on other stocks).
func doSymbol(symbol string, attempts int) {
	if attempts==5 {
	    defer wg.Done()
	}
	// If we have trouble with the internet, wait 30 seconds and try again.
	defer func(symbol string, attempts int) {
		if e := recover(); e != nil {
			if attempts > 0 {
				log.Printf("Retrying %s.\n", symbol)
				time.Sleep(30 * time.Second)
				defer doSymbol(symbol, attempts-1)
			} else {
				log.Fatal(e)
			}
		}
	}(symbol, attempts)

	// Construct the URL
	u := fmt.Sprintf(url, symbol, t.Month(), t.Day(), t.Year())

	resp, err := client.Get(u)
	if err != nil {
		panic(err)
		// Handle error
	}
	defer resp.Body.Close()
	log.Printf("Completed data retrieval for %s.\n", symbol)

	r := csv.NewReader(resp.Body)
	records, err := r.ReadAll()
	if err != nil {
		log.Fatal(err)
	}

	// Now update the database
	trans, err := db.Begin()
	if err != nil {
		log.Fatal(err)
	}
	bind := trans.Do(stmt)
	for _, rec := range records[1:] {
		_, err = bind.Run(symbol, rec[0], rec[1], rec[2], rec[3], rec[4], rec[5], rec[6], rec[1], rec[2],
			rec[3], rec[4], rec[5], rec[6])
		if err != nil {
			trans.Rollback()
			log.Fatal(err)
		}
	}
	err = trans.Commit()
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("Completed database updates for %s.\n", symbol)
}
