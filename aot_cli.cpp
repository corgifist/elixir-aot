#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_PrivacyTesting_test_Clause759086();
ExObject ExRemote_PrivacyTesting_test(ExObject argumnets);
ExObject ExModule_PrivacyTesting_test_Clause759086() {
ExObject exReturn = EX_NIL();
exReturn = ExRemote_IO_puts(EX_LIST({EX_ENVIRONMENT.get("x")}));
return exReturn;
}


ExObject ExRemote_PrivacyTesting_test(ExObject arguments) {
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({EX_VAR("x")}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_PrivacyTesting_test_Clause759086();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
ExException_FunctionClauseError(EX_TUPLE({EX_STRING("cannot find suitable clause for function"), EX_ATOM("PrivacyTesting_test"), arguments}));
return EX_NIL();
}




int main() {
GC_INIT();
EX_ENVIRONMENT.push();
try {
{
	;
	ExRemote_PrivacyTesting_test(EX_LIST({EX_NUMBER(12)}));
}
;
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}