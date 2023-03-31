#include "aotlibkernel.h"

EX_REMOTE_MACRO(Kernel, to_string) {
    return EX_STRING(ExObject_ToString(LIST_AT(args, 0)));
}