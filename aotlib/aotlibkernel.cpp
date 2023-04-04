#include "aotlibkernel.h"

EX_REMOTE_MACRO(Kernel, to_string) {
    return EX_STRING(ExObject_ToString(LIST_AT(args, 0)));
}

EX_REMOTE_MACRO(Kernel, hd) {
    ExObject targetList = LIST_AT(args, 0);
    if (AS_LIST(targetList).size() == 0)
        ExException_ArgumentError(targetList);
    return LIST_AT(targetList, 0);
}

EX_REMOTE_MACRO(Kernel, tl) {
    std::vector<ExObject> resultList;
    std::vector<ExObject> originalList = AS_LIST(LIST_AT(args, 0));
    if (originalList.size() < 2)
        ExException_ArgumentError(LIST_AT(args, 0));
    for (int i = 1; i < originalList.size(); i++) {
        resultList.push_back(originalList.at(i));
    }
    return EX_LIST(resultList);
}

EX_REMOTE_MACRO(Kernel, exit) {
    exit(LIST_AT(args, 0).as.atom);
}

EX_REMOTE_MACRO(Kernel, inspect) {
    ExObject argument = LIST_AT(args, 0);
    switch (argument.type) {
        case EX_STRING_TYPE: {
            return EX_STRING("\"" + ExObject_ToString(argument) + "\"");
        }
        case EX_TUPLE_TYPE:
        case EX_LIST_TYPE: {
            std::string acc = "";
            std::vector<ExObject> vector = AS_LIST(argument);
            int index = 0;
            for (ExObject object : vector) {
                acc += AS_STRING(ExRemote_Kernel_inspect(object)) + (index == vector.size() - 1 ? "" : ", ");
                index++;
            }
            return EX_STRING("[" + acc + "]");
        }
        default: {
            return EX_STRING(ExObject_ToString(argument));
        }
    }
}

EX_REMOTE_MACRO(Kernel, in) {
    ExObject target = LIST_AT(args, 0);
    ExObject container = LIST_AT(args, 1);
    if (container.type != EX_LIST_TYPE)
        ExException_ArgumentError(EX_TUPLE({EX_STRING("Kernel.in/2 is not supported for types: "), target, container}));
    std::vector<ExObject> rawContainer = AS_LIST(container);
    for (ExObject object : rawContainer) {
        if (ExObject_equals(target, object)) return EX_ATOM("true");
    }
    return EX_ATOM("false");
}