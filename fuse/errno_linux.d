/* Converted to D from errno.h by htod */
/* Following commands have been used: 
cp /usr/include/asm-generic/errno.h ./
wine htod.exe errno.h -I/usr/include -hs
*/
module fuse.errno_linux;
//C     #ifndef _ASM_GENERIC_ERRNO_H
//C     #define _ASM_GENERIC_ERRNO_H

//C     #include <asm-generic/errno-base.h>
//C     #ifndef _ASM_GENERIC_ERRNO_BASE_H
//C     #define _ASM_GENERIC_ERRNO_BASE_H

//C     #define	EPERM		 1	/* Operation not permitted */
//C     #define	ENOENT		 2	/* No such file or directory */
const EPERM = 1;
//C     #define	ESRCH		 3	/* No such process */
const ENOENT = 2;
//C     #define	EINTR		 4	/* Interrupted system call */
const ESRCH = 3;
//C     #define	EIO		 5	/* I/O error */
const EINTR = 4;
//C     #define	ENXIO		 6	/* No such device or address */
const EIO = 5;
//C     #define	E2BIG		 7	/* Argument list too long */
const ENXIO = 6;
//C     #define	ENOEXEC		 8	/* Exec format error */
const E2BIG = 7;
//C     #define	EBADF		 9	/* Bad file number */
const ENOEXEC = 8;
//C     #define	ECHILD		10	/* No child processes */
const EBADF = 9;
//C     #define	EAGAIN		11	/* Try again */
const ECHILD = 10;
//C     #define	ENOMEM		12	/* Out of memory */
const EAGAIN = 11;
//C     #define	EACCES		13	/* Permission denied */
const ENOMEM = 12;
//C     #define	EFAULT		14	/* Bad address */
const EACCES = 13;
//C     #define	ENOTBLK		15	/* Block device required */
const EFAULT = 14;
//C     #define	EBUSY		16	/* Device or resource busy */
const ENOTBLK = 15;
//C     #define	EEXIST		17	/* File exists */
const EBUSY = 16;
//C     #define	EXDEV		18	/* Cross-device link */
const EEXIST = 17;
//C     #define	ENODEV		19	/* No such device */
const EXDEV = 18;
//C     #define	ENOTDIR		20	/* Not a directory */
const ENODEV = 19;
//C     #define	EISDIR		21	/* Is a directory */
const ENOTDIR = 20;
//C     #define	EINVAL		22	/* Invalid argument */
const EISDIR = 21;
//C     #define	ENFILE		23	/* File table overflow */
const EINVAL = 22;
//C     #define	EMFILE		24	/* Too many open files */
const ENFILE = 23;
//C     #define	ENOTTY		25	/* Not a typewriter */
const EMFILE = 24;
//C     #define	ETXTBSY		26	/* Text file busy */
const ENOTTY = 25;
//C     #define	EFBIG		27	/* File too large */
const ETXTBSY = 26;
//C     #define	ENOSPC		28	/* No space left on device */
const EFBIG = 27;
//C     #define	ESPIPE		29	/* Illegal seek */
const ENOSPC = 28;
//C     #define	EROFS		30	/* Read-only file system */
const ESPIPE = 29;
//C     #define	EMLINK		31	/* Too many links */
const EROFS = 30;
//C     #define	EPIPE		32	/* Broken pipe */
const EMLINK = 31;
//C     #define	EDOM		33	/* Math argument out of domain of func */
const EPIPE = 32;
//C     #define	ERANGE		34	/* Math result not representable */
const EDOM = 33;

const ERANGE = 34;
//C     #endif

