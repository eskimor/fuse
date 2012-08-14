module fuse.fuse;
import fuse.util;
import std.bitmanip;
import core.stdc.config;
import core.sys.posix.sys.types;
public import core.sys.posix.sys.statvfs;
public import core.stdc.errno;
public import core.sys.posix.sys.stat; 
public import core.sys.posix.time;
import core.sys.posix.fcntl; 
import core.sys.posix.utime;
import std.container;
/**
 * Main interface you have to implement for a fuse filesystem.
 * Usually you won't derive from this interface directly but instead from 
 * the auto generated (thanks to compile time reflection and mixins) FuseOperations
 * class which implements default implementations for all methods, just spiting out a not
 * implemented error.
 * All pointers and arrays passed to the methods in this interfaces refer to the original data passed
 * by the fuse library, if you have to keep a reference, copy the data.
*/
interface FuseOperationsInterface {
	/** Get file attributes.
	 *
	 * Similar to stat().  The 'st_dev' and 'st_blksize' fields are
	 * ignored.	 The 'st_ino' field is ignored except if the 'use_ino'
	 * mount option is given.
	 */
	int getattr (const(char)[] path, stat_t* stbuf);

	/** Read the target of a symbolic link
	 *
	 * The buffer should be filled with a null terminated string.  The
	 * buffer size argument includes the space for the terminating
	 * null character.	If the linkname is too long to fit in the
	 * buffer, it should be truncated.	The return value should be 0
	 * for success.
	 */
	int readlink (const(char)[] path, ubyte[] buf);

	/** Create a file node
	 *
	 * This is called for creation of all non-directory, non-symlink
	 * nodes.  If the filesystem defines a create() method, then for
	 * regular files that will be called instead.
	 */
	int mknod (const(char)[] path, mode_t mode, dev_t dev);

	/** Create a directory 
	 *
	 * Note that the mode argument may not have the type specification
	 * bits set, i.e. S_ISDIR(mode) can be false.  To obtain the
	 * correct directory type bits use  mode|S_IFDIR
	 * */
	int mkdir (const(char)[] path, mode_t mode);

	/** Remove a file */
	int unlink (const(char)[] path);

	/** Remove a directory */
	int rmdir (const(char)[] path);

	/** Create a symbolic link */
	int symlink (const(char)[] path, const(char)[] to);

	/** Rename a file */
	int rename (const(char)[] path, const(char)[] to);

	/** Create a hard link to a file */
	int link (const(char)[] path, const(char)[] to);

	/** Change the permission bits of a file */
	int chmod (const(char)[] path, mode_t mode);

	/** Change the owner and group of a file */
	int chown (const(char)[] path, uid_t uid, gid_t gid);

	/** Change the size of a file */
	int truncate (const(char)[] path, off_t length);

	/** File open operation
	 *
	 * No creation (O_CREAT, O_EXCL) and by default also no
	 * truncation (O_TRUNC) flags will be passed to open(). If an
	 * application specifies O_TRUNC, fuse first calls truncate()
	 * and then open(). Only if 'atomic_o_trunc' has been
	 * specified and kernel version is 2.6.24 or later, O_TRUNC is
	 * passed on to open.
	 *
	 * Unless the 'default_permissions' mount option is given,
	 * open should check if the operation is permitted for the
	 * given flags. Optionally open may also return an arbitrary
	 * filehandle in the fuse_file_info structure, which will be
	 * passed to all file operations.
	 *
	 * Changed in version 2.2
	 */
	int open (const(char)[] path, fuse_file_info *info);

	/** Read data from an open file
	 *
	 * Read should return exactly the number of bytes requested except
	 * on EOF or error, otherwise the rest of the data will be
	 * substituted with zeroes.	 An exception to this is when the
	 * 'direct_io' mount option is specified, in which case the return
	 * value of the read system call will reflect the return value of
	 * this operation.
	 *
	 * Changed in version 2.2
	 */
	int read (const(char)[] path, ubyte[] readbuf, off_t offset,
			fuse_file_info * info );

