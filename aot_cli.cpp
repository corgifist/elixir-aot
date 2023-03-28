#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_Test_test1_Clause546594() {
ExObject exReturn = EX_NIL();
{
exReturn = ExRemote_IO_puts(EX_LIST({EX_STRING("Test1")}));
exReturn = ExMatch_pattern(EX_VAR("a"), EX_NUMBER(5));
}

return exReturn;
}


ExObject ExRemote_Test_test1(ExObject arguments) {
	EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({}), arguments)) {
		ExObject result = ExModule_Test_test1_Clause546594();
		EX_ENVIRONMENT.pop();
	return result;
	}
throw std::runtime_error("cannot find suitable clause for function call!");
}




int main() {
EX_ENVIRONMENT.push();
{
	;
	ExRemote_Test_test1(EX_LIST({}));
	ExRemote_IO_puts(EX_LIST({EX_ENVIRONMENT.get("a")}));
}
;
return 0;
}