//C     #define	EDEADLK		35	/* Resource deadlock would occur */
//C     #define	ENAMETOOLONG	36	/* File name too long */
const EDEADLK = 35;
//C     #define	ENOLCK		37	/* No record locks available */
const ENAMETOOLONG = 36;
//C     #define	ENOSYS		38	/* Function not implemented */
const ENOLCK = 37;
//C     #define	ENOTEMPTY	39	/* Directory not empty */
const ENOSYS = 38;
//C     #define	ELOOP		40	/* Too many symbolic links encountered */
const ENOTEMPTY = 39;
//C     #define	EWOULDBLOCK	EAGAIN	/* Operation would block */
const ELOOP = 40;
//C     #define	ENOMSG		42	/* No message of desired type */
alias EAGAIN EWOULDBLOCK;
//C     #define	EIDRM		43	/* Identifier removed */
const ENOMSG = 42;
//C     #define	ECHRNG		44	/* Channel number out of range */
const EIDRM = 43;
//C     #define	EL2NSYNC	45	/* Level 2 not synchronized */
const ECHRNG = 44;
//C     #define	EL3HLT		46	/* Level 3 halted */
const EL2NSYNC = 45;
//C     #define	EL3RST		47	/* Level 3 reset */
const EL3HLT = 46;
//C     #define	ELNRNG		48	/* Link number out of range */
const EL3RST = 47;
//C     #define	EUNATCH		49	/* Protocol driver not attached */
const ELNRNG = 48;
//C     #define	ENOCSI		50	/* No CSI structure available */
const EUNATCH = 49;
//C     #define	EL2HLT		51	/* Level 2 halted */
const ENOCSI = 50;
//C     #define	EBADE		52	/* Invalid exchange */
const EL2HLT = 51;
//C     #define	EBADR		53	/* Invalid request descriptor */
const EBADE = 52;
//C     #define	EXFULL		54	/* Exchange full */
const EBADR = 53;
//C     #define	ENOANO		55	/* No anode */
const EXFULL = 54;
//C     #define	EBADRQC		56	/* Invalid request code */
const ENOANO = 55;
//C     #define	EBADSLT		57	/* Invalid slot */
const EBADRQC = 56;

const EBADSLT = 57;
//C     #define	EDEADLOCK	EDEADLK

