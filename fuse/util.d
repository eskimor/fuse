#!/usr/bin/rdmd -unittest 
import std.stdio;
import std.traits;
import std.c.string;


string createImplementation(ClassType, string classname)(){
	string results="import std.stdio;\nimport fuse.errno;\nclass "~ classname~" : "~ClassType.stringof~" {\n";
	foreach(member ; __traits(allMembers, ClassType)) {
		foreach(method; __traits(getVirtualMethods, ClassType, member))	 {
			enum name=__traits(identifier, method);
			alias ReturnType!method return_type;
			results~="\toverride "~return_type.stringof~" "~name~ParameterTypeTuple!method.stringof~
`{
		writefln("Not implemented method called: %s", "`~name~`");
`;
			static if(is (return_type == int) )
				results~="\t\treturn -ENOSYS;\n\t}\n";
			else
				results~="\t}\n";
			//writefln("Found method: %s", __traits(identifier, method));
		}	
	}
	results~="}";
	return results;
}
unittest {
	interface MyInterface {
		int test(ref string arg);
		int test(out int a);
		void test1(in const(char)* c);
	}
	enum buf=createImplementation!(MyInterface, "MyImplementation")();	
	writefln("%s", buf);
	mixin(createImplementation!(MyInterface, "MyImplementation")());
	auto impl=new MyImplementation(); // Must be instantiable!
}
/**
 * Generate a string usable for a mixin, which initializes function pointers in a struct.
 * The mixin will create an instance of type StructType named struct_name and initializes all function
 * pointers in the instance with functions named like the function pointers with the string prefix prepended
 * If no global function with the given name is found, than the function pointer will be null.
 * @param StructType The struct type you want to have an initialized instance from.
 * @param struct_name The name of the initialized instance.
 * @param prefix The prefix the global have functions.
*/
string initializeFuncPtrStruct(StructType, string struct_name, string prefix)() {
	string result=StructType.stringof~" "~struct_name~";\n";
	foreach(member; __traits(allMembers, StructType)) {
		//writefln("Is function pointer: %s", isSomeFunction!(mixin(prefix~member)));
		//static if(isFunctionPointer!(__traits(getMember, StructType, member)) ) {
		//writefln("Juhu!");
		//}
		//static if(is(member==function) && is(typeof(mixin("&"~prefix~member))==function)) {
		result~="static if(__traits(compiles, &"~prefix~member~")) {\n";
		result~="\t"~struct_name~"."~member~"=&"~prefix~member~";\n}\n";
		//}
	}
	return result;
}
version(unittest) {
struct Test {
	void function() test;
	void function() test1;
}
void my_test() {}
}
unittest {
	writefln(initializeFuncPtrStruct!(Test, "my_struct", "my_")());
	mixin(initializeFuncPtrStruct!(Test, "my_struct", "my_")());
	assert(my_struct.test==&my_test);
	assert(my_struct.test1==null);
	
}


union d_array(T) {
	struct {
		size_t length;
		T* ptr;
	}
	T[] arr;
}
const(char)[] cString2DString(const char* c_str) {
	d_array!(const char) buf;
	buf.ptr=c_str;
	buf.length=strlen(c_str);
	return buf.arr;
}

T[] cArray2DArray(T)(T* c_arr, size_t length) {
	d_arary!(T) buf;
	buf.ptr=c_arr;
	buf.length=length;
	return buf.arr;
}
unittest {
	int[] arr=new int[](8);
	d_array!int myarr;
	myarr.length=8;
	myarr.ptr=arr.ptr;
	assert((myarr.arr is arr) && myarr.arr.length==8);  // Check that length is really the length and not the size in bytes.
}

void main() {
}
