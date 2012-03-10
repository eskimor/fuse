module fuse.fuse_impl;
import fuse.fuse;

package:
FuseOperationsInterface current_fuse_interface;
extern (C) {
	struct fuse_operations {
		int function (const char *, struct stat *) getattr;

		int function (const char *, char *, size_t) readlink;

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

		int function (const char *, struct utimbuf *) utime;

		int function (const char *, struct fuse_file_info *) open;

		int function (const char *, char *, size_t, off_t,
				struct fuse_file_info *) read;

		int function (const char *, const char *, size_t, off_t,
				struct fuse_file_info *) write;

		int function (const char *, struct statvfs *) statfs;

		int function (const char *, struct fuse_file_info *) flush;

		int function (const char *, struct fuse_file_info *) release;

		int function (const char *, int, struct fuse_file_info *) fsync;


		int function (const char *, const char *, const char *, size_t, int) setxattr;


		int function (const char *, const char *, char *, size_t) getxattr;


		int function (const char *, char *, size_t) listxattr;


		int function (const char *, const char *) removexattr;

		int function (const char *, struct fuse_file_info *) opendir;

		int function (const char *, void *, fuse_fill_dir_t, off_t,
				struct fuse_file_info *) readdir;

		int function (const char *, struct fuse_file_info *) releasedir;

		int function (const char *, int, struct fuse_file_info *) fsyncdir;

		void *function (struct fuse_conn_info *conn) init;

		void function (void *) destroy;

		int function (const char *, int) access;

		int function (const char *, mode_t, struct fuse_file_info *) create;

		int function (const char *, off_t, struct fuse_file_info *) ftruncate;

		int function (const char *, struct stat *, struct fuse_file_info *) fgetattr;

		int function (const char *, struct fuse_file_info *, int cmd,
				struct flock *) lock;

		int function (const char *, const struct timespec tv[2]) utimens;

		int function (const char *, size_t blocksize, uint64_t *idx) bmap;

		uint flags;

		int function (const char *, int cmd, void *arg,
				struct fuse_file_info *, unsigned int flags, void *data) ioctl;

		int function (const char *, struct fuse_file_info *,
				struct fuse_pollhandle *ph, unsigned *reventsp) poll;
	};

	/** Extra context that may be needed by some filesystems
	 *
	 * The uid, gid and pid fields are not filled in case of a writepage
	 * operation.
	 */
	struct fuse_context {
		/** Pointer to the fuse object */
		struct fuse *fuse;

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

	// Main entry point:
	int fuse_main_real(int argc, const(char*)* argv, const struct fuse_operations *op,
		   size_t op_size, void *user_data);

	int deimos_d_fuse_getattr (const char *, struct stat *);

	int deimos_d_fuse_readlink (const char *, char *, size_t);

	int deimos_d_fuse_mknod (const char *, mode_t, dev_t);

	int deimos_d_fuse_mkdir (const char *, mode_t);


	int deimos_d_fuse_unlink (const char *);


	int deimos_d_fuse_rmdir (const char *);


	int deimos_d_fuse_symlink (const char *, const char *);


	int deimos_d_fuse_rename (const char *, const char *);


	int deimos_d_fuse_link (const char *, const char *);


	int deimos_d_fuse_chmod (const char *, mode_t);


	int deimos_d_fuse_chown (const char *, uid_t, gid_t);


	int deimos_d_fuse_truncate (const char *, off_t);

	int deimos_d_fuse_utime (const char *, struct utimbuf *);

	int deimos_d_fuse_open (const char *, struct fuse_file_info *);

	int deimos_d_fuse_read (const char *, char *, size_t, off_t,
			struct fuse_file_info *);

	int deimos_d_fuse_write (const char *, const char *, size_t, off_t,
			struct fuse_file_info *);

	int deimos_d_fuse_statfs (const char *, struct statvfs *);

	int deimos_d_fuse_flush (const char *, struct fuse_file_info *);

	int deimos_d_fuse_release (const char *, struct fuse_file_info *);

	int deimos_d_fuse_fsync (const char *, int, struct fuse_file_info *);


	int deimos_d_fuse_setxattr (const char *, const char *, const char *, size_t, int);


	int deimos_d_fuse_getxattr (const char *, const char *, char *, size_t);


	int deimos_d_fuse_listxattr (const char *, char *, size_t);


	int deimos_d_fuse_removexattr (const char *, const char *);

	int deimos_d_fuse_opendir (const char *, struct fuse_file_info *);

	int deimos_d_fuse_readdir (const char *, void *, fuse_fill_dir_t, off_t,
			struct fuse_file_info *);

	int deimos_d_fuse_releasedir (const char *, struct fuse_file_info *);

	int deimos_d_fuse_fsyncdir (const char *, int, struct fuse_file_info *);

	void* deimos_d_fuse_init (struct fuse_conn_info *conn) {

	}

	void deimos_d_fuse_destroy (void *);

	int deimos_d_fuse_access (const char *, int);

	int deimos_d_fuse_create (const char *, mode_t, struct fuse_file_info *);

	int deimos_d_fuse_ftruncate (const char *, off_t, struct fuse_file_info *);

	int deimos_d_fuse_fgetattr (const char *, struct stat *, struct fuse_file_info *);

	int deimos_d_fuse_lock (const char *, struct fuse_file_info *, int cmd,
			struct flock *);

	int deimos_d_fuse_utimens (const char *, const struct timespec tv[2]);

	int deimos_d_fuse_bmap (const char *, size_t blocksize, uint64_t *idx);
	unsigned int flags;

	int deimos_d_fuse_ioctl (const char *, int cmd, void *arg,
			struct fuse_file_info *, unsigned int flags, void *data);

	int deimos_d_fuse_poll (const char *, struct fuse_file_info *,
			struct fuse_pollhandle *ph, unsigned *reventsp);
}
