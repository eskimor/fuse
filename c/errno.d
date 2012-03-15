module c.errno;
version(linux) {
	public import fuse.errno_linux;
}
else {
	pragma(msg, "Unsupported platform");
	static assert(0);
}
