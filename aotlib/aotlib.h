#pragma once
#include <iostream>
#include <string>
#include <unordered_map>
#include <sstream>
#include <stack>
#include <stdexcept>
#include <vector>
#include <cstdarg>
#include <tuple>

typedef enum {
    EX_NUMBER_TYPE, EX_ATOM_TYPE, EX_VAR_TYPE, EX_STRING_TYPE, 
    EX_LIST_TYPE, EX_TUPLE_TYPE, EX_CONS_TYPE, EX_NIL_TYPE
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

typedef struct {
    ExObject head, tail;
} ExCons;

typedef std::unordered_map<std::string, ExObject> ExBinding;

typedef struct {
    std::stack<ExBinding> scope;

    ExObject get(std::string name);
    ExObject write(std::string name, ExObject object);

    void push();
    void pop();
} ExEnvironment;

ExObject EX_LIST(std::vector<ExObject> list);
ExObject EX_TUPLE(std::vector<ExObject> tuple);

ExObject EX_ATOM(std::string atom);

ExObject EX_VAR(std::string var);

ExObject EX_STRING(std::string str);

ExObject EX_CONS(ExObject head, ExObject tail);
ExObject CONS_AS_LIST(ExObject cons);

ExObject ExRemote_IO_puts(ExObject expr);

ExObject ExMatch_pattern(ExObject left, ExObject right);
bool ExMatch_tryMatch(ExObject left, ExObject right);

ExObject ExClause_tupleToList(std::tuple<ExObject> tuple);

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
#define AS_LIST(value) (*((std::vector<ExObject>*) (value).as.pointer))
#define AS_CONS(value) (*((ExCons*) (value).as.pointer))
#define AS_STRING(value) *(value.as.str)

#define BOOL_AS_ATOM(value) ((value) ? EX_ATOM("true") : EX_ATOM("false"))

#define LIST_AT(list, index) ((AS_LIST(list)).at(index))

#define IS_TRUE(atom) (ExObject_ToString(atom)) == ":true"

#define EX_NOT_EXPR(expr) BOOL_AS_ATOM(!(IS_TRUE(expr)))

// because it is impossible to import aotlibexceptions.h
#define MATCH_ERROR() throw EX_TUPLE({EX_ATOM("MatchError"), EX_TUPLE({EX_STRING("cannot match values"), left, right})});
#define VARIABLE_ERROR(name) throw EX_TUPLE({EX_ATOM("RuntimeError"), EX_TUPLE({EX_STRING("unknown variable/function"), EX_STRING(name)})})