package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
)

const apiURL = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/%s.json"
const fallbackURL = "https://latest.currency-api.pages.dev/v1/currencies/%s.json"

func fetchRate(base, target string) (float64, error) {
	for _, template := range []string{apiURL, fallbackURL} {
		url := fmt.Sprintf(template, base)
		resp, err := http.Get(url)
		if err != nil {
			continue
		}
		defer resp.Body.Close()

		var data map[string]interface{}
		if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
			continue
		}

		rates, ok := data[base].(map[string]interface{})
		if !ok {
			continue
		}

		rate, ok := rates[target].(float64)
		if !ok {
			return 0, fmt.Errorf("currency %q not found", strings.ToUpper(target))
		}

		return rate, nil
	}
	return 0, fmt.Errorf("request failed")
}

func main() {
	args := os.Args[1:]

	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "usage: cx KZT:RUB [amount]")
		os.Exit(1)
	}

	parts := strings.Split(args[0], ":")
	if len(parts) != 2 {
		fmt.Fprintln(os.Stderr, "usage: cx KZT:RUB [amount]")
		os.Exit(1)
	}

	from := strings.ToLower(parts[0])
	to := strings.ToLower(parts[1])

	amount := 1.0
	if len(args) >= 2 {
		var err error
		amount, err = strconv.ParseFloat(args[1], 64)
		if err != nil {
			fmt.Fprintln(os.Stderr, "invalid amount:", args[1])
			os.Exit(1)
		}
	}

	rate, err := fetchRate(from, to)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Printf("%.2f %s = %.2f %s\n", amount, strings.ToUpper(from), amount*rate, strings.ToUpper(to))
}
