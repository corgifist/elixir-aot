#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
int main() {
EX_ENVIRONMENT.push();
{
	ExMatch_pattern(EX_ATOM("atom"), EX_ATOM("cba"));
	ExRemote_IO_puts(EX_STRING("why?"));
}
;
return 0;
}