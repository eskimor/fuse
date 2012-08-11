sources=fuse/fuse.d fuse/fuse_impl.d fuse/util.d 
hello_sources=$(sources) examples/hello.d
forward_sources=$(sources) examples/forwardfs.d
c_sources=fuse/struct_checks.o

CFLAGS=-D_FILE_OFFSET_BITS=64
.phony: all
all: c/sys/c_defs.d examples/hello
c_util/provideCsTypeDefs: c_util/provideCsTypeDefs.cc
	g++ $^ -o $@ -D_FILE_OFFSET_BITS=64
c/sys/c_defs.d: c_util/provideCsTypeDefs
	${PWD}/c_util/provideCsTypeDefs ${PWD}/c_util/header c/sys/c_defs.d
examples/hello: $(hello_sources) $(c_sources)
	dmd -unittest -debug=fuse -L-lfuse $^ -of$@
examples/forwardfs: $(forward_sources) $(c_sources)
	dmd -unittest -debug=fuse -L-lfuse dirent.o $^ -of$@ 
