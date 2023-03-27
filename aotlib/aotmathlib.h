#pragma once
#include "aotlib.h"

#define BINARY_OP(name, op) \
    ExObject name(ExObject a, ExObject b) { \
        return EX_NUMBER(AS_NUMBER(a) op AS_NUMBER(b)); \
    }

#define BINARY_OP_DEFINITION(name) \
    ExObject name(ExObject a, ExObject b);

BINARY_OP_DEFINITION(ExMath_add)
BINARY_OP_DEFINITION(ExMath_sub)
BINARY_OP_DEFINITION(ExMath_mul)
BINARY_OP_DEFINITION(ExMath_div)

ExObject ExMath_concatString(ExObject a, ExObject b); // <>