#!/usr/bin/rdmd -unittest 
module fuse.util;
import std.stdio;
import std.traits;
import std.c.string;
import std.conv;
import std.string;
import std.container;
private {
	string flagsToString(T)(int val) {
		string result;
		foreach(m; EnumMembers!T) {
			if(m==T.none)
				continue;
			if((val&m)!=0) {
				auto orig=to!string(m);
				auto buf=chomp(orig, "_");
				if(buf is orig)
					result~="@";
				result~=buf~" ";
			}
		}
		return result;
	}
}
string createImplementation(ClassType, string classname)(bool[string] methods_to_ignore=["":false]){
	string results;
	string begin="import std.stdio;\nimport core.stdc.errno;\nclass "~ classname~" : "~ClassType.stringof~" {\n";
	int alias_count=0;
	string alias_defs;
	foreach(member ; __traits(allMembers, ClassType)) {
		foreach(method; __traits(getVirtualMethods, ClassType, member))	 {
			enum name=__traits(identifier, method);
			if(name in methods_to_ignore) {
				continue;
			}
			alias ReturnType!method return_type;
			//results~="\toverride "~return_type.stringof~" "~name~ParameterTypeTuple!method.stringof~ // Not working for extern (C) function parameters.
			results~="\toverride "~return_type.stringof~" "~name~"(";
			
			foreach(i, p; ParameterTypeTuple!method) {
				results~=flagsToString!ParameterStorageClass(ParameterStorageClassTuple!method[i])~" ";
				if("extern".length<p.stringof.length && "extern"==p.stringof[0.."extern".length]) {
					alias_defs~="alias "~p.stringof~" work_around_"~to!string(alias_count)~";\n";
					results~="work_around_"~to!string(alias_count)~",";
					alias_count++;
				}
				else {
					results~=p.stringof~",";
				}
			}
			if(results[$-1]==',')
				results=results[0..$-1]~')';
			else
				results~=')';
			results~=" "~flagsToString!FunctionAttribute(functionAttributes!method);
			results~=`{
		writefln("Not implemented method called: %s", "`~name~`");
`;
			static if(is (return_type == int) )
				results~="\t\treturn -ENOSYS;\n\t}\n";
			else static if(is (return_type : void*) )
				results~="\t\treturn null;\n\t}\n";
			else static if(is (return_type : bool) ) 
				results~="\t\treturn false;\n\t}\n";
			else static if(is (return_type : void))
				results~="\t}\n";
			else 
				assert(0);
			//writefln("Found method: %s", __traits(identifier, method));
		}	
	}
	results~="}";
	return begin~alias_defs~results;
}
unittest {
	interface MyInterface {
		int test(ref string arg) const;
		int test(out int a);
		void test1(in const(char)* c);
		int* test2(float* p);
		alias extern (C) void function(int) type_t;
		void testExtern(type_t t);
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
//	d_array!(const char) buf;
//	buf.ptr=c_str;
//	buf.length=strlen(c_str);
	if(!c_str)
		return c_str[0..0];
	const(char)[] mystring=c_str[0..strlen(c_str)];
	return mystring;
}

T[] cArray2DArray(T)(T* c_arr, size_t length) {
//	d_array!(T) buf;
//	buf.ptr=c_arr;
//	buf.length=length;
//	T[] my_arr=c_arr[0..length];
	return c_arr[0..length];
}
unittest {
	int[] arr=new int[](8);
	d_array!int myarr;
	myarr.length=8;
	myarr.ptr=arr.ptr;
	assert((myarr.arr is arr) && myarr.arr.length==8);  // Check that length is really the length and not the size in bytes.
	assert(myarr.ptr==myarr.arr.ptr);
}
