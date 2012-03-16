module c.errno;
version(linux) {
	public import c.errno_linux;
}
else {
	pragma(msg, "Unsupported platform");
	static assert(0);
}
