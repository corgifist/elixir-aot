#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_Test_main_Clause295026();
ExObject ExRemote_Test_main(ExObject argumnets);
ExObject ExModule_Test_main_Clause295026() {
ExObject exReturn = EX_NIL();
{
exReturn = ExRemote_IO_puts(EX_LIST({EX_STRING("Before macro")}));
exReturn = ExRemote_IO_puts(EX_LIST({EX_STRING("Hello!")}));
}

return exReturn;
}


ExObject ExRemote_Test_main(ExObject arguments) {
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_Test_main_Clause295026();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
ExException_FunctionClauseError(EX_TUPLE({EX_STRING("cannot find suitable clause for function"), EX_ATOM("Test_main"), arguments}));
return EX_NIL();
}




int main() {
GC_INIT();
EX_ENVIRONMENT.push();
try {
{
	{
	;
	;
}
;
	ExRemote_Test_main(EX_LIST({}));
}
;
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}