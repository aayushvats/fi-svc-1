package main

import (
	"database/sql"
	"net/http"

	"github.com/labstack/echo/v4"
	_ "github.com/mattn/go-sqlite3"
)

func main() {
	e := echo.New()

	db, err := sql.Open("sqlite3", "transactions.db")
	if err != nil {
		e.Logger.Fatal(err)
	}
	defer db.Close()

	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL
    );`)
	if err != nil {
		e.Logger.Fatal(err)
	}

	type Transaction struct {
		Date        string  `json:"date"`
		Amount      float64 `json:"amount"`
		Category    string  `json:"category"`
		Description string  `json:"description"`
	}

	type CategorySpending struct {
		Category      string  `json:"category"`
		TotalSpending float64 `json:"totalSpending"`
	}

	e.POST("/transactions", func(c echo.Context) error {
		var transaction Transaction
		if err := c.Bind(&transaction); err != nil {
			return err
		}

		_, err := db.Exec("INSERT INTO transactions (date, amount, category, description) VALUES (?, ?, ?, ?)",
			transaction.Date, transaction.Amount, transaction.Category, transaction.Description)
		if err != nil {
			return err
		}

		return c.String(http.StatusCreated, "Transaction stored successfully")
	})

	e.GET("/spending", func(c echo.Context) error {
		rows, err := db.Query("SELECT category, SUM(amount) AS totalSpending FROM transactions GROUP BY category")
		if err != nil {
			return err
		}
		defer rows.Close()

		var result []CategorySpending
		for rows.Next() {
			var category string
			var totalSpending float64
			if err := rows.Scan(&category, &totalSpending); err != nil {
				return err
			}
			result = append(result, CategorySpending{Category: category, TotalSpending: totalSpending})
		}

		return c.JSON(http.StatusOK, result)
	})

	e.Logger.Fatal(e.Start(":8080"))
}
