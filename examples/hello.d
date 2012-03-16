import fuse.fuse;

import std.c.string;

class HelloFs : FuseOperations {
	int getattr (const(char)[] path, struct_stat * stat_buf) {
		int res = 0;

		memset(stbuf, 0, struct_stat.sizeof);
		if(path=="/") {
			stbuf->st_mode = S_IFDIR | 0755;
			stbuf->st_nlink = 2;
		}
		else if(path==hello_path) {
			stbuf->st_mode = S_IFREG | 0444;
			stbuf->st_nlink = 1;
			stbuf->st_size = hello_str.length;
		}
		else
			res = -ENOENT;

		return res;
	}
	int readdir (const(char)[] path, void * buf, fuse_fill_dir_t filler, off_t, fuse_file_info *) {
		if(path!="/")
			return -ENOENT;

		filler(buf, ".", null, 0);
		filler(buf, "..", null, 0);
		filler(buf, hello_path.ptr+1, null, 0);

		return 0;
	}
	int open (const(char)[] path, fuse_file_info * fi) {
		if(path!=hello_path)
			return -ENOENT;

		if((fi->flags & 3) != O_RDONLY)
			return -EACCES;

		return 0;
	}
	int read (const(char)[] path, char[] readbuf, off_t offset, fuse_file_info * info) {
		if(path!=hello_path)
			return -ENOENT;

		size_t len = hello_str.length-offset;
		size_t until = len>readbuf.length ? readbuf.length : len;
		if(offset<hello_str.length && offset>=0) {
			readbuf[]=hello_str[offset..until];
			return until-offset;
		}
		else
			return 0;
	}
	private:
	static string hello_path="/hello";
	static string hello_str="Hello World!\n";
}

void main(string[] args) {
	auto myfs=new HelloFs();
	fuse_main(args, myfs);
}
