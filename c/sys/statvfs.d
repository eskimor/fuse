module c.sys.statvfs;
import core.stdc.config;
import c.sys.c_defs;

extern (C) {
	static if(__WORDSIZE == 32) {
		version=_STATVFSBUF_F_UNUSED;
	}


	struct struct_statvfs
	{
		c_ulong f_bsize;
		c_ulong f_frsize;
		version( __USE_FILE_OFFSET64) {
			__fsblkcnt_t f_blocks;
			__fsblkcnt_t f_bfree;
			__fsblkcnt_t f_bavail;
			__fsfilcnt_t f_files;
			__fsfilcnt_t f_ffree;
			__fsfilcnt_t f_favail;
		}
		else {
			__fsblkcnt64_t f_blocks;
			__fsblkcnt64_t f_bfree;
			__fsblkcnt64_t f_bavail;
			__fsfilcnt64_t f_files;
			__fsfilcnt64_t f_ffree;
			__fsfilcnt64_t f_favail;
		}
		c_ulong f_fsid;
		version(_STATVFSBUF_F_UNUSED) {
			int __f_unused;
		}
		c_ulong f_flag;
		c_ulong f_namemax;
		int __f_spare[6];
	}
	extern size_t c_get_statvfs_size();
}
unittest {
	assert(struct_statvfs.sizeof==c_get_statvfs_size());
}
