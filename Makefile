.phony: all
all: fuse/c_defs.d
c_util/provideCTypesDefs: c_util/provideCsTypeDefs.cc
	g++ c_util/provideCsTypeDefs.cc -o c_util/provideCTypesDefs -D_FILE_OFFSET_BITS=64
fuse/c_defs.d: c_util/provideCTypesDefs
	${PWD}/c_util/provideCTypesDefs fuse/c_defs.d