alias EDEADLK EDEADLOCK;
//C     #define	EBFONT		59	/* Bad font file format */
//C     #define	ENOSTR		60	/* Device not a stream */
const EBFONT = 59;
//C     #define	ENODATA		61	/* No data available */
const ENOSTR = 60;
//C     #define	ETIME		62	/* Timer expired */
const ENODATA = 61;
//C     #define	ENOSR		63	/* Out of streams resources */
const ETIME = 62;
//C     #define	ENONET		64	/* Machine is not on the network */
const ENOSR = 63;
//C     #define	ENOPKG		65	/* Package not installed */
const ENONET = 64;
//C     #define	EREMOTE		66	/* Object is remote */
const ENOPKG = 65;
//C     #define	ENOLINK		67	/* Link has been severed */
const EREMOTE = 66;
//C     #define	EADV		68	/* Advertise error */
const ENOLINK = 67;
//C     #define	ESRMNT		69	/* Srmount error */
const EADV = 68;
//C     #define	ECOMM		70	/* Communication error on send */
const ESRMNT = 69;
//C     #define	EPROTO		71	/* Protocol error */
const ECOMM = 70;
//C     #define	EMULTIHOP	72	/* Multihop attempted */
const EPROTO = 71;
//C     #define	EDOTDOT		73	/* RFS specific error */
const EMULTIHOP = 72;
//C     #define	EBADMSG		74	/* Not a data message */
const EDOTDOT = 73;
//C     #define	EOVERFLOW	75	/* Value too large for defined data type */
const EBADMSG = 74;
//C     #define	ENOTUNIQ	76	/* Name not unique on network */
const EOVERFLOW = 75;
//C     #define	EBADFD		77	/* File descriptor in bad state */
const ENOTUNIQ = 76;
//C     #define	EREMCHG		78	/* Remote address changed */
const EBADFD = 77;
//C     #define	ELIBACC		79	/* Can not access a needed shared library */
const EREMCHG = 78;
//C     #define	ELIBBAD		80	/* Accessing a corrupted shared library */
const ELIBACC = 79;
//C     #define	ELIBSCN		81	/* .lib section in a.out corrupted */
const ELIBBAD = 80;
//C     #define	ELIBMAX		82	/* Attempting to link in too many shared libraries */
const ELIBSCN = 81;
//C     #define	ELIBEXEC	83	/* Cannot exec a shared library directly */
const ELIBMAX = 82;
//C     #define	EILSEQ		84	/* Illegal byte sequence */
const ELIBEXEC = 83;
//C     #define	ERESTART	85	/* Interrupted system call should be restarted */
const EILSEQ = 84;
//C     #define	ESTRPIPE	86	/* Streams pipe error */
const ERESTART = 85;
//C     #define	EUSERS		87	/* Too many users */
const ESTRPIPE = 86;
//C     #define	ENOTSOCK	88	/* Socket operation on non-socket */
const EUSERS = 87;
//C     #define	EDESTADDRREQ	89	/* Destination address required */
const ENOTSOCK = 88;
//C     #define	EMSGSIZE	90	/* Message too long */
const EDESTADDRREQ = 89;
//C     #define	EPROTOTYPE	91	/* Protocol wrong type for socket */
const EMSGSIZE = 90;
//C     #define	ENOPROTOOPT	92	/* Protocol not available */
const EPROTOTYPE = 91;
//C     #define	EPROTONOSUPPORT	93	/* Protocol not supported */
const ENOPROTOOPT = 92;
//C     #define	ESOCKTNOSUPPORT	94	/* Socket type not supported */
const EPROTONOSUPPORT = 93;
//C     #define	EOPNOTSUPP	95	/* Operation not supported on transport endpoint */
const ESOCKTNOSUPPORT = 94;
//C     #define	EPFNOSUPPORT	96	/* Protocol family not supported */
const EOPNOTSUPP = 95;
//C     #define	EAFNOSUPPORT	97	/* Address family not supported by protocol */
const EPFNOSUPPORT = 96;
//C     #define	EADDRINUSE	98	/* Address already in use */
const EAFNOSUPPORT = 97;
//C     #define	EADDRNOTAVAIL	99	/* Cannot assign requested address */
const EADDRINUSE = 98;
//C     #define	ENETDOWN	100	/* Network is down */
const EADDRNOTAVAIL = 99;
//C     #define	ENETUNREACH	101	/* Network is unreachable */
const ENETDOWN = 100;
//C     #define	ENETRESET	102	/* Network dropped connection because of reset */
const ENETUNREACH = 101;
//C     #define	ECONNABORTED	103	/* Software caused connection abort */
const ENETRESET = 102;
//C     #define	ECONNRESET	104	/* Connection reset by peer */
const ECONNABORTED = 103;
//C     #define	ENOBUFS		105	/* No buffer space available */
const ECONNRESET = 104;
//C     #define	EISCONN		106	/* Transport endpoint is already connected */
const ENOBUFS = 105;
//C     #define	ENOTCONN	107	/* Transport endpoint is not connected */
const EISCONN = 106;
//C     #define	ESHUTDOWN	108	/* Cannot send after transport endpoint shutdown */
const ENOTCONN = 107;
//C     #define	ETOOMANYREFS	109	/* Too many references: cannot splice */
const ESHUTDOWN = 108;
//C     #define	ETIMEDOUT	110	/* Connection timed out */
const ETOOMANYREFS = 109;
//C     #define	ECONNREFUSED	111	/* Connection refused */
const ETIMEDOUT = 110;
//C     #define	EHOSTDOWN	112	/* Host is down */
const ECONNREFUSED = 111;
//C     #define	EHOSTUNREACH	113	/* No route to host */
const EHOSTDOWN = 112;
//C     #define	EALREADY	114	/* Operation already in progress */
const EHOSTUNREACH = 113;
//C     #define	EINPROGRESS	115	/* Operation now in progress */
const EALREADY = 114;
//C     #define	ESTALE		116	/* Stale NFS file handle */
const EINPROGRESS = 115;
//C     #define	EUCLEAN		117	/* Structure needs cleaning */
const ESTALE = 116;
//C     #define	ENOTNAM		118	/* Not a XENIX named type file */
const EUCLEAN = 117;
//C     #define	ENAVAIL		119	/* No XENIX semaphores available */
const ENOTNAM = 118;
//C     #define	EISNAM		120	/* Is a named type file */
const ENAVAIL = 119;
//C     #define	EREMOTEIO	121	/* Remote I/O error */
const EISNAM = 120;
//C     #define	EDQUOT		122	/* Quota exceeded */
const EREMOTEIO = 121;

const EDQUOT = 122;
//C     #define	ENOMEDIUM	123	/* No medium found */
//C     #define	EMEDIUMTYPE	124	/* Wrong medium type */
const ENOMEDIUM = 123;
//C     #define	ECANCELED	125	/* Operation Canceled */
const EMEDIUMTYPE = 124;
//C     #define	ENOKEY		126	/* Required key not available */
const ECANCELED = 125;
//C     #define	EKEYEXPIRED	127	/* Key has expired */
const ENOKEY = 126;
//C     #define	EKEYREVOKED	128	/* Key has been revoked */
const EKEYEXPIRED = 127;
//C     #define	EKEYREJECTED	129	/* Key was rejected by service */
const EKEYREVOKED = 128;

const EKEYREJECTED = 129;
/* for robust mutexes */
//C     #define	EOWNERDEAD	130	/* Owner died */
//C     #define	ENOTRECOVERABLE	131	/* State not recoverable */
const EOWNERDEAD = 130;

const ENOTRECOVERABLE = 131;
//C     #define ERFKILL		132	/* Operation not possible due to RF-kill */

const ERFKILL = 132;
//C     #define EHWPOISON	133	/* Memory page has hardware error */

const EHWPOISON = 133;
//C     #endif
