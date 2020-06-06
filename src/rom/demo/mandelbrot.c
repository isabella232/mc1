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

#include <mc1/fast_math.h>
#include <mc1/framebuffer.h>

#include <stdint.h>


//--------------------------------------------------------------------------------------------------
// Configuration.
//--------------------------------------------------------------------------------------------------

typedef struct {
  int width;
  int height;
  int mode;
} vmode_t;

// Different video modes to try (we try lower and lower until the framebuffer fits in memory).
static const vmode_t VMODES[] = {
  {1024, 576, CMODE_PAL8},
  {1024, 576, CMODE_PAL4},
  {640, 360, CMODE_PAL8},
  {900, 506, CMODE_PAL4},
  {624, 351, CMODE_PAL4},
  {400, 225, CMODE_PAL8},
  {400, 225, CMODE_PAL4},
  {400, 225, CMODE_PAL2},
  {400, 225, CMODE_PAL1},
  {200, 112, CMODE_PAL1}
};
#define NUM_VMODES (int)(sizeof(VMODES) / sizeof(VMODES[0]))

typedef struct {
  float re;
  float im;
} cplx_t;

// Mandelbrot viewing area configuration.
static const cplx_t CENTER = {-1.2537962239935088f, -0.38392281601604755f};
static const float MAX_SIZE = 6.0f;
static const int MAX_ITERATIONS = 128;


//--------------------------------------------------------------------------------------------------
// Palette.
//--------------------------------------------------------------------------------------------------

// This is a fiery palette.
static const uint8_t PAL_128_RGB[128*3] = {
  0xed,0xc0,0x87, 0xee,0xc4,0x8d, 0xef,0xc8,0x95, 0xf1,0xcc,0x9d, 0xf1,0xd0,0xa5, 0xf3,0xd5,0xad,
  0xf4,0xd8,0xb5, 0xf5,0xdc,0xbc, 0xf6,0xe1,0xc4, 0xf7,0xe5,0xcc, 0xf8,0xe9,0xd4, 0xfa,0xed,0xdb,
  0xfb,0xf1,0xe3, 0xfc,0xf4,0xeb, 0xfd,0xf9,0xf2, 0xf3,0xf3,0xf3, 0xef,0xef,0xef, 0xe8,0xe9,0xe9,
  0xe2,0xe2,0xe1, 0xdb,0xdb,0xdb, 0xd4,0xd5,0xd4, 0xcd,0xcd,0xce, 0xc7,0xc7,0xc7, 0xc0,0xc0,0xc0,
  0xb9,0xb9,0xba, 0xb3,0xb3,0xb3, 0xad,0xac,0xac, 0xa5,0xa6,0xa5, 0x9f,0x9f,0x9f, 0x98,0x98,0x99,
  0x92,0x91,0x91, 0x8b,0x8b,0x8b, 0x85,0x84,0x85, 0x7e,0x7e,0x7e, 0x77,0x77,0x77, 0x70,0x70,0x70,
  0x67,0x67,0x67, 0x60,0x60,0x60, 0x5a,0x5a,0x5a, 0x54,0x54,0x54, 0x4d,0x4d,0x4e, 0x47,0x47,0x47,
  0x41,0x41,0x40, 0x3a,0x3a,0x3b, 0x34,0x34,0x34, 0x2e,0x2d,0x2d, 0x27,0x27,0x28, 0x21,0x21,0x21,
  0x13,0x13,0x12, 0x09,0x09,0x09, 0x00,0x00,0x00, 0x09,0x04,0x02, 0x12,0x07,0x04, 0x1a,0x0a,0x05,
  0x23,0x0d,0x07, 0x2b,0x10,0x08, 0x34,0x13,0x0a, 0x3d,0x16,0x0d, 0x45,0x1a,0x0e, 0x4d,0x1d,0x10,
  0x56,0x20,0x11, 0x5f,0x23,0x13, 0x66,0x26,0x15, 0x6f,0x29,0x17, 0x7a,0x2d,0x18, 0x87,0x31,0x1b,
  0x93,0x36,0x1d, 0x9f,0x3b,0x20, 0xaa,0x3f,0x22, 0xb7,0x43,0x25, 0xc3,0x48,0x27, 0xce,0x4c,0x29,
  0xdb,0x51,0x2b, 0xe4,0x59,0x2c, 0xe7,0x6a,0x27, 0xe9,0x7b,0x23, 0xec,0x8d,0x1e, 0xef,0x9e,0x1a,
  0xf3,0xb1,0x15, 0xf6,0xc6,0x0f, 0xfa,0xdc,0x09, 0xfc,0xf1,0x04, 0xfe,0xfd,0x00, 0xfe,0xf7,0x00,
  0xfc,0xf1,0x00, 0xfb,0xec,0x00, 0xfa,0xe5,0x00, 0xf8,0xe0,0x00, 0xf7,0xda,0x00, 0xf6,0xd4,0x00,
  0xf5,0xce,0x00, 0xf3,0xc8,0x00, 0xf2,0xc4,0x00, 0xf1,0xc1,0x00, 0xf1,0xbc,0x00, 0xf0,0xb8,0x00,
  0xef,0xb4,0x00, 0xee,0xb0,0x00, 0xed,0xad,0x00, 0xe9,0xa7,0x00, 0xe5,0xa2,0x00, 0xe1,0x9c,0x00,
  0xdc,0x96,0x00, 0xd9,0x90,0x01, 0xd5,0x8a,0x01, 0xd1,0x84,0x00, 0xce,0x7e,0x00, 0xca,0x79,0x00,
  0xc5,0x72,0x01, 0xc1,0x6d,0x00, 0xbe,0x67,0x01, 0xba,0x61,0x01, 0xb6,0x5b,0x01, 0xb2,0x55,0x01,
  0xae,0x4f,0x00, 0xa9,0x4a,0x00, 0xa2,0x45,0x00, 0x9c,0x3f,0x01, 0x95,0x3a,0x01, 0x8e,0x34,0x00,
  0x87,0x2d,0x00, 0x81,0x27,0x01, 0x7a,0x21,0x01, 0x73,0x1c,0x01, 0x6c,0x16,0x01, 0x66,0x10,0x01,
  0x5f,0x0a,0x01, 0x58,0x05,0x02
};