	/** Write data to an open file
	 *
	 * Write should return exactly the number of bytes requested
	 * except on error.	 An exception to this is when the 'direct_io'
	 * mount option is specified (see read operation).
	 *
	 * Changed in version 2.2
	 */
	int write (const(char)[] path, const(ubyte)[] data, off_t offset, fuse_file_info *info);

	/** Get file system statistics
	 *
	 * The 'f_frsize', 'f_favail', 'f_fsid' and 'f_flag' fields are ignored
	 *
	 * Replaced 'struct statfs' parameter with 'struct statvfs' in
	 * version 2.5
	 */
	int statfs (const(char)[] path, statvfs_t *stbuf);

	/** Possibly flush cached data
	 *
	 * BIG NOTE: This is not equivalent to fsync().  It's not a
	 * request to sync dirty data.
	 *
	 * Flush is called on each close() of a file descriptor.  So if a
	 * filesystem wants to return write errors in close() and the file
	 * has cached dirty data, this is a good place to write back data
	 * and return any errors.  Since many applications ignore close()
	 * errors this is not always useful.
	 *
	 * NOTE: The flush() method may be called more than once for each
	 * open().	This happens if more than one file descriptor refers
	 * to an opened file due to dup(), dup2() or fork() calls.	It is
	 * not possible to determine if a flush is final, so each flush
	 * should be treated equally.  Multiple write-flush sequences are
	 * relatively rare, so this shouldn't be a problem.
	 *
	 * Filesystems shouldn't assume that flush will always be called
	 * after some writes, or that if will be called at all.
	 *
	 * Changed in version 2.2
	 */
	int flush (const(char)[] path, fuse_file_info *info);

	/** Release an open file
	 *
	 * Release is called when there are no more references to an open
	 * file: all file descriptors are closed and all memory mappings
	 * are unmapped.
	 *
	 * For every open() call there will be exactly one release() call
	 * with the same flags and file descriptor.	 It is possible to
	 * have a file opened more than once, in which case only the last
	 * release will mean, that no more reads/writes will happen on the
	 * file.  The return value of release is ignored.
	 *
	 * Changed in version 2.2
	 */
	int release (const(char)[] path, fuse_file_info *info);

	/** Synchronize file contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data.
	 *
	 * Changed in version 2.2
	 */
	int fsync (const(char)[] path, bool onlyldatasync, fuse_file_info *info);

	/** Set extended attributes */
	int setxattr (const(char)[] path, const(char)[] name, const(ubyte)[] data, int flags);

	/** Get extended attributes */
	int getxattr (const(char)[] path, const(char)[] name, ubyte[] data);

	/** List extended attributes */
	/**
	 * @param list Provide all attribute names separated by '\0'.
	 */
	int listxattr (const(char)[] path, char[] list);

	/** Remove extended attributes */
	int removexattr (const(char)[] path, const(char)[] name);

	/** Open directory
	 *
	 * Unless the 'default_permissions' mount option is given,
	 * this method should check if opendir is permitted for this
	 * directory. Optionally opendir may also return an arbitrary
	 * filehandle in the fuse_file_info structure, which will be
	 * passed to readdir, closedir and fsyncdir.
	 *
	 * Introduced in version 2.3
	 */
	int opendir (const(char)[] path, fuse_file_info *info);

	/** Read directory
	 *
	 * This supersedes the old getdir() interface.  New applications
	 * should use this.
	 *
	 * The filesystem may choose between two modes of operation:
	 *
	 * 1) The readdir implementation ignores the offset parameter, and
	 * passes zero to the filler function's offset.  The filler
	 * function will not return '1' (unless an error happens), so the
	 * whole directory is read in a single readdir operation.  This
	 * works just like the old getdir() method.
	 *
	 * 2) The readdir implementation keeps track of the offsets of the
	 * directory entries.  It uses the offset parameter and always
	 * passes non-zero offset to the filler function.  When the buffer
	 * is full (or an error happens) the filler function will return
	 * '1'.
	 *
	 * Introduced in version 2.3
	 */
	int readdir (const(char)[] path, void * buf, fuse_fill_dir_t filler, off_t offset,
			fuse_file_info *info);

