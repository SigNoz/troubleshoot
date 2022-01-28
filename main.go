package main

import (
	"os"

	"github.com/signoz/troubleshoot/checkEndpoint"
	"github.com/spf13/cobra"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func initZapLog() *zap.Logger {
	config := zap.NewDevelopmentConfig()
	config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	config.EncoderConfig.TimeKey = "timestamp"
	config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	logger, _ := config.Build()
	return logger
}

func main() {
	loggerMgr := initZapLog()
	zap.ReplaceGlobals(loggerMgr)
	defer loggerMgr.Sync() // flushes buffer, if any

	logger := loggerMgr.Sugar()
	logger.Info("STARTING!")

	cli := &cobra.Command{
		Use:   "signoz",
		Short: "OpenSource Observability Platform",
	}

	commands := []*cobra.Command{
		checkEndpoint.Command(),
	}

	cli.AddCommand(commands...)

	err := cli.Execute()
	if err != nil {
		zap.S().Error(err)
		os.Exit(1)
	} else {
		zap.S().Info("Successfully sent sample data to signoz ...")
	}

}
