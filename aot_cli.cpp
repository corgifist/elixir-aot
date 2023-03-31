#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;

int main() {
EX_ENVIRONMENT.push();
{
	ExMatch_pattern(EX_VAR("coords"), EX_TUPLE({EX_NUMBER(1), EX_NUMBER(2), EX_NUMBER(3)}));
	ExMatch_pattern(EX_TUPLE({EX_VAR("x"), EX_VAR("y"), EX_VAR("z")}), EX_ENVIRONMENT.get("coords"));
	ExRemote_IO_puts(EX_LIST({ExMath_add(ExMath_add(EX_ENVIRONMENT.get("x"), EX_ENVIRONMENT.get("y")), EX_ENVIRONMENT.get("z"))}));
}
;
return 0;
}