	/** Release directory
	 *
	 * Introduced in version 2.3
	 */
	int releasedir (const(char)[] path, fuse_file_info *info);

	/** Synchronize directory contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data
	 *
	 * Introduced in version 2.3
	 */
	int fsyncdir (const(char)[] path, int, fuse_file_info *info);
	// Not needed, so it is not forwarded to this interface, don't implement it!
	/**
	 * Initialize filesystem
	 *
	 * The return value will passed in the private_data field of
	 * fuse_context to all file operations and as a parameter to the
	 * destroy() method.
	 *
	 * Introduced in version 2.3
	 * Changed in version 2.6
	 */
	//void *init (fuse_conn_info *conn);

	/**
	 * Clean up filesystem
	 *
	 * Called on filesystem exit.
	 *
	 * Introduced in version 2.3
	 */
	void destroy (void *private_data);

	/**
	 * Check file access permissions
	 *
	 * This will be called for the access() system call.  If the
	 * 'default_permissions' mount option is given, this method is not
	 * called.
	 *
	 * This method is not called under Linux kernel versions 2.4.x
	 *
	 * Introduced in version 2.5
	 */
	int access (const(char)[] path, int mask);

	/**
	 * Create and open a file
	 *
	 * If the file does not exist, first create it with the specified
	 * mode, and then open it.
	 *
	 * If this method is not implemented or under Linux kernel
	 * versions earlier than 2.6.15, the mknod() and open() methods
	 * will be called instead.
	 *
	 * Introduced in version 2.5
	 */
	int create (const(char)[] path, mode_t mode, fuse_file_info *info);

	/**
	 * Change the size of an open file
	 *
	 * This method is called instead of the truncate() method if the
	 * truncation was invoked from an ftruncate() system call.
	 *
	 * If this method is not implemented or under Linux kernel
	 * versions earlier than 2.6.15, the truncate() method will be
	 * called instead.
	 *
	 * Introduced in version 2.5
	 */
	int ftruncate (const(char)[] path, off_t length, fuse_file_info *info);

	/**
	 * Get attributes from an open file
	 *
	 * This method is called instead of the getattr() method if the
	 * file information is available.
	 *
	 * Currently this is only called after the create() method if that
	 * is implemented (see above).  Later it may be called for
	 * invocations of fstat() too.
	 *
	 * Introduced in version 2.5
	 */
	int fgetattr (const(char)[] path, stat_t *stbuf, fuse_file_info *info);

	/**
	 * Perform POSIX file locking operation
	 *
	 * The cmd argument will be either F_GETLK, F_SETLK or F_SETLKW.
	 *
	 * For the meaning of fields in 'struct flock' see the man page
	 * for fcntl(2).  The l_whence field will always be set to
	 * SEEK_SET.
	 *
	 * For checking lock ownership, the 'fuse_file_info->owner'
	 * argument must be used.
	 *
	 * For F_GETLK operation, the library will first check currently
	 * held locks, and if a conflicting lock is found it will return
	 * information without calling this method.	 This ensures, that
	 * for local locks the l_pid field is correctly filled in.	The
	 * results may not be accurate in case of race conditions and in
	 * the presence of hard links, but it's unlikly that an
	 * application would rely on accurate GETLK results in these
	 * cases.  If a conflicting lock is not found, this method will be
	 * called, and the filesystem may fill out l_pid by a meaningful
	 * value, or it may leave this field zero.
	 *
	 * For F_SETLK and F_SETLKW the l_pid field will be set to the pid
	 * of the process performing the locking operation.
	 *
	 * Note: if this method is not implemented, the kernel will still
	 * allow file locking to work locally.  Hence it is only
	 * interesting for network filesystems and similar.
	 *
	 * Introduced in version 2.6
	 */
	int lock (const(char)[] path, fuse_file_info *info, int cmd, flock *locks);

