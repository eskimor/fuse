import fuse.fuse;
class HelloFs : FuseOperations {
	int getattr (const(char)[] path, struct stat * stat_buf);
	int readdir (const(char)[] path, void * buf, fuse_fill_dir_t filler, off_t,
			struct fuse_file_info *);
	int open (const(char)[] path, struct fuse_file_info *);
	int read (const(char)[] path, char[] readbuf, off_t offset,
			struct fuse_file_info * info);
}
