import fuse.fuse;
class HelloFs : FuseOperations {
	int getattr (const(char)[] path, stat * stat_buf);
	int readdir (const(char)[] path, void * buf, fuse_fill_dir_t filler, off_t, fuse_file_info *);
	int open (const(char)[] path, fuse_file_info *);
	int read (const(char)[] path, char[] readbuf, off_t offset, fuse_file_info * info);
}

void main(string[] args) {
}