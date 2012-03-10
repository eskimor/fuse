#!/usr/bin/rdmd -unittest 
import std.stdio;
import std.traits;
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
	struct Test {
		void function() test;
	}
	void my_test() {}
	mixin InitializeFuncPtrStruct!(Test, "my_struct", "my_");	
	writefln(initializeFuncPtrStruct());
//	mixin(initializeFuncPtrStruct!(Test, "my_struct", "my_")());
	
}
mixin template InitializeFuncPtrStruct(StructType, string struct_name, string prefix) {
	string initializeFuncPtrStruct() {
		string result=StructType.stringof~" "~struct_name~"={\n";
		foreach(member; __traits(allMembers, StructType)) {
			//writefln("Is function pointer: %s", isSomeFunction!(mixin(prefix~member)));
			static if(isFunctionPointer!(__traits(getMember, StructType, member)) ) {
				writefln("Juhu!");
			}
			//static if(is(member==function) && is(typeof(mixin("&"~prefix~member))==function)) {
			result~="\t"~member~":&"~prefix~member~",\n";
			//}
		}
		result=result[0..$-2];
		result~="\n};";
		return result;
	}
}

void main() {}
