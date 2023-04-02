#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;




int main() {
GC_INIT();
EX_ENVIRONMENT.push();
try {
{
	;
	ExRemote_IO_puts(EX_LIST({EX_STRING("Hello, World!")}));
}
;
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}