	/**
	 * Change the access and modification times of a file with
	 * nanosecond resolution
	 *
	 * Introduced in version 2.6
	 */
	int utimens (const(char)[] path, const timespec tv[]);

	/**
	 * Map block index within file to block index within device
	 *
	 * Note: This makes sense only for block device backed filesystems
	 * mounted with the 'blkdev' option
	 *
	 * Introduced in version 2.6
	 */
	int bmap (const(char)[] path, size_t blocksize, ulong *idx);
	


	/**
	 * Ioctl
	 *
	 * flags will have FUSE_IOCTL_COMPAT set for 32bit ioctls in
	 * 64bit environment.  The size and direction of data is
	 * determined by _IOC_*() decoding of cmd.  For _IOC_NONE,
	 * data will be NULL, for _IOC_WRITE data is out area, for
	 * _IOC_READ in area and if both are set in/out area.  In all
	 * non-NULL cases, the area is of _IOC_SIZE(cmd) bytes.
	 *
	 * Introduced in version 2.8
	 */
	int ioctl (const(char)[] path, int cmd, void *arg, fuse_file_info *, uint flags, void *data);

	/**
	 * Poll for IO readiness events
	 *
	 * Note: If ph is non-NULL, the client should notify
	 * when IO readiness events occur by calling
	 * fuse_notify_poll() with the specified ph.
	 *
	 * Regardless of the number of times poll with a non-NULL ph
	 * is received, single notification is enough to clear all.
	 * Notifying more times incurs overhead but doesn't harm
	 * correctness.
	 *
	 * The callee is responsible for destroying ph with
	 * fuse_pollhandle_destroy() when no longer in use.
	 *
	 * Introduced in version 2.8
	 */
	int poll (const(char)[] path, fuse_file_info *info,	fuse_pollhandle *ph, uint *reventsp);
	bool isNullPathOk() @property;
}

version(unittest) {
import std.stdio;
}
/**
 * Derive from FuseOperations, if you want to have predefined methods, which simply spit out a not implemented error.
*/ 
mixin(createImplementation!(FuseOperationsInterface, "FuseOperations")());
//void main() {
	//writefln("Created impl:\n%s", createImplementation!(FuseOperationsInterface, "FuseOperations")());
//}

int fuse_main(const(char[])[] args, FuseOperationsInterface operations) {
	const(char)*[] c_args=new const(char)*[](args.length);
	foreach(i, arg; args) 
		c_args[i]=arg.ptr;
	mixin(initializeFuncPtrStruct!(fuse_operations, "my_operations", "deimos_d_fuse_")());
	debug(fuse) writefln("Initialize struct: ");
	debug(fuse) writefln(initializeFuncPtrStruct!(fuse_operations, "my_operations", "deimos_d_fuse_")());
	
	assert(my_operations.getattr==&deimos_d_fuse_getattr);
	assert(my_operations.read==&deimos_d_fuse_read);
	assert(my_operations.readdir==&deimos_d_fuse_readdir);
	my_operations.flag_nullpath_ok=operations.isNullPathOk;
	return fuse_main_real(cast(int)c_args.length, c_args.ptr, &my_operations, my_operations.sizeof, cast(void*) operations);
}

extern(C):
alias int function (void* buf, const char* name, const stat_t* stbuf, off_t offset) fuse_fill_dir_t;	
//alias fuse_fill_dir_t int function (fuse_dirh_t h, const char *name, int type, ino_t ino); // Don't know where I have got this definition from, but it is wrong.
extern struct fuse_dirhandle;
extern struct fuse_pollhandle;
//alias fuse_fill_dir_t* fuse_dirhandle;

