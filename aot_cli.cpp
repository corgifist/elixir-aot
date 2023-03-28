#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_Math_sum_Clause774165() {
ExObject exReturn = EX_NIL();
exReturn = ExMath_add(EX_ENVIRONMENT.get("a"), EX_ENVIRONMENT.get("a"));
return exReturn;
}

ExObject ExModule_Math_sum_Clause787144() {
ExObject exReturn = EX_NIL();
exReturn = ExMath_add(EX_ENVIRONMENT.get("a"), EX_ENVIRONMENT.get("b"));
return exReturn;
}


ExObject ExRemote_Math_sum(ExObject arguments) {
	//EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({EX_VAR("a"), EX_VAR("b")}), arguments)) {
		ExObject result = ExModule_Math_sum_Clause787144();
		//EX_ENVIRONMENT.pop();
	return result;
	}
	//EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({EX_VAR("a")}), arguments)) {
		ExObject result = ExModule_Math_sum_Clause774165();
		//EX_ENVIRONMENT.pop();
	return result;
	}
throw std::runtime_error("cannot find suitable clause for function call!");
}



int main() {
EX_ENVIRONMENT.push();
{
	;
	ExRemote_IO_puts(EX_LIST({ExRemote_Math_sum(EX_LIST({EX_NUMBER(1)}))}));
}
;
return 0;
}