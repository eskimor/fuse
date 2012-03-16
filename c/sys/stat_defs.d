/* Converted to D from stat_defs.h by htod */
module c.sys.stat_defs;
import std.conv;
/* Encoding of the file mode.  */

//C     #define __S_IFMT        octal!170000 /* These bits determine file type.  */

const __S_IFMT = octal!170000;
/* File types.  */
//C     #define __S_IFDIR       octal!40000 /* Directory.  */
//C     #define __S_IFCHR       octal!20000 /* Character device.  */
const __S_IFDIR = octal!40000;
//C     #define __S_IFBLK       octal!60000 /* Block device.  */
const __S_IFCHR = octal!20000;
//C     #define __S_IFREG       octal!100000 /* Regular file.  */
const __S_IFBLK = octal!60000;
//C     #define __S_IFIFO       octal!10000 /* FIFO.  */
const __S_IFREG = octal!100000;
//C     #define __S_IFLNK       octal!120000 /* Symbolic link.  */
const __S_IFIFO = octal!10000;
//C     #define __S_IFSOCK      octal!140000 /* Socket.  */
const __S_IFLNK = octal!120000;

const __S_IFSOCK = octal!140000;
/* POSIX.1b objects.  Note that these macros always evaluate to zero.  But
   they do it by enforcing the correct use of the macros.  */
//C     #define __S_TYPEISMQ(buf)  ((buf)->st_mode - (buf)->st_mode)
//C     #define __S_TYPEISSEM(buf) ((buf)->st_mode - (buf)->st_mode)
//C     #define __S_TYPEISSHM(buf) ((buf)->st_mode - (buf)->st_mode)

/* Protection bits.  */

//C     #define __S_ISUID       octal!4000   /* Set user ID on execution.  */
//C     #define __S_ISGID       octal!2000   /* Set group ID on execution.  */
const __S_ISUID = octal!4000;
//C     #define __S_ISVTX       octal!1000   /* Save swapped text after use (sticky).  */
const __S_ISGID = octal!2000;
//C     #define __S_IREAD       octal!400    /* Read by owner.  */
const __S_ISVTX = octal!1000;
//C     #define __S_IWRITE      octal!200    /* Write by owner.  */
const __S_IREAD = octal!400;
//C     #define __S_IEXEC       octal!100    /* Execute by owner.  */
const __S_IWRITE = octal!200;

const __S_IEXEC = octal!100;

