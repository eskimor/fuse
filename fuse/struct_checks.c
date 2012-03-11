#include <fuse/fuse.h>
#include <sys/types.h>

size_t c_get_fuse_file_info_size() {
	return sizeof(struct fuse_file_info);
}

int bit_field_check_fuse_file_info(struct fuse_file_info* test) {
	return test->direct_io && !test->keep_cache && test->flush && !test->nonseekable;
}