static void set_palette(fb_t* fb) {
  int N;
  int increment;
  switch (fb->mode) {
    case CMODE_PAL8:
      N = 256;
      increment = 1;
      break;
    case CMODE_PAL4:
      N = 16;
      increment = 9;
      break;
    case CMODE_PAL2:
      N = 4;
      increment = 63;
      break;
    case CMODE_PAL1:
    default:
      N = 2;
      increment = 1;
      break;
  }

  fb->palette[0] = 0xff000000;
  for (int k = 1; k < N; ++k) {
    const int idx = ((k - 1) & 127) * (increment * 3);
    const uint32_t r = (uint32_t)PAL_128_RGB[idx];
    const uint32_t g = (uint32_t)PAL_128_RGB[idx + 1];
    const uint32_t b = (uint32_t)PAL_128_RGB[idx + 2];
    fb->palette[k] = 0xff000000 | (b << 16) | (g << 8) | r;
  }
}


//--------------------------------------------------------------------------------------------------
// Math helpers.
//--------------------------------------------------------------------------------------------------

static float sqr(const float x) {
  return x * x;
}


//--------------------------------------------------------------------------------------------------
// Mandelbrot implementation
//--------------------------------------------------------------------------------------------------

static float get_zoom(int frame_no) {
  frame_no &= 255;
  if (frame_no >= 128) {
    frame_no = 256 - frame_no;
  }
  return fast_pow(0.96f, (float)frame_no);
}

