#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_Fibonacci_fib_Clause107232();
ExObject ExModule_Fibonacci_fib_Clause338862();
ExObject ExModule_Fibonacci_fib_Clause41455();
ExObject ExRemote_Fibonacci_fib(ExObject argumnets);
ExObject ExModule_Fibonacci_fib_Clause107232() {
ExObject exReturn = EX_NIL();
exReturn = EX_NUMBER(1);
return exReturn;
}

ExObject ExModule_Fibonacci_fib_Clause41455() {
ExObject exReturn = EX_NIL();
exReturn = EX_NUMBER(1);
return exReturn;
}

ExObject ExModule_Fibonacci_fib_Clause338862() {
ExObject exReturn = EX_NIL();
exReturn = ExMath_add(ExRemote_Fibonacci_fib(EX_LIST({ExMath_sub(EX_ENVIRONMENT.get("n"), EX_NUMBER(1))})), ExRemote_Fibonacci_fib(EX_LIST({ExMath_sub(EX_ENVIRONMENT.get("n"), EX_NUMBER(2))})));
return exReturn;
}


ExObject ExRemote_Fibonacci_fib(ExObject arguments) {
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({EX_NUMBER(0)}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_Fibonacci_fib_Clause107232();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({EX_NUMBER(1)}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_Fibonacci_fib_Clause41455();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
		EX_ENVIRONMENT.push();
		if (ExMatch_tryMatch(EX_LIST({EX_VAR("n")}), arguments)) {
			if (IS_TRUE(EX_ATOM("true"))) {
				ExObject result = ExModule_Fibonacci_fib_Clause338862();
				EX_ENVIRONMENT.pop();
				return result;
			};
		}
		EX_ENVIRONMENT.pop();
ExException_FunctionClauseError(EX_TUPLE({EX_STRING("cannot find suitable clause for function"), EX_ATOM("Fibonacci_fib"), arguments}));
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
	;
}
;
	ExRemote_IO_puts(EX_LIST({ExRemote_Fibonacci_fib(EX_LIST({EX_NUMBER(10)}))}));
}
;
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}