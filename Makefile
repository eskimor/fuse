sources=fuse/fuse.d fuse/fuse_impl.d fuse/util.d c/errno.d c/errno_linux.d c/sys/c_defs.d c/sys/stat.d c/sys/stat_defs.d c/sys/statvfs.d c/sys/fcntl.d examples/hello.d
c_sources=fuse/struct_checks.o

CFLAGS=-D_FILE_OFFSET_BITS=64
.phony: all
all: c/sys/c_defs.d examples/hello
c_util/provideCsTypeDefs: c_util/provideCsTypeDefs.cc
	g++ $^ -o $@ -D_FILE_OFFSET_BITS=64
c/sys/c_defs.d: c_util/provideCsTypeDefs
	${PWD}/c_util/provideCsTypeDefs ${PWD}/c_util/header c/sys/c_defs.d
examples/hello: $(sources) $(c_sources)
	dmd -unittest -debug=fuse -L-lfuse $^ -of$@
