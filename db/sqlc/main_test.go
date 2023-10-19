package db

import (
	"bank/util"
	"database/sql"
	"log"
	"os"
	"testing"

	_ "github.com/lib/pq"
)

var testQueries *Queries

func TestMain(m *testing.M) {
	config, err := util.LoadConfig("../..")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	conn, err := sql.Open(config.DBDriver, config.DBSource)
	if err != nil {
		log.Fatal("failed to establish connection with db:", err)
	}
	defer conn.Close()

	testQueries = New(conn)

	exitCode := m.Run()
	os.Exit(exitCode)
}
