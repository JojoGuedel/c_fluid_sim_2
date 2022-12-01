#include <stdbool.h>
#include <stdio.h>

#include "Pixa/core.h"
#include "Pixa/color.h"
#include "Pixa/graphics.h"
#include "Pixa/input.h"
#include "Pixa/scene.h"

#include "Utils/list.h"
#include "Utils/vector.h"

#include "cell.h"
#include "chunk.h"
#include "global.h"

float p_mouse_x;
float p_mouse_y;

List* chunks;

bool draging = false;

bool inserting = false;

bool zoom_in = false;
bool zoom_out = false;

float scale = 1.0f / 10.0f;
Vector offset = (Vector){0, 0};

Vector to_world(Vector vec) {
    return vector_mlt(vector_add(vec, offset), scale);
}

Vector to_screen(Vector vec) {
    return vector_sub(vector_div(vec, scale), offset);
}

void add_density(Vector pos, float amount) {
    cell_get(pos, true)->den += amount;
}

void add_velocity(Vector pos, Vector vel) {
    Cell* cell = cell_get(pos, true);
    cell->vel = vector_add(cell->vel, vel);
}

void input() {
    if (draging) {
        offset.x += p_mouse_x - mouse_x;
        offset.y += p_mouse_y - mouse_y;
    }

    if (zoom_in || zoom_out) {
        Vector pos0 = (Vector){mouse_x, mouse_y};
        Vector pos1 = to_world(pos0);
        scale *= 1.0f + ((float)zoom_out - (float)zoom_in) / 100.0f;
        Vector pos2 = to_screen(pos1);
        offset = vector_add(offset, vector_sub(pos2, pos0));
    }

    if (inserting) {
        float vx = (mouse_x - p_mouse_x) * scale / delta_time;
        float vy = (mouse_y - p_mouse_y) * scale / delta_time;

        add_density(to_world((Vector){mouse_x, mouse_y}), 1000 * SCALE_DEN);
        add_velocity(to_world((Vector){mouse_x, mouse_y}), (Vector){vx, vy});
    }
}

void on_create() {
    chunks = list_create(-1);
}

void on_update() {
    clear();

    // update all the chunks
    for (int i = 0; i < chunks->count; i++)
        chunk_stage0(list_get(chunks, i));
    for (int i = 0; i < chunks->count; i++)
        chunk_stage1(list_get(chunks, i));
    for (int i = 0; i < chunks->count; i++)
        chunk_stage2(list_get(chunks, i));
    for (int i = 0; i < chunks->count; i++)
        chunk_stage3(list_get(chunks, i));
    for (int i = 0; i < chunks->count; i++)
        chunk_stage4(list_get(chunks, i));
    for (int i = 0; i < chunks->count; i++)
        chunk_stage5(list_get(chunks, i));
    for (int i = 0; i < chunks->count; i++)
        chunk_stage6(list_get(chunks, i));

    // remove inactive chunks
    for (int i = 0; i < chunks->count; i++) {
        Chunk* chunk = list_get(chunks, i);
        chunk_set_state(chunk);

        if (chunk->state == STATE_INAC)
            list_remove(chunks, i--);
    }

    for (int i = 0; i < chunks->count; i++) {
        Chunk* chunk = list_get(chunks, i);

        for (int j = 0; j < SIZE_CHUNK * SIZE_CHUNK; j++) {
            Cell cell = chunk->cells[j];
            Vector s_pos = to_screen(cell.pos);

            color((Color){255, 255, 255, cell.den});
            fill_rect((int)s_pos.x, (int)s_pos.y, (int)(1.0f / scale), (int)(1.0f / scale));

            switch (cell.state) {
                case STATE_INAC:
                    // color(COLOR_BLUE);
                    break;
                
                case STATE_PASS:
                    // color(COLOR_CYAN);
                    break;

                case STATE_ACTI:
                    // color(COLOR_GREEN);
                    break;
            }
            color(COLOR_WHITE);
            draw_line((int)s_pos.x, (int)s_pos.y, (int)(s_pos.x + cell.vel.x / scale * SCALE_VEL), (int)(s_pos.y + cell.vel.y / scale * SCALE_VEL));
        }
    }

    input();

    Vector pos = (Vector){0, 0};
    Vector sPos = to_screen(pos);
    draw_rect(sPos.x, sPos.y, 100 / scale, 40 / scale);

    p_mouse_x = mouse_x;
    p_mouse_y = mouse_y;

    printf("%i\n", chunks->count);
}

void on_destory() {
    // clean up
    list_destory(chunks);
}

// input
void keyboard_cb(int key, int action, int flags) {
    if (action == KEY_PRESS) {
        switch (key) {
        case KEY_Q:
            zoom_out = true; 
            break;

        case KEY_E:
            zoom_in = true; 
            break;
        }
    }

    if (action == KEY_RELEASE) {
        switch (key) {
        case KEY_Q:
            zoom_out = false; 
            break;

        case KEY_E:
            zoom_in = false; 
            break;
        }
    }
}

void mouse_cb(int button, int action, int flags) {
    if (action == BUTTON_PRESS) {
        switch (button) {
        case MOUSE_BUTTON_1:
            inserting = true;
            break;

        case MOUSE_BUTTON_3:
            draging = true; 
            break;
        }
    }

    if (action == BUTTON_RELEASE) {
        switch (button) {
        case MOUSE_BUTTON_1:
            inserting = false;
            break;
        case MOUSE_BUTTON_3:
            draging = false; 
            break;
        }
    }
}

int main() {
    engine_create(500, 500, 2, 2);
    engine_set_user_input(keyboard_cb, mouse_cb);

    scene_create(on_create, on_update, on_destory);
    clear_color(COLOR_VERY_DARK_GREY);

    engine_start();
}