struct fuse_file_info {
	/** Open flags.	 Available in open() and release() */
	int flags;

	/** Old file handle, don't use */
	c_ulong fh_old;


	/** In case of a write operation indicates if this was caused by a
	  writepage */
	int writepage;
	mixin(bitfields!(
		bool, "direct_io", 1,
		bool, "keep_cache", 1,
		bool, "flush", 1,
		bool, "unseekable", 1,
		uint, "padding", 28));

	/** File handle.  May be filled in by filesystem in open().
	  Available in all other file operations */
	ulong fh;

	/** Lock owner id.  Available in locking operations and flush */
	ulong lock_owner;
};
version(unittest) {
extern size_t c_get_fuse_file_info_size();
// Expectes the bitfield to be set this way:
// direct_io:1, keep_cache:0, flushe:1, nonseekable:0
extern int bit_field_check_fuse_file_info(fuse_file_info* test); 
}
unittest {
	assert(fuse_file_info.sizeof==c_get_fuse_file_info_size());
	fuse_file_info my_info;
	with(my_info) {
		direct_io=1;
		keep_cache=0;
		flush=1;
		unseekable=0;
	}
	assert(bit_field_check_fuse_file_info(&my_info));
}

package:

alias void* fuse_dirfil_t; // Not correct, but it is deprecated anyway.
alias void* fuse_dirh_t; // Not correct but deprecated anyway.
// Forward declarations:
extern struct struct_fuse; // Renamed to avoid name clashes.
// Main entry point:
extern int fuse_main_real(int argc, const(char)** argv, const fuse_operations *op,
	   size_t op_size, void *user_data);

extern fuse_context *fuse_get_context();

struct fuse_operations {
	int function (const char *, stat_t *) getattr;

	int function (const char *, ubyte *, size_t) readlink;

	/* Deprecated, use readdir() instead */
	int function (const char *, fuse_dirh_t, fuse_dirfil_t) getdir;

	int function (const char *, mode_t, dev_t) mknod;

	int function (const char *, mode_t) mkdir;


	int function (const char *) unlink;


	int function (const char *) rmdir;


	int function (const char *, const char *) symlink;


	int function (const char *, const char *) rename;


	int function (const char *, const char *) link;


	int function (const char *, mode_t) chmod;


	int function (const char *, uid_t, gid_t) chown;


	int function (const char *, off_t) truncate;

	int function (const char *, utimbuf *) utime;

	int function (const char *, fuse_file_info *) open;

	int function (const char *, ubyte *, size_t, off_t,
			fuse_file_info *) read;

	int function (const char *, const ubyte *, size_t, off_t,
			fuse_file_info *) write;

	int function (const char *, statvfs_t *) statfs;

	int function (const char *, fuse_file_info *) flush;

	int function (const char *, fuse_file_info *) release;

	int function (const char *, int, fuse_file_info *) fsync;


	int function (const char *, const char *, const ubyte *, size_t, int) setxattr;


	int function (const char *, const char *, ubyte *, size_t) getxattr;


	int function (const char *, char *, size_t) listxattr;


	int function (const char *, const char *) removexattr;

	int function (const char *, fuse_file_info *) opendir;

	int function (const char *, void *, fuse_fill_dir_t, off_t,	fuse_file_info *) readdir;

	int function (const char *, fuse_file_info *) releasedir;

	int function (const char *, int, fuse_file_info *) fsyncdir;

	void* function (fuse_conn_info *conn) init;

	void function (void* data) destroy;

	int function (const char *, int) access;

	int function (const char *, mode_t, fuse_file_info *) create;

	int function (const char *, off_t, fuse_file_info *) ftruncate;

	int function (const char *, stat_t *, fuse_file_info *) fgetattr;

	int function (const char *, fuse_file_info *, int cmd,
			flock *) lock;

	int function (const char *, const timespec *tv) utimens;

