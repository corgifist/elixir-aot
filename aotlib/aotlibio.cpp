#include "aotlibio.h"

EX_REMOTE_MACRO(IO, puts) {
    std::cout << ExObject_ToString(LIST_AT(args, 0)) << std::endl;
    return EX_ATOM("ok");
}

EX_REMOTE_MACRO(IO, inspect) {
    std::cout << AS_STRING(ExRemote_Kernel_inspect(EX_LIST({LIST_AT(args, 0)}))) << std::endl;
    return LIST_AT(args, 0);
}