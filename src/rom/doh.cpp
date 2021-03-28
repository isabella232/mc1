// -*- mode: c; tab-width: 2; indent-tabs-mode: nil; -*-
//--------------------------------------------------------------------------------------------------
// Copyright (c) 2020 Marcus Geelnard
//
// This software is provided 'as-is', without any express or implied warranty. In no event will the
// authors be held liable for any damages arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose, including commercial
// applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not claim that you wrote
//     the original software. If you use this software in a product, an acknowledgment in the
//     product documentation would be appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be misrepresented as
//     being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//--------------------------------------------------------------------------------------------------

#include "doh.h"

#include <cstdint>

namespace {
const int FIRST_GLYPH = 32;
const int LAST_GLYPH = 126;
const int NUM_GLYPHS = LAST_GLYPH - FIRST_GLYPH + 1;
}  // namespace

// The 8x8 binary font is defined in another module.
extern uint8_t mc1_font_8x8[NUM_GLYPHS];

extern "C" [[noreturn]] void doh(const char* message) {
  // TODO(m): Implement me! We should create a simple text framebuffer (similar to vconsole),
  // and print the message to the framebuffer (with some pre-text, e.g. "Doh! Abnormal program
  // termination!"). If we want to be fancy, add some graphics like an animated black-yellow caution
  // ribbon and a warning sign.
  (void)message;

  // Never return!
  while (1)
    ;
}
