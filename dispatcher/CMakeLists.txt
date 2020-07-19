find_package(Protobuf REQUIRED)
include_directories(${Protobuf_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS increment.proto system.proto)

add_executable(dispatcher dispatcher.cpp ${PROTO_SRCS} ${PROTO_HDRS})
target_link_libraries(dispatcher ${Protobuf_LIBRARIES})

add_executable(handler_delegate handler_delegate.cpp ${PROTO_SRCS} ${PROTO_HDRS})
target_link_libraries(handler_delegate ${Protobuf_LIBRARIES})
