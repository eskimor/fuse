import fuse.fuse;
import std.conv;
import std.c.string;
import c.sys.fcntl;
import std.stdio;
enum O_RDONLY=0;
class HelloFs : FuseOperations {
	override int getattr (const(char)[] path, stat_t * stat_buf) {
		int res = 0;
		memset(stat_buf, 0, stat_t.sizeof);
		if(path=="/") {
			stat_buf.st_mode = S_IFDIR | octal!755;
			stat_buf.st_nlink = 2;
		}
		else if(path==hello_path) {
			writefln("hello_path requested!");
			stat_buf.st_mode = S_IFREG | octal!444;
			stat_buf.st_nlink = 1;
			stat_buf.st_size = hello_str.length;
		}
		else
			res = -ENOENT;

		return res;
	}
	union FixIt {
		int function (void* buf, const char* name, const stat_t* stbuf, off_t offset) bug_fix;
		extern (C) int function (void* buf, const char* name, const stat_t* stbuf, off_t offset) filler;
	}
	override int readdir (const(char)[] path, void * buf, fuse_fill_dir_t filler, off_t, fuse_file_info *) {
		if(path!="/")
			return -ENOENT;
		FixIt it;
		it.bug_fix=filler;
		it.filler(buf, ".", null, 0);
		it.filler(buf, "..", null, 0);
		it.filler(buf, hello_path.ptr+1, null, 0);

		return 0;
	}
	override int open (const(char)[] path, fuse_file_info * fi) {
		if(path!=hello_path)
			return -ENOENT;

		if((fi.flags & 3) != O_RDONLY)
			return -EACCES;

		return 0;
	}
	override int read (const(char)[] path, ubyte[] readbuf, off_t offset, fuse_file_info * info) {
		if(path!=hello_path)
			return -ENOENT;
		writefln("Passed buf length: %s", readbuf.length);
		writefln("Passed offset: %s", offset);
		size_t len = hello_str.length-cast(size_t)offset; // Cast save, hello world will never be larger than 2GB.
		writefln("from hello left: %s", len);
		len=readbuf.length>len ? len : readbuf.length;
		writefln("Actually copying: %s", len);
		if(offset<hello_str.length && offset>=0) {
			readbuf[0..len]=cast(immutable(ubyte)[])hello_str[cast(size_t)offset..len];
			//memcpy(readbuf.ptr, hello_str.ptr+offset, len);
			return cast(int)(len);
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
