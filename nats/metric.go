package nats

import (
	"sync"
	"time"

	natsgo "github.com/nats-io/nats.go"
	"github.com/simpleiot/simpleiot/data"
)

// Metric is a type that can be used to track metrics and periodically report
// them to a node point. Data is queued and averaged and then the average is sent
// out as a point.
type Metric struct {
	// config
	nc           *natsgo.Conn
	nodeID       string
	reportPeriod time.Duration

	// internal state
	lastReport time.Time
	value      float64
	min        float64
	max        float64
	lock       sync.Mutex
	avg        *data.PointAverager
}

// NewMetric creates a new metric
func NewMetric(nc *natsgo.Conn, nodeID, pointType string, reportPeriod time.Duration) *Metric {
	return &Metric{
		nc:           nc,
		nodeID:       nodeID,
		reportPeriod: reportPeriod,
		lastReport:   time.Now(),
		avg:          data.NewPointAverager(pointType),
	}
}

// AddSample adds a sample and reports it if reportPeriod has expired
func (m *Metric) AddSample(s float64) error {
	m.lock.Lock()
	defer m.lock.Unlock()
	now := time.Now()
	m.avg.AddPoint(data.Point{
		Time:  now,
		Value: s,
		Min:   s,
		Max:   s,
	})

	if now.Sub(m.lastReport) > m.reportPeriod {
		err := SendNodePoint(m.nc, m.nodeID, m.avg.GetAverage(), false)
		if err != nil {
			return err
		}

		m.avg.ResetAverage()
		m.lastReport = now
	}

	return nil
}
