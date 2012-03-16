#include <iostream>
#include <string>
#include <limits>
#include <fstream>
#include <sys/types.h>
#include <typeinfo>
#define FUSE_USE_VERSION 26
#include <fuse/fuse.h>
// This macro assumes a local const char* dtype; to be present.
#define createAliasDef(mytype)   switch(sizeof(mytype)) { case 1: dtype="byte";break;case 2: dtype="short";break; case 4:dtype="int";break; case 8: dtype="long";break; default: dtype="UNKNOWN TYPE";}  out<<"// C Type was: "<<typeid(mytype).name()<<std::endl; if(std::numeric_limits<mytype>::is_signed) out<<"alias "<<dtype<<" "#mytype";\n"; else out<<"alias "<<"u"<<dtype<<" "#mytype";\n";
int main(int argc, char** argv) {
	if(argc<2) {
		std::cerr<<"Usage: "<<argv[0]<<" [file for cating in at the beginning] doutfile.d"<<std::endl;
		return -1;
	}
	int outfile=argc>2 ? 2 : 1;
	std::ofstream out(argv[outfile]);
	out<<"/* Auto generated file by provideCsTypeDefs.cc, don't edit!*/"<<std::endl;
	if(argc>2) {
		std::ifstream in(argv[1]);
		int c;
		while(in) {
			c=in.get();
			if(c<0)
				break;
			out.put(char(c));
		}
	}
	const char* dtype;
	createAliasDef(off_t);
	createAliasDef(mode_t);
	createAliasDef(uid_t);
	createAliasDef(gid_t);
	createAliasDef(dev_t);
	createAliasDef(ino_t);
	createAliasDef(__ino_t);
	createAliasDef(__dev_t);
	createAliasDef(__mode_t);
	createAliasDef(__nlink_t);
	createAliasDef(__uid_t);
	createAliasDef(__gid_t);
	createAliasDef(__off64_t);
	createAliasDef(__off_t);
	createAliasDef(__blkcnt_t);
	createAliasDef(__fsfilcnt64_t);
	createAliasDef(__blksize_t);
	createAliasDef(__blkcnt64_t);
	createAliasDef(__time_t);
	createAliasDef(__fsblkcnt_t);
	createAliasDef(__fsblkcnt64_t);
	createAliasDef(time_t);
#ifdef __USE_FILE_OFFSET64
	out<<"version=__USE_FILE_OFFSET64;"<<std::endl;
	out<<"version(__USE_FILE_OFFSET64) {\nenum __USE_FILE_OFFSET64=true;\n}\nelse {\nenum __USE_FILE_OFFSET64=false;\n}"<<std::endl;
#endif
#ifdef __WORDSIZE
	out<<"enum __WORDSIZE="<<__WORDSIZE<<";"<<std::endl;
#endif
#ifdef __USE_MISC
	out<<"version=__USE_MISC;"<<std::endl;
#endif
#ifdef __USE_XOPEN2K8
	out<<"version=__USE_XOPEN2K8;"<<std::endl;
#endif
	return 0;
}
