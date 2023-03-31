#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;

int main() {
EX_ENVIRONMENT.push();
ExRemote_IO_puts(EX_LIST({ExMath_concatString(EX_STRING("Sum: "), ExRemote_Kernel_to_string(EX_LIST({ExMath_add(EX_NUMBER(2), EX_NUMBER(2))})))}));
return 0;
}