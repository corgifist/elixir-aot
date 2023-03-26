#pragma once
#include "aotlib.h"

#define BINARY_OP(name, op) \
    static ExObject name(ExObject a, ExObject b) { \
        return EX_NUMBER(AS_NUMBER(a) op AS_NUMBER(b)); \
    }

BINARY_OP(add, +)
BINARY_OP(sub, -)
BINARY_OP(mul, *)
BINARY_OP(div, /)

static ExObject concatString(ExObject a, ExObject b) { // <>
    return EX_STRING(ExObject_ToString(a) + ExObject_ToString(b));
}