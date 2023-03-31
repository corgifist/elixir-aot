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