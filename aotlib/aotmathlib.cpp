#include "aotmathlib.h"

BINARY_OP(ExMath_add, +)
BINARY_OP(ExMath_sub, -)
BINARY_OP(ExMath_mul, *)
BINARY_OP(ExMath_div, /)

CONDITION_OP(ExMath_less, <)
CONDITION_OP(ExMath_greater, >)
CONDITION_OP(ExMath_lessEqual, <=)
CONDITION_OP(ExMath_greaterEqual, >=)

ExObject ExMath_equal(ExObject a, ExObject b) {
    return BOOL_AS_ATOM(ExObject_equals(a, b));
}

ExObject ExMath_notEqual(ExObject a, ExObject b) {
    return BOOL_AS_ATOM(!ExObject_equals(a, b));
}

ExObject ExMath_concatString(ExObject a, ExObject b) { // <>
    return EX_STRING(ExObject_ToString(a) + ExObject_ToString(b));
}