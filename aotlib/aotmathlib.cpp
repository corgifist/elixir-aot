#include "aotmathlib.h"

BINARY_OP(ExMath_add, +)
BINARY_OP(ExMath_sub, -)
BINARY_OP(ExMath_mul, *)
BINARY_OP(ExMath_div, /)

ExObject ExMath_concatString(ExObject a, ExObject b) { // <>
    return EX_STRING(ExObject_ToString(a) + ExObject_ToString(b));
}