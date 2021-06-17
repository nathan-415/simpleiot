package node

import (
	"errors"

	"github.com/simpleiot/simpleiot/data"
)

// ModbusAdam4051Node describes a modbus IO db node
type ModbusAdam4051Node struct {
	nodeID      string
	description string
	id          int
}

// NewModbusAdam4051 Convert node to modbus IO node
func NewModbusAdam4051Node(busType string, node *data.NodeEdge) (*ModbusAdam4051Node, error) {
	ret := ModbusAdam4051Node{
		nodeID: node.ID,
	}

	var ok bool

	ret.id, ok = node.Points.ValueInt("", data.PointTypeID, 0)
	if busType == data.PointValueClient && !ok {
		if busType == data.PointValueServer {
			return nil, errors.New("Must define modbus ID")
		}
	}

	ret.description, _ = node.Points.Text("", data.PointTypeDescription, 0)

	return &ret, nil
}

// Changed returns true if the config of the IO has changed
// FIXME, we should not need this once we get NATS wired
func (io *ModbusAdam4051Node) Changed(newIO *ModbusAdam4051Node) bool {
	if io.id != newIO.id {
		return true
	}

	return false
}
