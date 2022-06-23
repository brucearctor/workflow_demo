package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {

	// Define HTTP server.
	http.HandleFunc("/", shippingHandler)

	// PORT environment variable is provided by Cloud Run.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	err := http.ListenAndServe(":"+port, nil)
	if err != nil {
		log.Fatal(err)
	}
}

func shippingHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello WORLD!")
}
