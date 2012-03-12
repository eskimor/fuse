import fuse.util;
import fuse.fuse_impl;
import std.bitmanip;
import core.stdc.config;
public import fuse.c_defs;

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
	int getattr (const(char)[] path, stat* stbuf);

	/** Read the target of a symbolic link
	 *
	 * The buffer should be filled with a null terminated string.  The
	 * buffer size argument includes the space for the terminating
	 * null character.	If the linkname is too long to fit in the
	 * buffer, it should be truncated.	The return value should be 0
	 * for success.
	 */
	int readlink (const(char)[] path, char[] buf);

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
	int chown (const(char)[] path, uid_t, gid_t);

	/** Change the size of a file */
	int truncate (const(char)[] path, off_t);

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
	int open (const(char)[] path, fuse_file_info *);

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
	int read (const(char)[] path, char[] readbuf, off_t offset,
			fuse_file_info * info );

	/** Write data to an open file
	 *
	 * Write should return exactly the number of bytes requested
	 * except on error.	 An exception to this is when the 'direct_io'
	 * mount option is specified (see read operation).
	 *
	 * Changed in version 2.2
	 */
	int write (const(char)[] path, const(char)[] data, off_t=0;
			fuse_file_info *);

	/** Get file system statistics
	 *
	 * The 'f_frsize', 'f_favail', 'f_fsid' and 'f_flag' fields are ignored
	 *
	 * Replaced 'struct statfs' parameter with 'struct statvfs' in
	 * version 2.5
	 */
	int statfs (const(char)[] path, statvfs *);

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
	int flush (const(char)[] path, fuse_file_info *);

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
	int release (const(char)[] path, fuse_file_info *);

	/** Synchronize file contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data.
	 *
	 * Changed in version 2.2
	 */
	int fsync (const(char)[] path, int, fuse_file_info *);

	/** Set extended attributes */
	int setxattr (const(char)[] path, const(char)[] name, const(byte)[] data, int);

	/** Get extended attributes */
	int getxattr (const(char)[] path, const(char)[] name, byte[] data);

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
	int opendir (const(char)[] path, fuse_file_info *);

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
	int readdir (const(char)[] path, void *, fuse_fill_dir_t, off_t,
			fuse_file_info *);

	/** Release directory
	 *
	 * Introduced in version 2.3
	 */
	int releasedir (const(char)[] path, fuse_file_info *);

	/** Synchronize directory contents
	 *
	 * If the datasync parameter is non-zero, then only the user data
	 * should be flushed, not the meta data
	 *
	 * Introduced in version 2.3
	 */
	int fsyncdir (const(char)[] path, int, fuse_file_info *);

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
	void *init (fuse_conn_info *conn);

	/**
	 * Clean up filesystem
	 *
	 * Called on filesystem exit.
	 *
	 * Introduced in version 2.3
	 */
	void destroy (void *);

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
	int access (const(char)[] path, int);

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
	int create (const(char)[] path, mode_t, fuse_file_info *);

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
	int ftruncate (const(char)[] path, off_t, fuse_file_info *);

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
	int fgetattr (const(char)[] path, stat *, fuse_file_info *);

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
	int lock (const(char)[] path, fuse_file_info *, int cmd=0;
			flock *);

	/**
	 * Change the access and modification times of a file with
	 * nanosecond resolution
	 *
	 * Introduced in version 2.6
	 */
	int utimens (const(char)[] path, const timespec tv[2]);

	/**
	 * Map block index within file to block index within device
	 *
	 * Note: This makes sense only for block device backed filesystems
	 * mounted with the 'blkdev' option
	 *
	 * Introduced in version 2.6
	 */
	int bmap (const(char)[] path, size_t blocksize, uint64_t *idx);

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
	int ioctl (const(char)[] path, int cmd, void *arg,
			fuse_file_info *, unsigned int flags, void *data);

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
	int poll (const(char)[] path, fuse_file_info *,	fuse_pollhandle *ph, unsigned *reventsp);
};

/**
 * Derive from FuseOperations, if you want to have predefined methods, which simply spit out a not implemented error.
*/ 
mixin(createImplementation!(FuseOperationsInterface, "FuseOperations")());


