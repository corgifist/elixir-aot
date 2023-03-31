#pragma once
#include "aotlib.h"

#define EX_REMOTE_MACRO(module, target) ExObject ExRemote_##module##_##target(ExObject args)