	int function (const char *, size_t blocksize, ulong *idx) bmap;

	mixin(bitfields!(
		bool, "flag_nullpath_ok", 1,
		uint, "flag_reserved", 31));

	int function (const char *, int cmd, void *arg,	fuse_file_info *, uint flags, void *data) ioctl;

	int function (const char *, fuse_file_info *, fuse_pollhandle *ph, uint *reventsp) poll;
}

/** Extra context that may be needed by some filesystems
 *
 * The uid, gid and pid fields are not filled in case of a writepage
 * operation.
 */
struct fuse_context {
	/** Pointer to the fuse object */
	struct_fuse *fuse;

	/** User ID of the calling process */
	uid_t uid;

	/** Group ID of the calling process */
	gid_t gid;

	/** Thread ID of the calling process */
	pid_t pid;

	/** Private filesystem data */
	void *private_data;

	/** Umask of the calling process (introduced in version 2.8) */
	mode_t umask;
};


/**
 * Connection information, passed to the ->init() method
 *
 * Some of the elements are read-write, these can be changed to
 * indicate the value requested by the filesystem.  The requested
 * value must usually be smaller than the indicated value.
 */
struct fuse_conn_info {
	/**
	 * Major version of the protocol (read-only)
	 */
	private uint proto_major_;
	@property uint proto_major() {
		return proto_major_;
	}

	/**
	 * Minor version of the protocol (read-only)
	 */
	private uint proto_minor_;
	@property uint proto_minor() {
		return proto_minor;
	}

	/**
	 * Is asynchronous read supported (read-write)
	 */
	uint async_read;

	/**
	 * Maximum size of the write buffer
	 */
	uint max_write;

	/**
	 * Maximum readahead
	 */
	uint max_readahead;

	/**
	 * Capability flags, that the kernel supports
	 */
	uint capable;

	/**
	 * Capability flags, that the filesystem wants to enable
	 */
	uint want;

	/**
	 * For future use.
	 */
	uint[25] reserved;
}

int deimos_d_fuse_getattr (const char * path, stat_t * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.getattr(cString2DString(path), info);
}

int deimos_d_fuse_readlink (const char * path, ubyte * buf, size_t size) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.readlink(cString2DString(path), cArray2DArray(buf, size));
}

int deimos_d_fuse_mknod (const char * path, mode_t mode, dev_t rdev) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.mknod(cString2DString(path), mode, rdev);
}

int deimos_d_fuse_mkdir (const char *path, mode_t mode) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.mkdir(cString2DString(path), mode);
}

int deimos_d_fuse_unlink (const char *path) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.unlink(cString2DString(path));
}

int deimos_d_fuse_rmdir (const char *path) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.rmdir(cString2DString(path));
}

int deimos_d_fuse_symlink (const char *from, const char *to) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.symlink(cString2DString(from), cString2DString(to));
}

int deimos_d_fuse_rename (const char *from, const char *to) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.rename(cString2DString(from), cString2DString(to));
}


int deimos_d_fuse_link (const char *from, const char *to) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.link(cString2DString(from), cString2DString(to));
}


int deimos_d_fuse_chmod (const char *path, mode_t mode) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.chmod(cString2DString(path), mode);
}

int deimos_d_fuse_chown (const char * path, uid_t uid, gid_t gid) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.chown(cString2DString(path), uid, gid);
}

int deimos_d_fuse_truncate (const char * path, off_t length) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.truncate(cString2DString(path), length);
}

//int deimos_d_fuse_utime (const char * path, utimbuf *time) {
//	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
//	return ops.utime(cString2DString(path), time);
//}

int deimos_d_fuse_open (const char * path, fuse_file_info * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.open(cString2DString(path), info);
}

int deimos_d_fuse_read (const char * path, ubyte * data , size_t data_length, 
		off_t offset, fuse_file_info * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.read(cString2DString(path), cArray2DArray!ubyte(data, data_length), offset, info);
}

