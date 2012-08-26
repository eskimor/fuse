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
import core.sys.posix.sys.time;
import stat=core.sys.posix.sys.stat;
import statvfs=core.sys.posix.sys.statvfs;


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
	override int create (const(char)[] path, mode_t mode, fuse_file_info *info) {
		assert(info);
		int opened=fcntl.creat(get_forwarding_path(path.idup).toStringz(), mode);
		info.fh=opened;
		if(opened<0)
			return -errno;
		return 0;
	}
	override int mknod (const(char)[] path, mode_t mode, dev_t dev) {
		if(stat.mknod(get_forwarding_path(path.idup).toStringz(), mode, dev)<0)
			return -errno;
		return 0;
	}
	override int unlink (const(char)[] path) {
		auto mpath=get_forwarding_path(path.idup);
		if(unistd.unlink(mpath.toStringz())<0)
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
	override int write (const(char)[] path, const(ubyte)[] data, off_t offset, fuse_file_info *info) {
		assert(info);
		auto fd=cast(int)(info.fh);
		int count=cast(int)unistd.pwrite(fd, data.ptr, data.length, offset);
		if(count<0)
			return -errno;
		return count;
	}
	
	override int fgetattr (const(char)[] path, stat_t *stbuf, fuse_file_info *info) {
		assert(info);
		auto fd=cast(int)(info.fh);
		if(fstat(fd, stbuf)<0)
			return -errno;
		return 0;
	}
	
	override int setxattr (const(char)[] path, const(char)[] name, const(ubyte)[] data, int flags) {
		//if(xattr.setxattr(get_forwarding_path(path.idup).toStringz(), 
		// Waiting for xattr in druntime. Already on it.
		return -1;
	}
	
	override int ftruncate (const(char)[] path, off_t length, fuse_file_info *info) {
		assert(info);
		auto fd=cast(int)(info.fh);
		if(unistd.ftruncate(fd, length)<0)
			return -errno;
		return 0;
	}
	override int truncate (const(char)[] path, off_t length) {
		if(unistd.truncate(get_forwarding_path(path.idup).toStringz(), length)<0)
			return -errno;
		return 0;
	}
	
	override int utimens (const(char)[] path, const timespec tv[]) {
		auto mpath=get_forwarding_path(path.idup);
		timeval[2] useconds_time=void;
		foreach(i, val; tv) {
			useconds_time[i].tv_sec=val.tv_sec;
			useconds_time[i].tv_usec=val.tv_nsec/1000;
		}
		if(utimes(mpath.toStringz(), useconds_time)<0)
			return -errno;
		return 0;
	}

	override int flush (const(char)[] path, fuse_file_info *info) {
		return 0; // Not needed implied in close().
	}

	override int chmod (const(char)[] path, mode_t mode) {
		auto mpath=get_forwarding_path(path.idup);
		return stat.chmod(mpath.toStringz(), mode);
	}

	override int chown (const(char)[] path, uid_t uid, gid_t gid) {
		auto mpath=get_forwarding_path(path.idup);
		return unistd.chown(mpath.toStringz(), uid, gid);
	}

	override int mkdir (const(char)[] path, mode_t mode) {
		auto mpath=get_forwarding_path(path.idup);
		return stat.mkdir(mpath.toStringz(), mode|S_IFDIR );
	}

	override int rmdir (const(char)[] path) {
	    	auto mpath=get_forwarding_path(path.idup);
		return unistd.rmdir(mpath.toStringz());
	}

	override int rename (const(char)[] path, const(char)[] to) {
	    	auto mpath=get_forwarding_path(path.idup);
	    	auto rpath=get_forwarding_path(to.idup);
		return c_stdio.rename(mpath.toStringz(), rpath.toStringz());
	}

	override int readlink (const(char)[] path, ubyte[] buf) {
	    	auto mpath=get_forwarding_path(path.idup);
	    	ssize_t len;
		len=unistd.readlink(mpath.toStringz(), cast(char*)(buf.ptr), buf.length);
		if (len < 0) {	
		   return -errno;
		}
		else if (len >= buf.length) {
		   return cast(int)len;
		}
		else {
		   buf[len]='\0';
		   return 0;
		}
	}
	
	override int symlink (const(char)[] to, const(char)[] path) {
	    	auto mpath=get_forwarding_path(path.idup);

		if (unistd.symlink(to.toStringz(), mpath.toStringz()) < 0)
		   return -errno;
		else 
		   return 0;
	}

	override int link (const(char)[] path, const(char)[] to) {
		auto mpath=get_forwarding_path(path.idup);
		auto topath=get_forwarding_path(to.idup);

		if (unistd.link(mpath.toStringz(), topath.toStringz()) < 0)
		   return -errno;
		else 
		   return 0;
	}

	override int statfs (const(char)[] path, statvfs_t *stbuf) {
		auto mpath=get_forwarding_path(path.idup);

		if (statvfs.statvfs(mpath.toStringz(), stbuf) < 0)
		   return -errno;
		else 
		   return 0;
	}

	override bool isNullPathOk() @property {
		return true;
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
