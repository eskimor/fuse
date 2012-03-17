module c.sys.stat;
public import c.sys.c_defs;
public import core.stdc.config;
public import c.sys.stat_defs;
public import core.sys.posix.time;
extern (C)  {
struct stat_t
{
	__dev_t st_dev;		/* Device.  */
	static if(__WORDSIZE == 32) {
		ushort __pad1;
	}

	static if (__WORDSIZE == 64 || ! __USE_FILE_OFFSET64) { 
		__ino_t st_ino;		/* File serial number.	*/
	}
	else {
		__ino_t __st_ino;			/* 32bit file serial number.	*/
	}
	static if (__WORDSIZE == 32 ) {
		__mode_t st_mode;			/* File mode.  */
		__nlink_t st_nlink;			/* Link count.  */
	}
	else {
		__nlink_t st_nlink;		/* Link count.  */
		__mode_t st_mode;		/* File mode.  */
	}
	__uid_t st_uid;		/* User ID of the file's owner.	*/
	__gid_t st_gid;		/* Group ID of the file's group.*/
	static if (__WORDSIZE == 64) {
		int __pad0;
	}
	__dev_t st_rdev;		/* Device number, if device.  */
	static if(__WORDSIZE==32) {
		ushort __pad2;
	}
	static if (__WORDSIZE == 64 || ! __USE_FILE_OFFSET64) { 
		__off_t st_size;			/* Size of file, in bytes.  */
	}
	else {
		__off64_t st_size;			/* Size of file, in bytes.  */
	}
	__blksize_t st_blksize;	/* Optimal block size for I/O.  */
	static if (__WORDSIZE == 64 || ! __USE_FILE_OFFSET64) { 
		__blkcnt_t st_blocks;		/* Number 512-byte blocks allocated. */
	}
	else {
		__blkcnt64_t st_blocks;		/* Number 512-byte blocks allocated. */
	}
	version(__USE_MISC) {
		version=DO_TIMESPEC_STUFF;
	}
	version(__USE_XOPEN2K8) {
		version=DO_TIMESPEC_STUFF;
	}
	version(DO_TIMESPEC_STUFF) {
		/* Nanosecond resolution timestamps are stored in a format
		   equivalent to 'struct timespec'.  This is the type used
		   whenever possible but the Unix namespace rules do not allow the
		   identifier 'timespec' to appear in the <sys/stat.h> header.
		   Therefore we have to handle the use of this header in strictly
		   standard-compliant sources special.  */
		timespec st_atim;		/* Time of last access.  */
		timespec st_mtim;		/* Time of last modification.  */
		timespec st_ctim;		/* Time of last status change.  */
		alias st_atim.tv_sec st_atime; //Backward compatibility.
		alias st_mtim.tv_sec st_mtime;
		alias st_ctim.tv_sec st_ctime;
	}
	else {
		__time_t st_atime;			/* Time of last access.  */
		c_ulong st_atimensec;	/* Nscecs of last access.  */
		__time_t st_mtime;			/* Time of last modification.  */
		c_ulong st_mtimensec;	/* Nsecs of last modification.  */
		__time_t st_ctime;			/* Time of last status change.  */
		c_ulong st_ctimensec;	/* Nsecs of last status change.  */
	}

	static if( __WORDSIZE == 64) {
		c_long __unused[3];
	}
	else static if(__USE_FILE_OFFSET64) {
		c_ulong __unused4;
		c_ulong __unused5;
	}
	else {
		__ino64_t st_ino;			/* File serial number.	*/
	}
}
extern size_t c_get_stat_size();
}
unittest {
	assert(c_get_stat_size()==stat_t.sizeof);
}
