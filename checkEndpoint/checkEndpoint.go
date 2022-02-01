package checkEndpoint

import (
	"context"
	"fmt"
	"time"

	"github.com/spf13/cobra"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/sdk/trace/tracetest"
	"go.uber.org/zap"
)

func newGRPCExporter(ctx context.Context, endpoint string, additionalOpts ...otlptracegrpc.Option) *otlptrace.Exporter {
	opts := []otlptracegrpc.Option{
		otlptracegrpc.WithInsecure(),
		otlptracegrpc.WithEndpoint(endpoint),
		otlptracegrpc.WithReconnectionPeriod(50 * time.Millisecond),
	}

	opts = append(opts, additionalOpts...)
	client := otlptracegrpc.NewClient(opts...)
	exp, err := otlptrace.New(ctx, client)
	if err != nil {
		return nil
	}
	return exp
}

var roSpans = tracetest.SpanStubs{{Name: "TestingSpan"}}.Snapshots()

// Command returns checkEndpoint command
func Command() *cobra.Command {
	var endpoint string
	cmd := &cobra.Command{
		Use:     "checkEndpoint",
		Short:   "Checks endpoint of SigNoz",
		Example: "checkEndpoint -e localhost:4317",
		RunE: func(cmd *cobra.Command, args []string) error {
			zap.S().Info("checking reachability of SigNoz endpoint")

			ctx := context.Background()
			exp := newGRPCExporter(

				ctx,
				endpoint,
				otlptracegrpc.WithTimeout(10*time.Second),
				otlptracegrpc.WithRetry(otlptracegrpc.RetryConfig{Enabled: false}),
			)

			err := exp.ExportSpans(ctx, roSpans)
			if err != nil {
				return fmt.Errorf("not able to send data to SigNoz endpoint ...\n%s", err)
			} else {
				return nil
			}

		},
	}
	cmd.Flags().StringVarP(&endpoint, "endpoint", "e", "localhost:4317", "URL to SigNoz with port")
	cmd.MarkFlagRequired("endpoint")
	return cmd
}
