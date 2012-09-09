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
	override void access (in const (char)[] path, int mask, in ref AccessContext context) {
		setRealIds(context.uid, context.gid); 
		scope(exit) restoreRealIds();
		errnoEnforce(unistd.access(get_forwarding_path(path.idup).toStringz(), mask)==0);
	}
	override void getattr (in const (char)[] path, stat_t * stat_buf, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		errnoEnforce(lstat(get_forwarding_path(path.idup).toStringz(), stat_buf)==0);		
	}
	
	override void opendir (in const (char)[] path, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto dir=dirent_m.opendir(get_forwarding_path(path.idup).toStringz()); 
		errnoEnforce(dir);
		info.fh=cast(ulong)(dir);
		stderr.writefln("Set fh to: %s", info.fh);
	}
	override void releasedir (in const (char)[] path, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto dir=cast(dirent_m.DIR*)(info.fh);
		errnoEnforce(dirent_m.closedir(dir)==0);
	}
	override void readdir (in const (char)[] path, void * buf, fuse_fill_dir_t filler, off_t, fuse_file_info * info, in ref AccessContext context) {
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
			errnoEnforce(dir);
		}
		dirent_m.dirent entry;
		dirent_m.dirent *p;
		int retval=dirent_m.readdir_r(dir, &entry, &p);
		while(p) {
			filler(buf, entry.d_name.ptr, null, 0);
			retval=dirent_m.readdir_r(dir, &entry, &p);
		}
		if(retval!=0) {
			errno=retval; // For the sake of consistency.
			throw new ErrnoException("");
		}
	}
	
	override void open (in const (char)[] path, fuse_file_info * fi, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(fi);
		int opened=fcntl.open(get_forwarding_path(path.idup).toStringz(), fi.flags);
		errnoEnforce(opened>=0);
		fi.fh=opened;
	}
	override void create (in const (char)[] path, mode_t mode, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		int opened=fcntl.creat(get_forwarding_path(path.idup).toStringz(), mode);
		errnoEnforce(opened>=0);
	}
	override void mknod (in const (char)[] path, mode_t mode, dev_t dev, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		errnoEnforce(stat.mknod(get_forwarding_path(path.idup).toStringz(), mode, dev)==0);
	}
	override void unlink (in const (char)[] path, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		errnoEnforce(unistd.unlink(mpath.toStringz())==0);		
	}
	override void release (in const (char)[] path, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		errnoEnforce(unistd.close(cast(int)(info.fh))==0);
	}
	override int read (in const (char)[] path, ubyte[] readbuf, off_t offset, fuse_file_info * info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		int count=cast(int)(unistd.pread(fd, readbuf.ptr, readbuf.length, offset));
		errnoEnforce(count>=0);
		return count;
	}
	override int write (in const (char)[] path, in const (ubyte)[] data, off_t offset, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		int count=cast(int)unistd.pwrite(fd, data.ptr, data.length, offset);
		errnoEnforce(count>=0);
		return count;
	}
	
	override void fgetattr (in const (char)[] path, stat_t *stbuf, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		errnoEnforce(fstat(fd, stbuf)==0);
	}
	
	override void setxattr (in const (char)[] path, in const (char)[] name, in const (ubyte)[] data, int flags, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		errnoEnforce(xattr.setxattr(get_forwarding_path(path.idup).toStringz(), name.ptr, data.ptr, data.length, flags)==0);
	}
	
	override ssize_t getxattr (in const (char)[] path, in const (char)[] name, ubyte[] data, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		ssize_t length=xattr.getxattr(get_forwarding_path(path.idup).toStringz(), name.ptr, data.ptr, data.length);
		//errnoEnforce(length>=0); Don't throw exception here, happens far too often! (Every time no data is available. a zero return would have been enough, but ok that's how it is.)
		errnoEnforce(length>=0 || errno==ENODATA);
		if(length<0)
			return -errno;
		return length;
	}

	
	override ssize_t listxattr (in const (char)[] path, char[] list, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		ssize_t length=xattr.listxattr(get_forwarding_path(path.idup).toStringz(), list.ptr, list.length);
		errnoEnforce(length>=0);
		return length;
	}

	override void removexattr (in const (char)[] path, in const (char)[] name, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		errnoEnforce(xattr.removexattr(get_forwarding_path(path.idup).toStringz(), name.ptr)==0);
	}
	override void ftruncate (in const (char)[] path, off_t length, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		assert(info);
		auto fd=cast(int)(info.fh);
		errnoEnforce(unistd.ftruncate(fd, length)==0);
	}
	override void truncate (in const (char)[] path, off_t length, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		errnoEnforce(unistd.truncate(get_forwarding_path(path.idup).toStringz(), length)==0);
	}
	
	override void utimens (in const (char)[] path, const timespec tv[], in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		timeval[2] useconds_time=void;
		foreach(i, val; tv) {
			useconds_time[i].tv_sec=val.tv_sec;
			useconds_time[i].tv_usec=val.tv_nsec/1000;
		}
		errnoEnforce(utimes(mpath.toStringz(), useconds_time)==0);
	}

	override void flush (in const (char)[] path, fuse_file_info *info, in ref AccessContext context) {
		// Empty everything done in close.
	}

	override void chmod (in const (char)[] path, mode_t mode, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		errnoEnforce(stat.chmod(mpath.toStringz(), mode)==0);
	}

	override void chown (in const (char)[] path, uid_t uid, gid_t gid, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		errnoEnforce(unistd.chown(mpath.toStringz(), uid, gid)==0);
	}

	override void mkdir (in const (char)[] path, mode_t mode, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		errnoEnforce(stat.mkdir(mpath.toStringz(), mode|S_IFDIR )==0);
	}

	override void rmdir (in const (char)[] path, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
	    auto mpath=get_forwarding_path(path.idup);
		errnoEnforce(unistd.rmdir(mpath.toStringz())==0);
	}

	override void rename (in const (char)[] path, in const (char)[] to, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
	    auto mpath=get_forwarding_path(path.idup);
	    auto rpath=get_forwarding_path(to.idup);
		errnoEnforce(c_stdio.rename(mpath.toStringz(), rpath.toStringz())==0);
	}

	override void readlink (in const (char)[] path, ubyte[] buf, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
	    auto mpath=get_forwarding_path(path.idup);
	    ssize_t len=unistd.readlink(mpath.toStringz(), cast(char*)(buf.ptr), buf.length-1);
		errnoEnforce(len>=0);
		assert(len>buf.length-1);
		assert(buf.length>0);
		buf[len]=0;
	}
	
	override void symlink (in const (char)[] to, in const (char)[] path, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
	    auto mpath=get_forwarding_path(path.idup);

		errnoEnforce(unistd.symlink(to.toStringz(), mpath.toStringz()) ==0);
	}

	override void link (in const(char)[] path, in const(char)[] to, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		auto topath=get_forwarding_path(to.idup);

		errnoEnforce(unistd.link(mpath.toStringz(), topath.toStringz()) ==0);
	}

	override void statfs (in const(char)[] path, statvfs_t *stbuf, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto mpath=get_forwarding_path(path.idup);
		errnoEnforce(statvfs.statvfs(mpath.toStringz(), stbuf) ==0);
	}

	override void fsync (in const(char)[] path, bool onlydatasync, fuse_file_info *info, in ref AccessContext context) {
		setEffectiveIds(context.uid, context.gid);
		scope(exit) restoreEffectiveIds();
		auto fd=cast(int)(info.fh);
		errnoEnforce((onlydatasync ? unistd.fdatasync(fd) : unistd.fsync(fd))==0);
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
			errnoEnforce(unistd.setregid(our_egid_, gid)==0, "setregid (swapping ids) failed!"); // First set gid our new euid might not allow setting the gid to the given value.
			errnoEnforce(unistd.setreuid(our_euid_, uid)==0, "setreuid (swapping ids) failed!"); // Make sure we can gain back our idendity on BSD.
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
			errnoEnforce(unistd.setregid(gid, -1)==0, "setgid failed!");
			errnoEnforce(unistd.setreuid(uid, -1)==0, "setuid failed!");
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
	auto myfs=new ForwardFs("/", false);
	fuse_main(args, myfs);
}
