#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_Test_b_Clause193779() {
ExObject exReturn = EX_NIL();
exReturn = EX_ATOM("b");
return exReturn;
}

ExObject ExModule_Test_a_Clause975503() {
ExObject exReturn = EX_NIL();
exReturn = EX_ATOM("a");
return exReturn;
}


ExObject ExRemote_Test_b(ExObject arguments) {
	//EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({}), arguments)) {
		ExObject result = ExModule_Test_b_Clause193779();
		//EX_ENVIRONMENT.pop();
	return result;
	}
throw std::runtime_error("cannot find suitable clause for function call!");
}

ExObject ExRemote_Test_a(ExObject arguments) {
	//EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({}), arguments)) {
		ExObject result = ExModule_Test_a_Clause975503();
		//EX_ENVIRONMENT.pop();
	return result;
	}
throw std::runtime_error("cannot find suitable clause for function call!");
}




int main() {
EX_ENVIRONMENT.push();
{
	;
	ExRemote_IO_puts(EX_LIST({ExRemote_Test_a(EX_LIST({}))}));
	ExRemote_IO_puts(EX_LIST({ExRemote_Test_b(EX_LIST({}))}));
}
;
return 0;
}