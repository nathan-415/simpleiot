package db

import (
	"errors"
	"fmt"
	"log"
	"net"
	"strings"
	"sync"
	"time"

	genjierrors "github.com/genjidb/genji/errors"
	"github.com/google/uuid"
	natsgo "github.com/nats-io/nats.go"
	"github.com/simpleiot/simpleiot/data"
	"github.com/simpleiot/simpleiot/internal/pb"
	"github.com/simpleiot/simpleiot/msg"
	"github.com/simpleiot/simpleiot/nats"
	"google.golang.org/protobuf/proto"
)

// NatsHandler implements the SIOT NATS api
type NatsHandler struct {
	server              string
	Nc                  *natsgo.Conn
	db                  *Db
	authToken           string
	lock                sync.Mutex
	nodeUpdateLock      sync.Mutex
	updates             map[string]time.Time
	metricNodePoint     *nats.Metric
	metricNodeEdgePoint *nats.Metric
	metricNode          *nats.Metric
	metricNodeChildren  *nats.Metric
}

// NewNatsHandler creates a new NATS client for handling SIOT requests
func NewNatsHandler(db *Db, authToken, server string) *NatsHandler {
	log.Println("NATS handler connecting to: ", server)
	return &NatsHandler{
		db:        db,
		authToken: authToken,
		updates:   make(map[string]time.Time),
		server:    server,
	}
}

// Connect to NATS server and set up handlers for things we are interested in
func (nh *NatsHandler) Connect() (*natsgo.Conn, error) {
	nc, err := natsgo.Connect(nh.server,
		natsgo.Timeout(10*time.Second),
		natsgo.PingInterval(60*5*time.Second),
		natsgo.MaxPingsOutstanding(5),
		natsgo.ReconnectBufSize(5*1024*1024),
		natsgo.SetCustomDialer(&net.Dialer{
			KeepAlive: -1,
		}),
		natsgo.Token(nh.authToken),
	)

	if err != nil {
		return nil, err
	}

	nh.Nc = nc

	nh.metricNodePoint = nats.NewMetric(nc, nh.db.rootNodeID(),
		data.PointTypeMetricNatsNodePoint, time.Minute)
	nh.metricNodeEdgePoint = nats.NewMetric(nc, nh.db.rootNodeID(),
		data.PointTypeMetricNatsNodeEdgePoint, time.Minute)
	nh.metricNode = nats.NewMetric(nc, nh.db.rootNodeID(),
		data.PointTypeMetricNatsNode, time.Minute)
	nh.metricNodeChildren = nats.NewMetric(nc, nh.db.rootNodeID(),
		data.PointTypeMetricNatsNodeChildren, time.Minute)

	if _, err := nc.Subscribe("node.*.points", nh.handleNodePoints); err != nil {
		return nil, fmt.Errorf("Subscribe node points error: %w", err)
	}

	if _, err := nc.Subscribe("node.*.*.points", nh.handleEdgePoints); err != nil {
		return nil, fmt.Errorf("Subscribe edge points error: %w", err)
	}

	if _, err := nc.Subscribe("node.*", nh.handleNode); err != nil {
		return nil, fmt.Errorf("Subscribe node error: %w", err)
	}

	if _, err := nc.Subscribe("node.*.children", nh.handleNodeChildren); err != nil {
		return nil, fmt.Errorf("Subscribe node error: %w", err)
	}

	if _, err := nc.Subscribe("node.*.not", nh.handleNotification); err != nil {
		return nil, fmt.Errorf("Subscribe notification error: %w", err)
	}

	if _, err := nc.Subscribe("node.*.msg", nh.handleMessage); err != nil {
		return nil, fmt.Errorf("Subscribe message error: %w", err)
	}

	go func() {
		for {
			childNodes, err := nh.db.nodeDescendents(nh.db.rootNodeID(), "", false, false)
			if err != nil {
				log.Println("Error getting child nodes to run schedule: ", err)
			} else {
				for _, c := range childNodes {
					err := nh.runSchedule(c)
					if err != nil {
						log.Println("Error running schedule: ", err)
					}
				}
			}
			time.Sleep(time.Second * 5)
		}
	}()

	return nc, nil
}

