#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
ExObject ExCase836063(ExObject argument);
ExObject ExCase836063(ExObject argument) {
EX_ENVIRONMENT.push();
if (ExMatch_tryMatch(EX_NUMBER(12), argument)) {
if (IS_TRUE(EX_ATOM("true"))) {
ExObject exReturn = EX_NIL();
exReturn = EX_ATOM("raw_twelve");
EX_ENVIRONMENT.pop();
return exReturn;
}
}
EX_ENVIRONMENT.pop();
ExException_CaseClauseError(argument);
return EX_NIL();
}

int main() {
GC_INIT();
EX_ENVIRONMENT.push();
try {
ExRemote_IO_puts(EX_LIST({ExCase836063(EX_NUMBER(12))}));
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}