#pragma once
#include "aotlib.h"

#define BINARY_OP(name, op) \
    ExObject name(ExObject a, ExObject b) { \
        return EX_NUMBER(AS_NUMBER(a) op AS_NUMBER(b)); \
    }

#define CONDITION_OP(name, op) \
    ExObject name(ExObject a, ExObject b) { \
        return BOOL_AS_ATOM(AS_NUMBER(a) op AS_NUMBER(b)); \
    }

#define BINARY_OP_DEFINITION(name) \
    ExObject name(ExObject a, ExObject b);

BINARY_OP_DEFINITION(ExMath_add)
BINARY_OP_DEFINITION(ExMath_sub)
BINARY_OP_DEFINITION(ExMath_mul)
BINARY_OP_DEFINITION(ExMath_div)

BINARY_OP_DEFINITION(ExMath_less)
BINARY_OP_DEFINITION(ExMath_greater)
BINARY_OP_DEFINITION(ExMath_equal)
BINARY_OP_DEFINITION(ExMath_lessEqual)
BINARY_OP_DEFINITION(ExMath_greaterEqual)
BINARY_OP_DEFINITION(ExMath_notEqual)


ExObject ExMath_concatString(ExObject a, ExObject b); // <>