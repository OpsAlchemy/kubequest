package main

import (
	"io/ioutil"
	"log"
	"strings"
	"time"
)

func main() {
	configPath := "/etc/config/log_level.conf"

	for {
		data, err := ioutil.ReadFile(configPath)
		if err != nil {
			log.Printf("Failed to read config file: %v\n", err)
		} else {
			logLevel := strings.TrimSpace(string(data)) // trim newline, etc.
			switch strings.ToUpper(logLevel) {
			case "DEBUG":
				log.Println("[DEBUG] Checking system status...")
			case "INFO":
				log.Println("[INFO] Running smoothly.")
			case "WARN":
				log.Println("[WARN] Something might need attention.")
			case "ERROR":
				log.Println("[ERROR] Something went wrong.")
			default:
				log.Printf("[UNKNOWN] Unknown log level: %s\n", logLevel)
			}
		}
		time.Sleep(10 * time.Second)
	}
}

