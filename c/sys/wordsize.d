module c.sys.wordsize;
version(X86) {
	version = wordsize32;
}

version(X86_64) {
	version = wordsize64;
}

version(ARM) {
	version = wordsize32;
}

version(PPC) {
	version = wordsize32;
}

version(PPC64) {
	version = wordsize64;
}

version(IA64) {
	version = wordsize64;
}

version(MIPS) {
	version = wordsize32;
}

version(MIPS6) {
	version = wordsize64;
}

version(SPARC) {
	version = wordsize32;
}

version(SPARC64) {
	version = wordsize64;
}

version(S390) {
	version = wordsize32;
}

version(S390X) {
	version = wordsize64;
}

version(HPPA) {
	version = wordsize32;
}

version(HPPA6) {
	version = wordsize64;
}

version(SH) {
	version = wordsize32;
}

version(SH64) {
	version = wordsize64;
}

version(Alpha) {
	version = wordsize64;
}

