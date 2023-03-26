#include <iostream>
#include <string>
#include <unordered_map>
#include <sstream>

std::unordered_map<std::string, int> ATOMS;
std::unordered_map<int, std::string> REVERSED_ATOMS;
int ATOMS_COUNT = 0;

typedef enum {
    EX_NUMBER_TYPE, EX_ATOM_TYPE, EX_STRING_TYPE, EX_NIL_TYPE
} ExValueType;

typedef struct {
    ExValueType type;
    union {
        double number;
        int atom;
        std::string* str;
    } as;
} ExObject;

#define EX_NUMBER(value) ((ExObject){EX_NUMBER_TYPE, {.number = value}})
#define EX_NIL() ((ExObject){EX_NIL_TYPE, {}})

#define AS_NUMBER(value) ((value).as.number)

ExObject EX_ATOM(std::string atom) {
    if (ATOMS.find(atom) != ATOMS.end()) return ((ExObject){EX_ATOM_TYPE, {.atom=ATOMS[atom]}});
    ATOMS[atom] = ATOMS_COUNT;
    REVERSED_ATOMS[ATOMS_COUNT] = atom;
    ATOMS_COUNT++;
    return EX_ATOM(atom);
}

ExObject EX_STRING(std::string str) {
    std::string mstr = std::move(str);
    return ((ExObject){EX_STRING_TYPE, {.str=&mstr}});
}

ExObject ExRemote_IO_puts(ExObject expr);

std::string DoubleToString(double value) {
    std::ostringstream strs;
    strs << value;
    return strs.str();
}

std::string ExObject_ToString(ExObject object);