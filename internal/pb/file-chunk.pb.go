// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.25.0-devel
// 	protoc        v3.12.3
// source: internal/pb/file-chunk.proto

package pb

import (
	proto "github.com/golang/protobuf/proto"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

// This is a compile-time assertion that a sufficiently up-to-date version
// of the legacy proto package is being used.
const _ = proto.ProtoPackageIsVersion4

type FileChunk_State int32

const (
	FileChunk_NONE  FileChunk_State = 0
	FileChunk_START FileChunk_State = 1
	FileChunk_DONE  FileChunk_State = 2
)

// Enum value maps for FileChunk_State.
var (
	FileChunk_State_name = map[int32]string{
		0: "NONE",
		1: "START",
		2: "DONE",
	}
	FileChunk_State_value = map[string]int32{
		"NONE":  0,
		"START": 1,
		"DONE":  2,
	}
)

func (x FileChunk_State) Enum() *FileChunk_State {
	p := new(FileChunk_State)
	*p = x
	return p
}

func (x FileChunk_State) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (FileChunk_State) Descriptor() protoreflect.EnumDescriptor {
	return file_internal_pb_file_chunk_proto_enumTypes[0].Descriptor()
}

func (FileChunk_State) Type() protoreflect.EnumType {
	return &file_internal_pb_file_chunk_proto_enumTypes[0]
}

func (x FileChunk_State) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use FileChunk_State.Descriptor instead.
func (FileChunk_State) EnumDescriptor() ([]byte, []int) {
	return file_internal_pb_file_chunk_proto_rawDescGZIP(), []int{0, 0}
}

type FileChunk struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	State FileChunk_State `protobuf:"varint,1,opt,name=state,proto3,enum=pb.FileChunk_State" json:"state,omitempty"`
	Seq   int32           `protobuf:"varint,2,opt,name=seq,proto3" json:"seq,omitempty"`
	Data  []byte          `protobuf:"bytes,3,opt,name=data,proto3" json:"data,omitempty"`
}

func (x *FileChunk) Reset() {
	*x = FileChunk{}
	if protoimpl.UnsafeEnabled {
		mi := &file_internal_pb_file_chunk_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *FileChunk) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*FileChunk) ProtoMessage() {}

