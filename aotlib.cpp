#include "aotlib.h"


ExObject ExRemote_IO_puts(ExObject expr) {
    std::cout << ExObject_ToString(expr) << std::endl;
    return EX_ATOM("ok");
}

std::string ExObject_ToString(ExObject object) {
    switch (object.type) {
        case EX_NUMBER_TYPE: {
            return DoubleToString(AS_NUMBER(object));
        }
        case EX_ATOM_TYPE: {
            return REVERSED_ATOMS[object.as.atom];
        }
        
        default: {
            return "unknown aot type";
        }
    }
}