#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_MacroTesting_main_Clause562255();
ExObject ExRemote_MacroTesting_main(ExObject argumnets);
ExObject ExModule_MacroTesting_main_Clause562255() {
ExObject exReturn = EX_NIL();
{
exReturn = ExMatch_pattern(EX_VAR("a"), EX_NUMBER(5));
exReturn = ExRemote_IO_puts(EX_LIST({ExMath_concatString(EX_STRING("A: "), ExRemote_Kernel_to_string(EX_LIST({EX_ENVIRONMENT.get("a")})))}));
exReturn = ExRemote_IO_puts(EX_LIST({EX_STRING("begining")}));
exReturn = ExRemote_IO_puts(EX_LIST({EX_TUPLE({EX_TUPLE({EX_ATOM("{}"), EX_LIST({}), EX_LIST({EX_ATOM("atomic")})}), EX_LIST({})})}));
exReturn = ExRemote_IO_puts(EX_LIST({ExRemote_Kernel_to_string(EX_LIST({EX_NUMBER(1)}))}));
exReturn = ExRemote_IO_puts(EX_LIST({ExRemote_Kernel_to_string(EX_LIST({EX_NUMBER(2)}))}));
exReturn = ExRemote_IO_puts(EX_LIST({EX_TUPLE({EX_TUPLE({EX_ATOM("+"), EX_LIST({EX_TUPLE({EX_ATOM("context"), EX_ATOM("Elixir")}), EX_TUPLE({EX_ATOM("imports"), EX_LIST({EX_TUPLE({EX_NUMBER(1), EX_ATOM("Elixir.Kernel")}), EX_TUPLE({EX_NUMBER(2), EX_ATOM("Elixir.Kernel")})})})}), EX_LIST({EX_TUPLE({EX_ATOM("a"), EX_LIST({}), EX_ATOM("Elixir")}), EX_TUPLE({EX_ATOM("b"), EX_LIST({}), EX_ATOM("Elixir")})})}), EX_LIST({})})}));
exReturn = ExRemote_IO_inspect(EX_LIST({EX_STRING("Hello, World!")}));
}

return exReturn;
}


ExObject ExRemote_MacroTesting_main(ExObject arguments) {
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_MacroTesting_main_Clause562255();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
ExException_FunctionClauseError(EX_TUPLE({EX_STRING("cannot find suitable clause for function"), EX_ATOM("MacroTesting_main"), arguments}));
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
	ExRemote_MacroTesting_main(EX_LIST({}));
}
;
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}