func (nh *NatsHandler) runSchedule(node data.NodeEdge) error {
	switch node.Type {
	case data.NodeTypeRule:
		p := data.Point{Time: time.Now(), Type: data.PointTypeTrigger}
		err := nh.processRuleNode(node, "", []data.Point{p})
		if err != nil {
			return err
		}

	case data.NodeTypeGroup:
		childNodes, err := nh.db.nodeDescendents(node.ID, "", false, false)
		if err != nil {
			return err
		}
		for _, c := range childNodes {
			err := nh.runSchedule(c)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func (nh *NatsHandler) setSwUpdateState(id string, state data.SwUpdateState) error {
	p := state.Points()

	return nats.SendNodePoints(nh.Nc, id, p, false)
}

// StartUpdate starts an update
func (nh *NatsHandler) StartUpdate(id, url string) error {
	nh.lock.Lock()
	defer nh.lock.Unlock()

	if _, ok := nh.updates[id]; ok {
		return fmt.Errorf("Update already in process for dev: %v", id)
	}

	nh.updates[id] = time.Now()

	err := nh.setSwUpdateState(id, data.SwUpdateState{
		Running: true,
	})

	if err != nil {
		delete(nh.updates, id)
		return err
	}

	go func() {
		err := NatsSendFileFromHTTP(nh.Nc, id, url, func(bytesTx int) {
			err := nh.setSwUpdateState(id, data.SwUpdateState{
				Running:     true,
				PercentDone: bytesTx,
			})

			if err != nil {
				log.Println("Error setting update status in DB: ", err)
			}
		})

		state := data.SwUpdateState{
			Running: false,
		}

		if err != nil {
			state.Error = "Error updating software"
			state.PercentDone = 0
		} else {
			state.PercentDone = 100
		}

		nh.lock.Lock()
		delete(nh.updates, id)
		nh.lock.Unlock()

		err = nh.setSwUpdateState(id, state)
		if err != nil {
			log.Println("Error setting sw update state: ", err)
		}
	}()

	return nil
}

func (nh *NatsHandler) handleNodePoints(msg *natsgo.Msg) {
	start := time.Now()
	defer func() {
		t := time.Since(start).Milliseconds()
		nh.metricNodePoint.AddSample(float64(t))
	}()
	nh.nodeUpdateLock.Lock()
	defer nh.nodeUpdateLock.Unlock()

	nodeID, points, err := nats.DecodeNodePointsMsg(msg)

	if err != nil {
		fmt.Printf("Error decoding nats message: %v: %v", msg.Subject, err)
		nh.reply(msg.Reply, errors.New("error decoding node points subject"))
		return
	}

	// write points to database
	err = nh.db.nodePoints(nodeID, points)

	if err != nil {
		// TODO track error stats
		log.Printf("Error writing nodeID (%v) to Db: %v", nodeID, err)
		log.Println("msg subject: ", msg.Subject)
		nh.reply(msg.Reply, err)
		return
	}

	node, err := nh.db.node(nodeID)
	if err != nil {
		log.Println("handleNodePoints, error getting node for id: ", nodeID)
	}

	desc := node.Desc()

	// process point in upstream nodes
	err = nh.processPointsUpstream(nodeID, nodeID, desc, points)
	if err != nil {
		// TODO track error stats
		log.Println("Error processing point in upstream nodes: ", err)
	}

	nh.reply(msg.Reply, nil)
}

func (nh *NatsHandler) handleEdgePoints(msg *natsgo.Msg) {
	start := time.Now()
	defer func() {
		t := time.Since(start).Milliseconds()
		nh.metricNodeEdgePoint.AddSample(float64(t))
	}()

	nh.nodeUpdateLock.Lock()
	defer nh.nodeUpdateLock.Unlock()

	nodeID, parentID, points, err := nats.DecodeEdgePointsMsg(msg)

	if err != nil {
		fmt.Printf("Error decoding nats message: %v: %v", msg.Subject, err)
		nh.reply(msg.Reply, errors.New("error decoding edge points subject"))
		return
	}

	// write points to database
	err = nh.db.edgePoints(nodeID, parentID, points)

	if err != nil {
		// TODO track error stats
		log.Printf("Error writing edge points (%v:%v) to Db: %v", nodeID, parentID, err)
		log.Println("msg subject: ", msg.Subject)
		nh.reply(msg.Reply, err)
	}

	nh.reply(msg.Reply, nil)
}

func (nh *NatsHandler) handleNode(msg *natsgo.Msg) {
	start := time.Now()
	defer func() {
		t := time.Since(start).Milliseconds()
		nh.metricNode.AddSample(float64(t))
	}()

	resp := &pb.NodeRequest{}
	var parent string
	var nodeID string
	var node data.NodeEdge
	var err error

	chunks := strings.Split(msg.Subject, ".")
	if len(chunks) < 2 {
		resp.Error = fmt.Sprintf("Error in message subject: %v", msg.Subject)
		goto handleNodeDone
	}

	parent = string(msg.Data)

	nodeID = chunks[1]

	if nodeID == "root" {
		nodeID = nh.db.rootNodeID()
	}

	node, err = nh.db.nodeEdge(nodeID, parent)

	if err != nil {
		if err != genjierrors.ErrDocumentNotFound {
			resp.Error = fmt.Sprintf("NATS handler: Error getting node %v from db: %v\n", nodeID, err)
		} else {
			resp.Error = data.ErrDocumentNotFound.Error()
		}
	}

handleNodeDone:
	resp.Node, err = node.ToPbNode()
	if err != nil {
		resp.Error = fmt.Sprintf("Error pb encoding node: %v\n", err)
	}

	data, err := proto.Marshal(resp)

	err = nh.Nc.Publish(msg.Reply, data)
	if err != nil {
		log.Println("NATS: Error publishing response to node request: ", err)
	}
}

func (nh *NatsHandler) handleNodeChildren(msg *natsgo.Msg) {
	start := time.Now()
	defer func() {
		t := time.Since(start).Milliseconds()
		nh.metricNodeChildren.AddSample(float64(t))
	}()

	resp := &pb.NodesRequest{}
	params := pb.NatsRequest{}
	var err error
	var nodes data.Nodes
	var nodeID string

	chunks := strings.Split(msg.Subject, ".")
	if len(chunks) < 3 {
		resp.Error = fmt.Sprintf("Error in message subject: %v", msg.Subject)
		goto handleNodeChildrenDone
	}

	// decode request params
	if len(msg.Data) > 0 {
		err := proto.Unmarshal(msg.Data, &params)
		if err != nil {
			resp.Error = fmt.Sprintf("Error decoding Node children request params: %v", err)
			goto handleNodeChildrenDone
		}
	}

	nodeID = chunks[1]

	nodes, err = nh.db.nodeDescendents(nodeID, params.Type, false, params.IncludeDel)

	if err != nil {
		resp.Error = fmt.Sprintf("NATS: Error getting node %v from db: %v\n", nodeID, err)
		goto handleNodeChildrenDone
	}

handleNodeChildrenDone:
	resp.Nodes, err = nodes.ToPbNodes()
	if err != nil {
		resp.Error = fmt.Sprintf("Error pb encoding nodes: %v", err)
	}

	data, err := proto.Marshal(resp)
	if err != nil {
		resp.Error = fmt.Sprintf("Error encoding data: %v", err)
	}

	err = nh.Nc.Publish(msg.Reply, data)

	if err != nil {
		log.Println("NATS: Error publishing response to node children request: ", err)
	}
}

func (nh *NatsHandler) handleNotification(msg *natsgo.Msg) {
	chunks := strings.Split(msg.Subject, ".")
	if len(chunks) < 2 {
		log.Println("Error in message subject: ", msg.Subject)
		return
	}

	nodeID := chunks[1]

	not, err := data.PbDecodeNotification(msg.Data)

	if err != nil {
		log.Println("Error decoding Pb notification: ", err)
		return
	}

	userNodes := []data.NodeEdge{}

	var findUsers func(id string)

	findUsers = func(id string) {
		nodes, err := nh.db.nodeDescendents(id, data.NodeTypeUser, false, false)
		if err != nil {
			log.Println("Error find user nodes: ", err)
			return
		}

		for _, n := range nodes {
			userNodes = append(userNodes, n)
		}

		// now process upstream nodes
		upIDs, err := nh.db.edgeUp(id)
		if err != nil {
			log.Println("Error getting upstream nodes: ", err)
			return
		}

		for _, id := range upIDs {
			findUsers(id.Up)
		}
	}

	node, err := nh.db.node(nodeID)

	if err != nil {
		log.Println("Error getting node: ", nodeID)
		return
	}

	if node.Type == data.NodeTypeUser {
		// if we notify a user node, we only want to message this node, and not walk up the tree
		nodeEdge := node.ToNodeEdge(data.Edge{Up: not.Parent})
		userNodes = append(userNodes, nodeEdge)
	} else {
		findUsers(nodeID)
	}

	for _, userNode := range userNodes {
		user, err := data.NodeToUser(userNode.ToNode())

		if err != nil {
			log.Println("Error converting node to user: ", err)
			continue
		}

		if user.Email != "" || user.Phone != "" {
			msg := data.Message{
				ID:             uuid.New().String(),
				UserID:         user.ID,
				ParentID:       userNode.Parent,
				NotificationID: nodeID,
				Email:          user.Email,
				Phone:          user.Phone,
				Subject:        not.Subject,
				Message:        not.Message,
			}

			data, err := msg.ToPb()

			if err != nil {
				log.Println("Error serializing msg to protobuf: ", err)
				continue
			}

			err = nh.Nc.Publish("node."+user.ID+".msg", data)

			if err != nil {
				log.Println("Error publishing message: ", err)
				continue
			}
		}
	}
}

func (nh *NatsHandler) handleMessage(natsMsg *natsgo.Msg) {
	chunks := strings.Split(natsMsg.Subject, ".")
	if len(chunks) < 2 {
		log.Println("Error in message subject: ", natsMsg.Subject)
		return
	}

	nodeID := chunks[1]

	message, err := data.PbDecodeMessage(natsMsg.Data)

	if err != nil {
		log.Println("Error decoding Pb message: ", err)
		return
	}

	svcNodes := []data.NodeEdge{}

	var findSvcNodes func(string)

	level := 0

	findSvcNodes = func(id string) {
		nodes, err := nh.db.nodeDescendents(id, data.NodeTypeMsgService, false, false)
		if err != nil {
			log.Println("Error getting svc descendents: ", err)
			return
		}

		svcNodes = append(svcNodes, nodes...)

		// now process upstream nodes
		// if we are at the first level, only process the msg user parent, instead
		// of all user parents. This eliminates duplicate messages when a user is a
		// member of multiple groups which may have different notification services.

		var upIDs []*data.Edge

		if level == 0 {
			upIDs = []*data.Edge{&data.Edge{Up: message.ParentID}}
		} else {
			upIDs, err = nh.db.edgeUp(id)
			if err != nil {
				log.Println("Error getting upstream nodes: ", err)
				return
			}
		}

		level++

		for _, id := range upIDs {
			findSvcNodes(id.Up)
		}
	}

	findSvcNodes(nodeID)

	svcNodes = data.RemoveDuplicateNodesID(svcNodes)

	for _, svcNode := range svcNodes {
		svc, err := data.NodeToMsgService(svcNode.ToNode())
		if err != nil {
			log.Println("Error converting node to msg service: ", err)
			continue
		}

		if svc.Service == data.PointValueTwilio &&
			message.Phone != "" {
			twilio := msg.NewTwilio(svc.SID, svc.AuthToken, svc.From)

			err := twilio.SendSMS(message.Phone, message.Message)

			if err != nil {
				log.Printf("Error sending SMS to: %v: %v\n",
					message.Phone, err)
			}
		}
	}
}

// used for messages that want an ACK
func (nh *NatsHandler) reply(subject string, err error) {
	if subject == "" {
		// node is not expecting a reply
		return
	}

	reply := ""

	if err != nil {
		reply = err.Error()
	}

	nh.Nc.Publish(subject, []byte(reply))
}

func (nh *NatsHandler) processRuleNode(ruleNode data.NodeEdge, sourceNodeID string, points []data.Point) error {
	conditionNodes, err := nh.db.nodeDescendents(ruleNode.ID, data.NodeTypeCondition,
		false, false)
	if err != nil {
		return err
	}

	actionNodes, err := nh.db.nodeDescendents(ruleNode.ID, data.NodeTypeAction,
		false, false)
	if err != nil {
		return err
	}

	actionInactiveNodes, err := nh.db.nodeDescendents(ruleNode.ID,
		data.NodeTypeActionInactive,
		false, false)
	if err != nil {
		return err
	}

	rule, err := data.NodeToRule(ruleNode, conditionNodes, actionNodes, actionInactiveNodes)

	if err != nil {
		return err
	}

	active, changed, err := ruleProcessPoints(nh.Nc, rule, sourceNodeID, points)

	if err != nil {
		log.Println("Error processing rule point: ", err)
	}

	if active && changed {
		err := nh.ruleRunActions(nh.Nc, rule, rule.Actions, sourceNodeID)
		if err != nil {
			log.Println("Error running rule actions: ", err)
		}
	}

	if !active && changed {
		err := nh.ruleRunActions(nh.Nc, rule, rule.ActionsInactive, sourceNodeID)
		if err != nil {
			log.Println("Error running rule actions: ", err)
		}
	}

	return nil
}

func (nh *NatsHandler) processPointsUpstream(currentNodeID, nodeID, nodeDesc string, points data.Points) error {
	// at this point, the point update has already been written to the DB

	// get children and process any rules
	ruleNodes, err := nh.db.nodeDescendents(currentNodeID, data.NodeTypeRule, false, false)
	if err != nil {
		return err
	}

	for _, ruleNode := range ruleNodes {
		err := nh.processRuleNode(ruleNode, nodeID, points)
		if err != nil {
			return err
		}
	}

	// get database nodes
	dbNodes, err := nh.db.nodeDescendents(currentNodeID, data.NodeTypeDb, false, false)

	for _, dbNode := range dbNodes {

		influxConfig, err := NodeToInfluxConfig(dbNode)

		if err != nil {
			log.Println("Error with influxdb node: ", err)
			continue
		}

		idb := NewInflux(influxConfig)

		err = idb.WritePoints(nodeID, nodeDesc, points)

		if err != nil {
			log.Println("Error writing point to influx: ", err)
		}
	}

	edges, err := nh.db.edgeUp(currentNodeID)
	if err != nil {
		return err
	}

	for _, edge := range edges {

		err = nh.processPointsUpstream(edge.Up, nodeID, nodeDesc, points)
		if err != nil {
			log.Println("Rules -- error processing upstream node: ", err)
		}
	}

	return nil
}
