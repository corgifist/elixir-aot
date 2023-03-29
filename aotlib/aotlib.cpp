#include "aotlib.h"

std::unordered_map<std::string, int> ATOMS;
std::unordered_map<int, std::string> REVERSED_ATOMS;
int ATOMS_COUNT = 0;
extern ExEnvironment EX_ENVIRONMENT{};

ExObject ExMatch_pattern(ExObject left, ExObject right) {
    switch (left.type) {
        case EX_VAR_TYPE: { // variable pattern
            std::string name = AS_STRING(left);
            EX_ENVIRONMENT.write(name, right);
            break;
        }
        case EX_LIST_TYPE: { // list pattern
            std::vector<ExObject> leftList = AS_LIST(left);
            std::vector<ExObject> rightList = AS_LIST(right);
            if (leftList.size() != rightList.size()) 
                MATCH_ERROR();
            for (int i = 0; i < leftList.size(); i++) {
                ExObject leftObject = leftList.at(i);
                ExObject rightObject = rightList.at(i);
                ExMatch_pattern(leftObject, rightObject);
            }
            break;
        }
        case EX_CONS_TYPE: { // cons type
            ExCons leftCons = AS_CONS(left);
            std::vector<ExObject> rightCons = AS_LIST(right);
            ExMatch_pattern(leftCons.head, rightCons.at(0));
            std::vector<ExObject> cutTail;
            for (int i = 1; i < rightCons.size(); i++) {
                cutTail.push_back(rightCons.at(i));
            }
            ExMatch_pattern(leftCons.tail, EX_LIST(cutTail));
            break;
        }
        default: { // constant pattern
            if (!ExObject_equals(left, right)) 
                MATCH_ERROR();
        }
    }
    return right;
}

bool ExMatch_tryMatch(ExObject left, ExObject right) {
    try {
        ExMatch_pattern(left, right);
        return true;
    } catch (std::runtime_error& ex) {
        return false;
    }
}

ExObject ExRemote_IO_puts(ExObject args) {
    std::cout << ExObject_ToString(LIST_AT(args, 0)) << std::endl;
    return EX_ATOM("ok");
}

ExObject ExEnvironment::get(std::string name) {
    if (scope.top().find(name) == scope.top().end()) {
        throw std::runtime_error("undefined variable/function " + name);
    }
    return scope.top()[name];
}

ExObject ExEnvironment::write(std::string name, ExObject object) {
    scope.top()[name] = object;
    return object;
}

void ExEnvironment::push() {
    if (scope.empty()) {
        scope.push(ExBinding{});
        return;
    }
    ExBinding binding = scope.top();
    scope.push(binding);
}

void ExEnvironment::pop() {
    scope.pop();
}

std::string ExObject_ToString(ExObject object) {
    switch (object.type) {
        case EX_NUMBER_TYPE: {
            return DoubleToString(AS_NUMBER(object));
        }
        case EX_ATOM_TYPE: {
            return ":" + REVERSED_ATOMS[object.as.atom];
        }
        case EX_STRING_TYPE: {
            return AS_STRING(object);
        }
        case EX_LIST_TYPE: {
            return ExObject_ListToString(object);
        }
        case EX_VAR_TYPE: {
            return AS_STRING(object);
        }
        case EX_CONS_TYPE: {
            ExCons cons = AS_CONS(object);
            std::vector<ExObject> futurePreview;
            futurePreview.push_back(cons.head);
            std::vector<ExObject> tailVector = AS_LIST(cons.tail);
            for (auto& object : tailVector) {
                futurePreview.push_back(object);
            }
            return ExObject_ToString(EX_LIST(futurePreview));
        }
        case EX_NIL_TYPE: {
            return "nil";
        }
        default: {
            return "unknown aot type";
        }
    }
}

std::string ExObject_AtomToRawString(ExObject object) {
    return REVERSED_ATOMS[object.as.atom];
}

std::string ExObject_ListToString(ExObject list) {
    std::string result = "";
    std::vector<ExObject> vectorList = AS_LIST(list);
    int index = 0;
    for (ExObject object : vectorList) {
        result += ExObject_ToString(object) + (index == vectorList.size() - 1 ? "" : ", ");
        index++;
    }
    return "[" + result + "]";
}

bool ExObject_equals(ExObject a, ExObject b) {
    if (a.type != b.type) return false;
    switch (a.type) {
        case EX_NUMBER_TYPE: {
            return AS_NUMBER(a) == AS_NUMBER(b);
        }
        case EX_ATOM_TYPE: {
            return a.as.atom == b.as.atom;
        }
        case EX_STRING_TYPE: {
            return AS_STRING(a) == AS_STRING(b);
        }
        case EX_LIST_TYPE: {
            std::vector<ExObject> aList = AS_LIST(a);
            std::vector<ExObject> bList = AS_LIST(b);
            if (aList.size() != bList.size()) return false;
            for (int i = 0; i < aList.size(); i++) {
                ExObject aObject = aList.at(i);
                ExObject bObject = bList.at(i);
                if (!ExObject_equals(aObject, bObject)) return false;
            }
            return true;
        }
        case EX_CONS_TYPE: {
            ExCons aCons = AS_CONS(a);
            ExCons bCons = AS_CONS(b);
            return ExObject_equals(aCons.head, bCons.head) &&
                    ExObject_equals(aCons.tail, aCons.tail);
        }
        case EX_NIL_TYPE: {
            return a.type == b.type;
        }
    }
    return false;
}

ExObject EX_LIST(std::vector<ExObject> list) {
    ExObject result{};
    result.type = EX_LIST_TYPE;
    result.as.pointer = &list;
    return result;
}

ExObject EX_ATOM(std::string atom) {
    if (ATOMS.find(atom) != ATOMS.end()) return ((ExObject){EX_ATOM_TYPE, {.atom=ATOMS[atom]}});
    ATOMS[atom] = ATOMS_COUNT;
    REVERSED_ATOMS[ATOMS_COUNT] = atom;
    ATOMS_COUNT++;
    return EX_ATOM(atom);
}

ExObject EX_VAR(std::string atom) {
    ExObject result = EX_STRING(atom);
    result.type = EX_VAR_TYPE; // only for pattern matching
    return result;
}

ExObject EX_CONS(ExObject head, ExObject tail) {
    ExCons cons{};
    cons.head = head;
    cons.tail = tail;
    ExObject result{};
    result.type = EX_CONS_TYPE;
    result.as.pointer = &cons;
    return result;
}

ExObject EX_STRING(std::string str) {
    std::string* mstr = new std::string(str);
    return ((ExObject){EX_STRING_TYPE, {.str=mstr}});
}