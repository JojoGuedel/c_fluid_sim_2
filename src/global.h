#ifndef GLOBAL_H
#define GLOBAL_H

#include "Utils/list.h"
#include "Utils/vector.h"

#include "state.h"

extern const int SIZE_CHUNK;

extern const int LIMIT_SOLVE;
extern const int LIMIT_CHUNK;
extern const int LIMIT_FILL;

extern const float MIN_VEL;
extern const float MIN_DEN;

extern const float DIFF;
extern const float VISC;

extern const float SCALE_VEL;
extern const float SCALE_DEN;

extern List* chunks;

extern float p_mouse_x;
extern float p_mouse_y;

#endif