int deimos_d_fuse_write (const char *path, const ubyte *data, size_t length, off_t offset, fuse_file_info *info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.write(cString2DString(path), cArray2DArray(data, length), offset, info);
}

int deimos_d_fuse_statfs (const char * path, statvfs_t *stbuf) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.statfs(cString2DString(path), stbuf);
}

int deimos_d_fuse_flush (const char * path, fuse_file_info *info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.flush(cString2DString(path), info);
}

int deimos_d_fuse_release (const char * path, fuse_file_info *info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.release(cString2DString(path), info);
}

int deimos_d_fuse_fsync (const char * path, int onlydatasync, fuse_file_info *info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.fsync(cString2DString(path), onlydatasync!=0, info);
}


int deimos_d_fuse_setxattr (const char *path, const char *name, const ubyte *data, size_t length , int flags) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.setxattr(cString2DString(path), cString2DString(name), cArray2DArray(data, length), flags);
}


int deimos_d_fuse_getxattr (const char *path, const char *name, ubyte *data, size_t length) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.getxattr(cString2DString(path), cString2DString(name), cArray2DArray(data, length));
}


int deimos_d_fuse_listxattr (const char *path, char *attributes, size_t length) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.listxattr(cString2DString(path), cArray2DArray(attributes, length));
}


int deimos_d_fuse_removexattr (const char *path, const char *name) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.removexattr(cString2DString(path), cString2DString(name));
}

int deimos_d_fuse_opendir (const char * path, fuse_file_info * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.opendir(cString2DString(path), info);
}

int deimos_d_fuse_readdir (const char * path, void * data , fuse_fill_dir_t filler, off_t offset,
fuse_file_info * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.readdir(cString2DString(path), data, filler, offset, info);
}

int deimos_d_fuse_releasedir (const char * path, fuse_file_info * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.releasedir(cString2DString(path), info);
}

int deimos_d_fuse_fsyncdir (const char * path , int flush_only_user_data, fuse_file_info *info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.fsyncdir(cString2DString(path), flush_only_user_data!=0, info);
}
// Not needed and even harms, because if not implemented the private_data pointer will be overridden wit 0.
//void* deimos_d_fuse_init (fuse_conn_info *conn) {
//	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
//	return ops.init(conn);
//}

void deimos_d_fuse_destroy (void * data) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.destroy(data);
}

int deimos_d_fuse_access (const char * path, int mask) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.access(cString2DString(path), mask);
}

int deimos_d_fuse_create (const char *path, mode_t mode, fuse_file_info * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.create(cString2DString(path), mode, info);
}

int deimos_d_fuse_ftruncate (const char *path, off_t length, fuse_file_info * info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.ftruncate(cString2DString(path), length, info);
}

int deimos_d_fuse_fgetattr (const char *path, stat_t *stbuf, fuse_file_info *info) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.fgetattr(cString2DString(path), stbuf, info);
}

int deimos_d_fuse_lock (const char *path, fuse_file_info *info, int cmd,
flock * locks) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.lock(cString2DString(path), info, cmd, locks);
}

int deimos_d_fuse_utimens (const char *path, const timespec* ts) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.utimens(cString2DString(path), cArray2DArray(ts, 2));
}

int deimos_d_fuse_bmap (const char * path, size_t blocksize, ulong *idx) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.bmap(cString2DString(path), blocksize, idx);
}


int deimos_d_fuse_ioctl (const char * path, int cmd, void *arg,
fuse_file_info * info, uint flags, void *data) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.ioctl(cString2DString(path), cmd, arg, info, flags, data);
}

int deimos_d_fuse_poll (const char * path, fuse_file_info * info,
fuse_pollhandle *ph, uint *reventsp) {
	auto ops=cast(FuseOperationsInterface)fuse_get_context().private_data;
	return ops.poll(cString2DString(path), info, ph, reventsp);
}