func (x *FileChunk) ProtoReflect() protoreflect.Message {
	mi := &file_internal_pb_file_chunk_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use FileChunk.ProtoReflect.Descriptor instead.
func (*FileChunk) Descriptor() ([]byte, []int) {
	return file_internal_pb_file_chunk_proto_rawDescGZIP(), []int{0}
}

func (x *FileChunk) GetState() FileChunk_State {
	if x != nil {
		return x.State
	}
	return FileChunk_NONE
}

func (x *FileChunk) GetSeq() int32 {
	if x != nil {
		return x.Seq
	}
	return 0
}

func (x *FileChunk) GetData() []byte {
	if x != nil {
		return x.Data
	}
	return nil
}

var File_internal_pb_file_chunk_proto protoreflect.FileDescriptor

var file_internal_pb_file_chunk_proto_rawDesc = []byte{
	0x0a, 0x1c, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 0x6c, 0x2f, 0x70, 0x62, 0x2f, 0x66, 0x69,
	0x6c, 0x65, 0x2d, 0x63, 0x68, 0x75, 0x6e, 0x6b, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x12, 0x02,
	0x70, 0x62, 0x22, 0x84, 0x01, 0x0a, 0x09, 0x46, 0x69, 0x6c, 0x65, 0x43, 0x68, 0x75, 0x6e, 0x6b,
	0x12, 0x29, 0x0a, 0x05, 0x73, 0x74, 0x61, 0x74, 0x65, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0e, 0x32,
	0x13, 0x2e, 0x70, 0x62, 0x2e, 0x46, 0x69, 0x6c, 0x65, 0x43, 0x68, 0x75, 0x6e, 0x6b, 0x2e, 0x53,
	0x74, 0x61, 0x74, 0x65, 0x52, 0x05, 0x73, 0x74, 0x61, 0x74, 0x65, 0x12, 0x10, 0x0a, 0x03, 0x73,
	0x65, 0x71, 0x18, 0x02, 0x20, 0x01, 0x28, 0x05, 0x52, 0x03, 0x73, 0x65, 0x71, 0x12, 0x12, 0x0a,
	0x04, 0x64, 0x61, 0x74, 0x61, 0x18, 0x03, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x04, 0x64, 0x61, 0x74,
	0x61, 0x22, 0x26, 0x0a, 0x05, 0x53, 0x74, 0x61, 0x74, 0x65, 0x12, 0x08, 0x0a, 0x04, 0x4e, 0x4f,
	0x4e, 0x45, 0x10, 0x00, 0x12, 0x09, 0x0a, 0x05, 0x53, 0x54, 0x41, 0x52, 0x54, 0x10, 0x01, 0x12,
	0x08, 0x0a, 0x04, 0x44, 0x4f, 0x4e, 0x45, 0x10, 0x02, 0x42, 0x2c, 0x5a, 0x2a, 0x67, 0x69, 0x74,
	0x68, 0x75, 0x62, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x73, 0x69, 0x6d, 0x70, 0x6c, 0x65, 0x69, 0x6f,
	0x74, 0x2f, 0x73, 0x69, 0x6d, 0x70, 0x6c, 0x65, 0x69, 0x6f, 0x74, 0x2f, 0x69, 0x6e, 0x74, 0x65,
	0x72, 0x6e, 0x61, 0x6c, 0x2f, 0x70, 0x62, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_internal_pb_file_chunk_proto_rawDescOnce sync.Once
	file_internal_pb_file_chunk_proto_rawDescData = file_internal_pb_file_chunk_proto_rawDesc
)

func file_internal_pb_file_chunk_proto_rawDescGZIP() []byte {
	file_internal_pb_file_chunk_proto_rawDescOnce.Do(func() {
		file_internal_pb_file_chunk_proto_rawDescData = protoimpl.X.CompressGZIP(file_internal_pb_file_chunk_proto_rawDescData)
	})
	return file_internal_pb_file_chunk_proto_rawDescData
}

var file_internal_pb_file_chunk_proto_enumTypes = make([]protoimpl.EnumInfo, 1)
var file_internal_pb_file_chunk_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_internal_pb_file_chunk_proto_goTypes = []interface{}{
	(FileChunk_State)(0), // 0: pb.FileChunk.State
	(*FileChunk)(nil),    // 1: pb.FileChunk
}
var file_internal_pb_file_chunk_proto_depIdxs = []int32{
	0, // 0: pb.FileChunk.state:type_name -> pb.FileChunk.State
	1, // [1:1] is the sub-list for method output_type
	1, // [1:1] is the sub-list for method input_type
	1, // [1:1] is the sub-list for extension type_name
	1, // [1:1] is the sub-list for extension extendee
	0, // [0:1] is the sub-list for field type_name
}

func init() { file_internal_pb_file_chunk_proto_init() }
func file_internal_pb_file_chunk_proto_init() {
	if File_internal_pb_file_chunk_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_internal_pb_file_chunk_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*FileChunk); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_internal_pb_file_chunk_proto_rawDesc,
			NumEnums:      1,
			NumMessages:   1,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_internal_pb_file_chunk_proto_goTypes,
		DependencyIndexes: file_internal_pb_file_chunk_proto_depIdxs,
		EnumInfos:         file_internal_pb_file_chunk_proto_enumTypes,
		MessageInfos:      file_internal_pb_file_chunk_proto_msgTypes,
	}.Build()
	File_internal_pb_file_chunk_proto = out.File
	file_internal_pb_file_chunk_proto_rawDesc = nil
	file_internal_pb_file_chunk_proto_goTypes = nil
	file_internal_pb_file_chunk_proto_depIdxs = nil
}