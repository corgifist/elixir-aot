#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_Checker_is_true_Clause133870();
ExObject ExModule_Checker_is_true_Clause476412();
ExObject ExRemote_Checker_is_true(ExObject argumnets);
ExObject ExModule_Checker_is_true_Clause476412() {
ExObject exReturn = EX_NIL();
exReturn = EX_STRING("not true uhhh");
return exReturn;
}

ExObject ExModule_Checker_is_true_Clause133870() {
ExObject exReturn = EX_NIL();
exReturn = EX_STRING("true yeeeah");
return exReturn;
}


ExObject ExRemote_Checker_is_true(ExObject arguments) {
	EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({EX_VAR("x")}), arguments)) {
		if (IS_TRUE(EX_ENVIRONMENT.get("x"))) {
			ExObject result = ExModule_Checker_is_true_Clause133870();
			EX_ENVIRONMENT.pop();
			return result;
		};
	}
	EX_ENVIRONMENT.pop();
	EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({EX_VAR("x")}), arguments)) {
		if (IS_TRUE(EX_ATOM("true"))) {
			ExObject result = ExModule_Checker_is_true_Clause476412();
			EX_ENVIRONMENT.pop();
			return result;
		};
	}
	EX_ENVIRONMENT.pop();
throw std::runtime_error("cannot find suitable clause for function call!");
}




int main() {
EX_ENVIRONMENT.push();
{
	;
	ExRemote_IO_puts(EX_LIST({ExRemote_Checker_is_true(EX_LIST({EX_ATOM("true")}))}));
	ExRemote_IO_puts(EX_LIST({ExRemote_Checker_is_true(EX_LIST({EX_ATOM("abc")}))}));
}
;
return 0;
}