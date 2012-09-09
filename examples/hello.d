import fuse.fuse;
import std.conv;
import std.c.string;
import c.sys.fcntl;
import std.stdio;
import std.exception;
enum O_RDONLY=0;
class HelloFs : FuseOperations {
	override void getattr (in const(char)[] path, stat_t* stbuf, in ref AccessContext context) {
		memset(stbuf, 0, stat_t.sizeof);
		if(path=="/") {
			stbuf.st_mode = S_IFDIR | octal!755;
			stbuf.st_nlink = 2;
		}
		else if(path==hello_path) {
			writefln("hello_path requested!");
			stbuf.st_mode = S_IFREG | octal!444;
			stbuf.st_nlink = 1;
			stbuf.st_size = hello_str.length;
		}
		else {
			errno=ENOENT;
			throw new ErrnoException("");
		}
	}
	override void readdir (in const(char)[] path, void * buf, fuse_fill_dir_t filler, off_t offset, fuse_file_info *info, in ref AccessContext context) {
		if(path!="/") {
			errno=ENOENT;
			throw new ErrnoException("");
		}
		
		filler(buf, ".", null, 0);
		filler(buf, "..", null, 0);
		filler(buf, hello_path.ptr+1, null, 0);
	}
	override void open (in const(char)[] path, fuse_file_info *info, in ref AccessContext context) {
		if(path!=hello_path) {
			errno=ENOENT;
			throw new ErrnoException("");
		}

		if((info.flags & 3) != O_RDONLY) {
			errno=-EACCES;
			throw new ErrnoException("");
		}
	}
	override int read (in const(char)[] path, ubyte[] readbuf, off_t offset, fuse_file_info * info , in ref AccessContext context) {
		if(path!=hello_path) {
			errno=ENOENT;
			throw new ErrnoException("");
		}
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
