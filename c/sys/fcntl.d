module c.sys.fcntl;
import c.sys.c_defs;
extern (C) {

struct flock
  {
    short l_type;   /* Type of lock: F_RDLCK, F_WRLCK, or F_UNLCK.  */
    short l_whence; /* Where `l_start' is relative to (like `lseek').  */

	version(__USE_FILE_OFFSET64) {
    __off_t l_start;    /* Offset where the lock begins.  */
    __off_t l_len;      /* Size of the locked area; zero means until EOF.  */
	}
	else {
    __off64_t l_start;  /* Offset where the lock begins.  */
    __off64_t l_len;    /* Size of the locked area; zero means until EOF.  */
	}

    __pid_t l_pid;      /* Process holding the lock.  */
  }
}