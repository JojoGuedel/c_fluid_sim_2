#ifndef VECTOR_H
#define VECTOR_H

typedef struct {
    float x;
    float y;
} Vector;

Vector vector_add(Vector a, Vector b);
Vector vector_sub(Vector a, Vector b);
Vector vector_mlt(Vector vec, float a);
Vector vector_div(Vector vec, float a);

float vector_dot(Vector a, Vector b);
float vector_len(Vector vec);

Vector vector_floor(Vector vec);

#endif