static int iterate(const float re_c, const float im_c) {
  const cplx_t c = {re_c, im_c};

  // Optimization: Skip computations inside M1 and M2. See:
  // - http://iquilezles.org/www/articles/mset_1bulb/mset1bulb.htm
  // - http://iquilezles.org/www/articles/mset_2bulb/mset2bulb.htm
  {
    float c2 = sqr(re_c) + sqr(im_c);
    if ((256.0f * c2 * c2 - 96.0f * c2 + 32.0f * c.re - 3.0f) < 0.0f)
      return 0;
    if ((16.0f * (c2 + 2.0f * c.re + 1.0f) - 1.0f) < 0.0f)
      return 0;
  }

  cplx_t z = {0.0f, 0.0f};
  float zrsqr = sqr(z.re);
  float zisqr = sqr(z.im);

  int n;
  for (n = 1; n < MAX_ITERATIONS && (zrsqr + zisqr) <= 4.0f; ++n) {
    z.im = sqr(z.re + z.im) - zrsqr - zisqr;
    z.im += c.im;
    z.re = zrsqr - zisqr + c.re;
    zrsqr = sqr(z.re);
    zisqr = sqr(z.im);
  }

  return n >= MAX_ITERATIONS ? 0 : n;
}


//--------------------------------------------------------------------------------------------------
// Public API.
//--------------------------------------------------------------------------------------------------

static fb_t* s_fb;

void mandelbrot_init(void) {
  if (s_fb == NULL) {
    for (int i = 0; i < NUM_VMODES; ++i) {
      const vmode_t* vm = &VMODES[i];
      s_fb = fb_create(vm->width, vm->height, vm->mode);
      if (s_fb != NULL) {
        set_palette(s_fb);
        break;
      }
    }
  }
}

void mandelbrot_deinit(void) {
  if (s_fb != NULL) {
    fb_destroy(s_fb);
    s_fb = NULL;
  }
}

void mandelbrot(int frame_no) {
  if (s_fb == NULL) {
    return;
  }

  fb_show(s_fb, LAYER_1);

  float step = get_zoom(frame_no) * MAX_SIZE / (float)s_fb->width;

  for (int k = 0; k < s_fb->height; ++k) {
    // We start at the middle and alternatingly expand up and down.
    int dy = (k + 1) >> 1;
    if ((k & 1) == 1) {
      dy = -dy;
    }
    const int y = s_fb->height / 2 + dy;
    const float im_c = CENTER.im + step * (float)(y - s_fb->height / 2);

    // Draw one row (left to right).
    uint8_t* pixels = &((uint8_t*)s_fb->pixels)[y * s_fb->stride];
    uint8_t pix = 0;
    for (int x = 0; x < s_fb->width; ++x) {
      const float re_c = CENTER.re + step * (float)(x - s_fb->width / 2);

      // Run the Mandelbrot iterations for this C.
      const int n = iterate(re_c, im_c);

      // Convert the iteration count to a color.
      if (s_fb->mode == CMODE_PAL8) {
        *pixels = (uint8_t)n;
        ++pixels;
      } else if (s_fb->mode == CMODE_PAL4) {
        const int n2 = n ? ((n % 15) + 1) : 0;
        pix = pix | ((uint8_t)n2) << ((x & 1) * 4);
        if ((x & 1) == 1) {
          *pixels = pix;
          ++pixels;
          pix = 0;
        }
      } else if (s_fb->mode == CMODE_PAL2) {
        const int n2 = n ? ((n % 3) + 1) : 0;
        pix = pix | ((uint8_t)n2) << ((x & 3) * 2);
        if ((x & 3) == 3) {
          *pixels = pix;
          ++pixels;
          pix = 0;
        }
      } else if (s_fb->mode == CMODE_PAL1) {
        pix = pix | ((uint8_t)n & 1) << (x & 7);
        if ((x & 7) == 7) {
          *pixels = pix;
          ++pixels;
          pix = 0;
        }
      }
    }
  }
}

