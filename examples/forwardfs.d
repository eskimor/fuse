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
import xattr=core.sys.linux.sys.xattr;
import std.exception;


enum O_RDONLY=0;

/**
 * Forwards all calls to a real filesystem.
 * All methods accessing the filesystem might throw an ErrnoException if so_seteuid
 */
class ForwardFs : FuseOperations {
	/**
	 * Params:
	 * 	base_path = The path to the real filesystem which should be accessed by the methods of this class. It is more or less prependet to all paths given.
	 *  do_seteids = The filesystem will try to set the effective user/group id to the actual user accessing the file system in every call. If this fails,
	 * 						the program will simply exit for security reasons. (All users accessing the filesystem would have the rights of the user that started
	 * 						the fuse process. Especially with this forwarding filesystem it would be all to easy to let all other users access you very personal files.)
	 * 						If you know what you are doing you can set this parameter to false and the filesystem won't change the effective user/group id.
	 */
	this(string base_path="/", bool do_seteids=true) {
		forward_path_=base_path;
		do_seteids_=do_seteids;
		if(do_seteids) {
			our_uid_=unistd.getuid();
			our_euid_=unistd.geteuid();
			our_gid_=unistd.getgid();
			our_egid_=unistd.getegid();
		}
	}
	override int access (in const (char)[] path, int mask, in ref AccessContext context) {
		setRealIds(context.uid, context.gid); 
		scope(exit) restoreRealIds();
		if(unistd.access(get_forwarding_path(path.idup).toStringz(), mask)<0)
			return -errno;
		return 0;
	}
	override int getattr (in const (char)[] path, stat_t * stat_buf, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		if(lstat(get_forwarding_path(path.idup).toStringz(), stat_buf)<0)
			return -errno;
		return 0;
		
	}
	
