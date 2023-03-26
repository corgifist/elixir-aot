#pragma once
#include <iostream>
#include <string>
#include <unordered_map>
#include <sstream>
#include <stack>

static std::unordered_map<std::string, int> ATOMS;
static std::unordered_map<int, std::string> REVERSED_ATOMS;
static int ATOMS_COUNT = 0;

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

typedef std::unordered_map<std::string, ExObject> ExBinding;

typedef struct {
    std::stack<ExBinding> scope;

    ExObject get(std::string name) {
        return scope.top()[name];
    }

    ExObject write(std::string name, ExObject object) {
        scope.top()[name] = object;
        return object;
    }

    void push() {
        scope.push(scope.top());
    }
    void pop() {
        scope.pop();
    }
} ExEnvironment;

#define EX_NUMBER(value) ((ExObject){EX_NUMBER_TYPE, {.number = value}})
#define EX_NIL() ((ExObject){EX_NIL_TYPE, {}})

#define AS_NUMBER(value) ((value).as.number)

static ExObject EX_ATOM(std::string atom) {
    if (ATOMS.find(atom) != ATOMS.end()) return ((ExObject){EX_ATOM_TYPE, {.atom=ATOMS[atom]}});
    ATOMS[atom] = ATOMS_COUNT;
    REVERSED_ATOMS[ATOMS_COUNT] = atom;
    ATOMS_COUNT++;
    return EX_ATOM(atom);
}

static ExObject EX_STRING(std::string str) {
    std::string mstr = std::move(str);
    return ((ExObject){EX_STRING_TYPE, {.str=&mstr}});
}

ExObject ExRemote_IO_puts(ExObject expr);

static std::string DoubleToString(double value) {
    std::ostringstream strs;
    strs << value;
    return strs.str();
}

std::string ExObject_ToString(ExObject object);