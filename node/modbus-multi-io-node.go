package node

import (
	"errors"

	"github.com/simpleiot/simpleiot/data"
)

// ModbusMultiIONode describes a modbus IO db node
type ModbusMultiIONode struct {
	nodeID      string
	description string
	id          int
}

// NewModbusMultiIONode Convert node to modbus IO node
func NewModbusMultiIONode(busType string, node *data.NodeEdge) (*ModbusMultiIONode, error) {
	ret := ModbusMultiIONode{
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
func (io *ModbusMultiIONode) Changed(newIO *ModbusMultiIONode) bool {
	if io.id != newIO.id {
		return true
	}

	return false
}
