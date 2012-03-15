.phony: all
all: c/sys/c_defs.d
c_util/provideCsTypeDefs: c_util/provideCsTypeDefs.cc
	g++ c_util/provideCsTypeDefs.cc -o c_util/provideCsTypeDefs -D_FILE_OFFSET_BITS=64
c/sys/c_defs.d: c_util/provideCsTypeDefs
	${PWD}/c_util/provideCsTypeDefs ${PWD}/c_util/header c/sys/c_defs.d
