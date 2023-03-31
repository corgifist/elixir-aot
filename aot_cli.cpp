#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_NestedTraversingTest_first_Clause48565();
ExObject ExModule_NestedTraversingTest_second_Clause877912();
ExObject ExRemote_NestedTraversingTest_first(ExObject argumnets);
ExObject ExRemote_NestedTraversingTest_second(ExObject argumnets);
ExObject ExModule_NestedTraversingTest_first_Clause48565() {
ExObject exReturn = EX_NIL();
{
exReturn = ExRemote_IO_puts(EX_LIST({ExMath_concatString(EX_STRING("In "), ExRemote_Kernel_to_string(EX_LIST({EX_ATOM("internal")})))}));
exReturn = ExRemote_NestedTraversingTest_second(EX_LIST({}));
}

return exReturn;
}

ExObject ExModule_NestedTraversingTest_second_Clause877912() {
ExObject exReturn = EX_NIL();
exReturn = ExRemote_IO_puts(EX_LIST({ExMath_concatString(EX_STRING("In "), ExMath_concatString(ExRemote_Kernel_hd(EX_LIST({EX_LIST({EX_NUMBER(2)})})), ExRemote_Kernel_to_string(EX_LIST({EX_ATOM("nd")}))))}));
return exReturn;
}


ExObject ExRemote_NestedTraversingTest_first(ExObject arguments) {
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_NestedTraversingTest_first_Clause48565();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
ExException_FunctionClauseError(EX_TUPLE({EX_STRING("cannot find suitable clause for function"), EX_ATOM("NestedTraversingTest_first"), arguments}));
return EX_NIL();
}

ExObject ExRemote_NestedTraversingTest_second(ExObject arguments) {
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_NestedTraversingTest_second_Clause877912();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
ExException_FunctionClauseError(EX_TUPLE({EX_STRING("cannot find suitable clause for function"), EX_ATOM("NestedTraversingTest_second"), arguments}));
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
	ExRemote_NestedTraversingTest_first(EX_LIST({}));
}
;
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}