int fuse_main(const(char[])[] args, FuseOperationsInterface operations) {
	current_fuse_interface=operations;
	const(char*)[] c_args=new const(char*)[](args.length);
	foreach(i, arg; args) 
		c_args[i]=arg.ptr;
	mixin(initializeFuncPtrStruct!(fuse_operations, "my_operations", "my_")());
	fuse_main_real(c_args.length, c_args.ptr, &my_operations, my_operations.sizeof, cast(void*) operations);
}
extern(C) {
	//alias fuse_fill_dir_t int function (fuse_dirh_t h, const char *name, int type, ino_t ino); // Don't know where I have got this definition from, but it is wrong.
	alias int function (void* buf, const char* name, const stat* stbuf, off_t offset) fuse_fill_dir_t;
	extern struct fuse_dirhandle;
	alias fuse_dirhandle* fuse_dirh_t;
	struct stat
	{
		__dev_t st_dev;		/* Device.  */
#if __WORDSIZE == 32
		unsigned short int __pad1;
#endif
#if __WORDSIZE == 64 || !defined __USE_FILE_OFFSET64
		__ino_t st_ino;		/* File serial number.	*/
#else
		__ino_t __st_ino;			/* 32bit file serial number.	*/
#endif
#if __WORDSIZE == 32
		__mode_t st_mode;			/* File mode.  */
		__nlink_t st_nlink;			/* Link count.  */
#else
		__nlink_t st_nlink;		/* Link count.  */
		__mode_t st_mode;		/* File mode.  */
#endif
		__uid_t st_uid;		/* User ID of the file's owner.	*/
		__gid_t st_gid;		/* Group ID of the file's group.*/
#if __WORDSIZE == 64
		int __pad0;
#endif
		__dev_t st_rdev;		/* Device number, if device.  */
#if __WORDSIZE == 32
		unsigned short int __pad2;
#endif
#if __WORDSIZE == 64 || !defined __USE_FILE_OFFSET64
		__off_t st_size;			/* Size of file, in bytes.  */
#else
		__off64_t st_size;			/* Size of file, in bytes.  */
#endif
		__blksize_t st_blksize;	/* Optimal block size for I/O.  */
#if __WORDSIZE == 64 || !defined __USE_FILE_OFFSET64
		__blkcnt_t st_blocks;		/* Number 512-byte blocks allocated. */
#else
		__blkcnt64_t st_blocks;		/* Number 512-byte blocks allocated. */
#endif
#if defined __USE_MISC || defined __USE_XOPEN2K8
		/* Nanosecond resolution timestamps are stored in a format
		   equivalent to 'struct timespec'.  This is the type used
		   whenever possible but the Unix namespace rules do not allow the
		   identifier 'timespec' to appear in the <sys/stat.h> header.
		   Therefore we have to handle the use of this header in strictly
		   standard-compliant sources special.  */
		struct timespec st_atim;		/* Time of last access.  */
		struct timespec st_mtim;		/* Time of last modification.  */
		struct timespec st_ctim;		/* Time of last status change.  */
# define st_atime st_atim.tv_sec	/* Backward compatibility.  */
# define st_mtime st_mtim.tv_sec
# define st_ctime st_ctim.tv_sec
#else
		__time_t st_atime;			/* Time of last access.  */
		unsigned long int st_atimensec;	/* Nscecs of last access.  */
		__time_t st_mtime;			/* Time of last modification.  */
		unsigned long int st_mtimensec;	/* Nsecs of last modification.  */
		__time_t st_ctime;			/* Time of last status change.  */
		unsigned long int st_ctimensec;	/* Nsecs of last status change.  */
#endif
#if __WORDSIZE == 64
		long int __unused[3];
#else
# ifndef __USE_FILE_OFFSET64
		unsigned long int __unused4;
		unsigned long int __unused5;
# else
		__ino64_t st_ino;			/* File serial number.	*/
# endif
#endif
	};
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
		uint lock_owner;
	};
	extern size_t c_get_fuse_file_info_size();
	// Expectes the bitfield to be set this way:
	// direct_io:1, keep_cache:0, flushe:1, nonseekable:0
	extern int bit_field_check_fuse_file_info(fuse_file_info* test); 
	unittest {
		assert(fuse_file_info.sizeof==c_get_fuse_file_info_size()));
		fuse_file_info my_info;
		with(my_info) {
			direct_io=1;
			keep_cache=0;
			flush=1;
			nonseekable=0;
		}
		assert(bit_field_check_fuse_file_info(&my_info));
	}
}

