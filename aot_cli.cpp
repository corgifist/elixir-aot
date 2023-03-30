#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExModule_HT_sum_all_Clause370908();
ExObject ExModule_HT_sum_all_Clause469373();
ExObject ExModule_HT_sum_all_Clause744887();
ExObject ExRemote_HT_sum_all(ExObject argumnets);
ExObject ExModule_HT_sum_all_Clause469373() {
ExObject exReturn = EX_NIL();
exReturn = ExRemote_HT_sum_all(EX_LIST({EX_ENVIRONMENT.get("list"), EX_NUMBER(0)}));
return exReturn;
}

ExObject ExModule_HT_sum_all_Clause370908() {
ExObject exReturn = EX_NIL();
exReturn = EX_ENVIRONMENT.get("acc");
return exReturn;
}

ExObject ExModule_HT_sum_all_Clause744887() {
ExObject exReturn = EX_NIL();
exReturn = ExRemote_HT_sum_all(EX_LIST({EX_ENVIRONMENT.get("tail"), ExMath_add(EX_ENVIRONMENT.get("expr"), EX_ENVIRONMENT.get("acc"))}));
return exReturn;
}


ExObject ExRemote_HT_sum_all(ExObject arguments) {
	EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({EX_VAR("list")}), arguments)) {
		if (IS_TRUE(EX_ATOM("true"))) {
			ExObject result = ExModule_HT_sum_all_Clause469373();
			EX_ENVIRONMENT.pop();
			return result;
		};
	}
	EX_ENVIRONMENT.pop();
	EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({EX_LIST({}), EX_VAR("acc")}), arguments)) {
		if (IS_TRUE(EX_ATOM("true"))) {
			ExObject result = ExModule_HT_sum_all_Clause370908();
			EX_ENVIRONMENT.pop();
			return result;
		};
	}
	EX_ENVIRONMENT.pop();
	EX_ENVIRONMENT.push();
	if (ExMatch_tryMatch(EX_LIST({EX_CONS(EX_VAR("expr"), EX_VAR("tail")), EX_VAR("acc")}), arguments)) {
		if (IS_TRUE(EX_ATOM("true"))) {
			ExObject result = ExModule_HT_sum_all_Clause744887();
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
	ExRemote_IO_puts(EX_LIST({ExRemote_HT_sum_all(EX_LIST({EX_LIST({EX_NUMBER(1), EX_NUMBER(2), EX_NUMBER(3)})}))}));
}
;
return 0;
}