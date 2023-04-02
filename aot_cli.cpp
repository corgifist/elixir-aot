#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;

int main() {
GC_INIT();
EX_ENVIRONMENT.push();
try {
ExRemote_IO_puts(EX_LIST({EX_TUPLE({EX_TUPLE({EX_ATOM("+"), EX_LIST({EX_TUPLE({EX_ATOM("context"), EX_ATOM("Elixir")}), EX_TUPLE({EX_ATOM("imports"), EX_LIST({EX_TUPLE({EX_NUMBER(1), EX_ATOM("Elixir.Kernel")}), EX_TUPLE({EX_NUMBER(2), EX_ATOM("Elixir.Kernel")})})})}), EX_LIST({EX_TUPLE({EX_ATOM("a"), EX_LIST({}), EX_ATOM("Elixir")}), EX_TUPLE({EX_ATOM("b"), EX_LIST({}), EX_ATOM("Elixir")})})}), EX_LIST({})})}));
} catch (ExObject object) {
throw std::runtime_error(ExObject_ToString(object));
}
return 0;
}