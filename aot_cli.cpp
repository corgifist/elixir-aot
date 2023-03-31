#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;

int main() {
EX_ENVIRONMENT.push();
try {
ExRemote_IO_puts(EX_LIST({EX_NOT_EXPR(EX_ATOM("true"))}));
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}