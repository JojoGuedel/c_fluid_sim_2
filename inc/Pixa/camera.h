#ifndef PIXA_CAMERA_H
#define PIXA_CAMERA_H

#include "Pixa/layer.h"
#include "Pixa/sprite.h"

typedef struct {
    int pos_x;
    int pos_y;
    int pos_z;

    int rot_x;
    int rot_y;
    int rot_z;

    Layer layer_target;
} Camera;

Camera* camera_create(Layer* layer_target);
void camera_destroy(Camera* camera);

void camera_bind(Camera* camera);

#endif