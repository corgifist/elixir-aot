#include "aotlib/aotgeneral.h"

extern ExEnvironment EX_ENVIRONMENT;
int main() {
EX_ENVIRONMENT.push();
ExMatch_pattern(EX_LIST({EX_LIST({EX_LIST({EX_LIST({EX_ATOM("a")})})})}), EX_LIST({EX_LIST({EX_LIST({EX_LIST({EX_NUMBER(1)})})})}));
return 0;
}