import fuse.fuse;
import std.conv;
import std.c.string;
import c.sys.fcntl;
import std.stdio;
import c_stdio=std.c.stdio;
import std.string;
import dirent_m=core.sys.posix.dirent;
import core.sys.posix.fcntl;
import fcntl=core.sys.posix.fcntl;
import unistd=core.sys.posix.unistd;

enum O_RDONLY=0;

class ForwardFs : FuseOperations {
	override int getattr (const(char)[] path, stat_t * stat_buf) {
		if(lstat(get_forwarding_path(path.idup).toStringz(), stat_buf)<0)
			return -errno;
		return 0;
		
	}
	
	override int opendir (const(char)[] path, fuse_file_info * info) {
		auto dir=dirent_m.opendir(get_forwarding_path(path.idup).toStringz()); 
		if(!dir) {
			return -errno;
		}
		info.fh=cast(ulong)(dir);
		stderr.writefln("Set fh to: %s", info.fh);
		return 0;
	}
	int releasedir (const(char)[] path, fuse_file_info * info) {
		auto dir=cast(dirent_m.DIR*)(info.fh);
		if(dirent_m.closedir(dir)<0)
			return -errno;
		return 0;
	}
	override int readdir (const(char)[] path, void * buf, fuse_fill_dir_t filler, off_t, fuse_file_info * info) {
		dirent_m.DIR* dir;
		if(info) stderr.writefln("info.fh: %s", info.fh);
		if(info) {
			assert(info.fh);
			dir=cast(dirent_m.DIR*)(info.fh);
		}
		else {
			path=get_forwarding_path(path.idup);
			dir=dirent_m.opendir(path.toStringz());
			scope(exit) dirent_m.closedir(dir);
			if(!dir) {
				return -errno;
			}
		}
		dirent_m.dirent entry;
		dirent_m.dirent *p;
		int retval=dirent_m.readdir_r(dir, &entry, &p);
		while(p) {
			filler(buf, entry.d_name.ptr, null, 0);
			retval=dirent_m.readdir_r(dir, &entry, &p);
		}
		return -retval;
	}
	
	override int open (const(char)[] path, fuse_file_info * fi) {
		assert(fi);
		int opened=fcntl.open(get_forwarding_path(path.idup).toStringz(), fi.flags);
		fi.fh=opened;
		if(opened<0)
			return -errno;
		return 0;
	}
	override int release (const(char)[] path, fuse_file_info * info) {
		assert(info);
		if(unistd.close(cast(int)(info.fh))<0)
			return -errno;
		return 0;
		
	}
	override int read (const(char)[] path, ubyte[] readbuf, off_t offset, fuse_file_info * info) {
		assert(info);
		auto fd=cast(int)(info.fh);
		int count=cast(int)(unistd.pread(fd, readbuf.ptr, readbuf.length, offset));
		if(count<0) {
			return -errno;
		}
		return count;
	}
	private:
	string get_forwarding_path(string path) {
		if(path[0]=='/') 
			path=path[1..$];
		return forward_path_~path;
	}
	string forward_path_="/";	
}

void main(string[] args) {
	auto myfs=new ForwardFs();
	fuse_main(args, myfs);
}
