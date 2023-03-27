#include "aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
int main() {
EX_ENVIRONMENT.push();
{
	ExMatch_pattern(EX_LIST({EX_ATOM("a"), EX_ATOM("b"), EX_ATOM("c")}), EX_LIST({EX_NUMBER(1), EX_NUMBER(2), EX_NUMBER(3)}));
	ExRemote_IO_puts(ExMath_add(ExMath_add(EX_ENVIRONMENT.get("a"), EX_ENVIRONMENT.get("b")), EX_ENVIRONMENT.get("c")));
}
;
return 0;
}