	override int opendir (in const (char)[] path, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto dir=dirent_m.opendir(get_forwarding_path(path.idup).toStringz()); 
		if(!dir) {
			return -errno;
		}
		info.fh=cast(ulong)(dir);
		stderr.writefln("Set fh to: %s", info.fh);
		return 0;
	}
	int releasedir (in const (char)[] path, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto dir=cast(dirent_m.DIR*)(info.fh);
		if(dirent_m.closedir(dir)<0)
			return -errno;
		return 0;
	}
	override int readdir (in const (char)[] path, void * buf, fuse_fill_dir_t filler, off_t, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		dirent_m.DIR* dir;
		if(info) stderr.writefln("info.fh: %s", info.fh);
		if(info) {
			assert(info.fh);
			dir=cast(dirent_m.DIR*)(info.fh);
		}
		else {
			auto mpath=get_forwarding_path(path.idup);
			dir=dirent_m.opendir(mpath.toStringz());
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
	
	override int open (in const (char)[] path, fuse_file_info * fi, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(fi);
		int opened=fcntl.open(get_forwarding_path(path.idup).toStringz(), fi.flags);
		fi.fh=opened;
		if(opened<0)
			return -errno;
		return 0;
	}
	override int create (in const (char)[] path, mode_t mode, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		int opened=fcntl.creat(get_forwarding_path(path.idup).toStringz(), mode);
		info.fh=opened;
		if(opened<0)
			return -errno;
		return 0;
	}
	override int mknod (in const (char)[] path, mode_t mode, dev_t dev, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		if(stat.mknod(get_forwarding_path(path.idup).toStringz(), mode, dev)<0)
			return -errno;
		return 0;
	}
	override int unlink (in const (char)[] path, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		if(unistd.unlink(mpath.toStringz())<0)
			return -errno;
		return 0;
		
	}
	override int release (in const (char)[] path, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		if(unistd.close(cast(int)(info.fh))<0)
			return -errno;
		return 0;
		
	}
	override int read (in const (char)[] path, ubyte[] readbuf, off_t offset, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		int count=cast(int)(unistd.pread(fd, readbuf.ptr, readbuf.length, offset));
		if(count<0) {
			return -errno;
		}
		return count;
	}
	override int write (in const (char)[] path, in const (ubyte)[] data, off_t offset, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		int count=cast(int)unistd.pwrite(fd, data.ptr, data.length, offset);
		if(count<0)
			return -errno;
		return count;
	}
	
	override int fgetattr (in const (char)[] path, stat_t *stbuf, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		if(fstat(fd, stbuf)<0)
			return -errno;
		return 0;
	}
	
	override int setxattr (in const (char)[] path, in const (char)[] name, in const (ubyte)[] data, int flags, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		if(xattr.setxattr(get_forwarding_path(path.idup).toStringz(), name.ptr, data.ptr, data.length, flags)<0)
			return -errno;
		return 0;
	}
	
	override ssize_t getxattr (in const (char)[] path, in const (char)[] name, ubyte[] data, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		ssize_t length=xattr.getxattr(get_forwarding_path(path.idup).toStringz(), name.ptr, data.ptr, data.length);
		if(length<0)
			return -errno;
		return length;
	}

	
	override ssize_t listxattr (in const (char)[] path, char[] list, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		ssize_t length=xattr.listxattr(get_forwarding_path(path.idup).toStringz(), list.ptr, list.length);
		if(length<0)
			return -errno;
		return length;
	}

	override int removexattr (in const (char)[] path, in const (char)[] name, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		if(xattr.removexattr(get_forwarding_path(path.idup).toStringz(), name.ptr)<0)
			return -errno;
		return 0;
	}
	override int ftruncate (in const (char)[] path, off_t length, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		if(unistd.ftruncate(fd, length)<0)
			return -errno;
		return 0;
	}
	override int truncate (in const (char)[] path, off_t length, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		if(unistd.truncate(get_forwarding_path(path.idup).toStringz(), length)<0)
			return -errno;
		return 0;
	}
	
	override int utimens (in const (char)[] path, const timespec tv[], in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
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

	override int flush (in const (char)[] path, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		return 0; // Not needed implied in close().
	}

	override int chmod (in const (char)[] path, mode_t mode, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		return stat.chmod(mpath.toStringz(), mode);
	}

	override int chown (in const (char)[] path, uid_t uid, gid_t gid, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		return unistd.chown(mpath.toStringz(), uid, gid);
	}

	override int mkdir (in const (char)[] path, mode_t mode, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		return stat.mkdir(mpath.toStringz(), mode|S_IFDIR );
	}

	override int rmdir (in const (char)[] path, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
	    auto mpath=get_forwarding_path(path.idup);
		return unistd.rmdir(mpath.toStringz());
	}

	override int rename (in const (char)[] path, in const (char)[] to, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
	    auto mpath=get_forwarding_path(path.idup);
	    auto rpath=get_forwarding_path(to.idup);
		return c_stdio.rename(mpath.toStringz(), rpath.toStringz());
	}

	override int readlink (in const (char)[] path, ubyte[] buf, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
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
	
	override int symlink (in const (char)[] to, in const (char)[] path, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
	    auto mpath=get_forwarding_path(path.idup);

		if (unistd.symlink(to.toStringz(), mpath.toStringz()) < 0)
		   return -errno;
		else 
		   return 0;
	}

	override int link (in const(char)[] path, in const(char)[] to, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		auto topath=get_forwarding_path(to.idup);

		if (unistd.link(mpath.toStringz(), topath.toStringz()) < 0)
		   return -errno;
		else 
		   return 0;
	}

	override int statfs (in const(char)[] path, statvfs_t *stbuf, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);

		if (statvfs.statvfs(mpath.toStringz(), stbuf) < 0)
		   return -errno;
		else 
		   return 0;
	}

	override bool isNullPathOk() @property {
		return true;
	}
	protected:
		/**
		 * Checks do_setuid_, if falls simply does nothing. If true it sets euid and egid to the given values. If the call fails it throws.
		 * Just a little comment so I'll understand this code in the future: Checkout: http://www.lst.de/~okir/blackhats/node27.html
		 * and the man pages of setreuid, seteuid, setuid.
		 * effective user id: Usually the same as the real one, except for setuid bit programs, there it is the owner of the program. (the file on disk)
		 * real user id: The id of the user who started the program.
		 * So usually the effective user id will be 0 (root). 
		 * In the BSD world there is no saved user id, so you need to set the real user id to the effective users id (which is the privileged one) before
		 * setting the effective user id, otherwise you are not allowed to set it back.
		 *
		 * Throws:
		 * 	ErrnoException if call fails.
		 */
		void setEffectiveIds(uid_t uid, gid_t gid) {
			if(!do_seteids_)
				return;
			errnoEnforce(unistd.setreuid(our_euid_, uid)==0, "setreuid (swapping ids) failed!"); // Make sure we can gain back our idendity on BSD.
			errnoEnforce(unistd.setregid(our_egid_, gid)==0, "setregid (swapping ids) failed!");
				
		}
		/**
		 * Throws:
		 * 	ErrnoException if something goes wrong.
		 */
		void restoreEffectiveIds() {
			if(!do_seteids_)
				return;
			errnoEnforce(unistd.setreuid(our_uid_, our_euid_)==0, "setreuid (swapping ids) failed!");
			errnoEnforce(unistd.setregid(our_gid_, our_egid_)==0, "setregid (swapping ids) failed!");
		}
		/**
		 * Checks do_setuid_, if falls simply does nothing. If true it sets euid and egid to the given values. If the call fails it throws.
		 * Throws:
		 * 	ErrnoException if call fails.
		 */
		void setRealIds(uid_t uid, gid_t gid) {
			if(!do_seteids_)
				return;
			errnoEnforce(unistd.setreuid(uid, -1)==0, "setuid failed!");
			errnoEnforce(unistd.setregid(gid, -1)==0, "setgid failed!");
		}
		/**
		 * Throws:
		 * 	ErrnoException if something goes wrong.
		 */
		void restoreRealIds() {
			if(!do_seteids_)
				return;
			errnoEnforce(unistd.setreuid(our_uid_, -1)==0);
			errnoEnforce(unistd.setregid(our_gid_, -1)==0);
		}
	private:
	string get_forwarding_path(string path) {
		if(path[0]=='/') 
			path=path[1..$];
		return forward_path_~path;
	}
	string forward_path_="/";	
	bool do_seteids_=true;
	immutable(uid_t) our_uid_, our_euid_;
	immutable(gid_t) our_gid_, our_egid_;
}


void main(string[] args) {
	auto myfs=new ForwardFs("/", true);
	fuse_main(args, myfs);
}
