#pragma once
#include "aotlib.h"

#define EXCEPTION_DEFINITION(name) void ExException_##name(ExObject arg)

#define EXCEPTION_STANDARD_IMPLEMENTATION(name) \
    EXCEPTION_DEFINITION(name) { \
        throw EX_TUPLE({EX_ATOM(#name), arg}); \
    }

EXCEPTION_DEFINITION(throw);
EXCEPTION_DEFINITION(RuntimeError);
EXCEPTION_DEFINITION(ArgumentError);
EXCEPTION_DEFINITION(ArithmeticError);
EXCEPTION_DEFINITION(BadArityError);
EXCEPTION_DEFINITION(BadBooleanError);
EXCEPTION_DEFINITION(BadFunctionError);
EXCEPTION_DEFINITION(BadMapError);
EXCEPTION_DEFINITION(BadStructError);
EXCEPTION_DEFINITION(BadStructError);
EXCEPTION_DEFINITION(CaseClauseError);
EXCEPTION_DEFINITION(Code_LoadError);
EXCEPTION_DEFINITION(CompileError);
EXCEPTION_DEFINITION(CondClauseError);
EXCEPTION_DEFINITION(Enum_EmptyError);
EXCEPTION_DEFINITION(Enum_OutOfBoundsError);
EXCEPTION_DEFINITION(File_CopyError);
EXCEPTION_DEFINITION(File_Error);
EXCEPTION_DEFINITION(File_LinkError);
EXCEPTION_DEFINITION(File_RenameError);
EXCEPTION_DEFINITION(FunctionClauseError);
EXCEPTION_DEFINITION(IO_StreamError);
EXCEPTION_DEFINITION(Inspect_Error);
EXCEPTION_DEFINITION(KeyError);
EXCEPTION_DEFINITION(MatchError);
EXCEPTION_DEFINITION(Module_Types_Error);
EXCEPTION_DEFINITION(OptionParser_ParseError);