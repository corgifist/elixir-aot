#pragma once
#include <iostream>
#include <string>
#include <unordered_map>
#include <sstream>
#include <stack>
#include <stdexcept>
#include <vector>
#include <cstdarg>

typedef enum {
    EX_NUMBER_TYPE, EX_ATOM_TYPE, EX_STRING_TYPE, 
    EX_LIST_TYPE, EX_NIL_TYPE
} ExValueType;

typedef struct {
    ExValueType type;
    union {
        double number;
        int atom;
        std::string* str;

        void* pointer;
    } as;
} ExObject;

typedef std::unordered_map<std::string, ExObject> ExBinding;

typedef struct {
    std::stack<ExBinding> scope;

    ExObject get(std::string name);
    ExObject write(std::string name, ExObject object);

    void push();
    void pop();
} ExEnvironment;

ExObject EX_LIST(std::vector<ExObject> list);

ExObject EX_ATOM(std::string atom);

ExObject EX_STRING(std::string str);

ExObject ExRemote_IO_puts(ExObject expr);

ExObject ExMatch_pattern(ExObject left, ExObject right);

static std::string DoubleToString(double value) {
    std::ostringstream strs;
    strs << value;
    return strs.str();
}

bool ExObject_equals(ExObject a, ExObject b);
std::string ExObject_ToString(ExObject object);
std::string ExObject_AtomToRawString(ExObject object);
std::string ExObject_ListToString(ExObject list);

#define EX_NUMBER(value) ((ExObject){EX_NUMBER_TYPE, {.number = value}})
#define EX_NIL() ((ExObject){EX_NIL_TYPE, {}})

#define AS_NUMBER(value) ((value).as.number)
#define AS_LIST(value) *((std::vector<ExObject>*) (value).as.pointer)
#define AS_STRING(value) *(value.as.str)

#define MATCH_ERROR() throw std::runtime_error("cannot match values: " + ExObject_ToString(left) + " and " + ExObject_ToString(right))