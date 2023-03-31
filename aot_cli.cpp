#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;

int main() {
EX_ENVIRONMENT.push();
try {
{
	ExMatch_pattern(EX_VAR("list"), EX_LIST({EX_NUMBER(1), EX_NUMBER(2), EX_NUMBER(3)}));
	ExMatch_pattern(EX_VAR("fn_hd"), ExRemote_Kernel_hd(EX_LIST({EX_ENVIRONMENT.get("list")})));
	ExMatch_pattern(EX_VAR("fn_tl"), ExRemote_Kernel_tl(EX_LIST({EX_ENVIRONMENT.get("list")})));
	ExMatch_pattern(EX_CONS(EX_VAR("match_hd"), EX_VAR("match_tl")), EX_ENVIRONMENT.get("list"));
	ExRemote_IO_puts(EX_LIST({ExMath_concatString(ExRemote_Kernel_to_string(EX_LIST({EX_ENVIRONMENT.get("fn_hd")})), ExMath_concatString(EX_STRING(" "), ExRemote_Kernel_to_string(EX_LIST({EX_ENVIRONMENT.get("fn_tl")}))))}));
	ExRemote_Kernel_exit(EX_LIST({EX_ATOM("normal")}));
	ExRemote_IO_puts(EX_LIST({ExMath_concatString(ExRemote_Kernel_to_string(EX_LIST({EX_ENVIRONMENT.get("match_hd")})), ExMath_concatString(EX_STRING(" "), ExRemote_Kernel_to_string(EX_LIST({EX_ENVIRONMENT.get("match_tl")}))))}));
}
;
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}