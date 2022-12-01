#include <math.h>

#include "vector.h"

Vector vector_add(Vector a, Vector b) {
    return (Vector){a.x + b.x, a.y + b.y};
}

Vector vector_sub(Vector a, Vector b) {
    return (Vector){a.x - b.x, a.y - b.y};
}

Vector vector_mlt(Vector vec, float a) {
    return (Vector){vec.x * a, vec.y * a};
}

Vector vector_div(Vector vec, float a) {
    return (Vector){vec.x / a, vec.y / a};
}

float vector_dot(Vector a, Vector b) {
    return a.x * b.x + a.y * b.y;
}

float vector_len(Vector vec) {
    return sqrt(vec.x * vec.x + vec.y * vec.y);
}

Vector vector_floor(Vector vec) {
    return (Vector){floor(vec.x), floor(vec.y)};
}
