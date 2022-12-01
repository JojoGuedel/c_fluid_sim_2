#include <math.h>
#include <stdbool.h>
#include <stdlib.h>

#include "Pixa/core.h"

#include "Utils/vector.h"

#include "cell.h"
#include "chunk.h"
#include "global.h"
#include "state.h"

static Cell empty_cell = (Cell){};
Cell* CELL_EMPTY = &empty_cell;

Cell cell_create(Vector pos, Chunk* chunk) {
    return (Cell) {
        .state =  STATE_INAC,
        .chunk = chunk,
        .call_count = 0,

        .pos = pos,
        .vel = (Vector){0, 0}, .vel0 = (Vector){0, 0},
        .den = 0, .den0 = 0,
        .div = 0, .div0 = 0,
    };
}

Cell* cell_get(Vector pos, bool force) {
    pos = vector_floor(pos);

    for (int i = 0; i < chunks->count; i++) {
        Chunk* chunk = list_get(chunks, i);

        if (chunk_contains(chunk, pos))
            return chunk_cell_get(chunk, pos, force);
    }

    if (!force || chunks->count >= LIMIT_CHUNK)
        return CELL_EMPTY;
    
    Chunk* chunk = chunk_create(pos);
    list_add(chunks, chunk);
    return chunk_cell_get(chunk, pos, force);
}

Cell* cell_call(Cell* cell) {
    cell->call_count++;
    return cell;
}

void cell_set_state(Cell* cell) {
    if (cell->call_count <= 0)
        cell->state = STATE_INAC;
    else
        cell->state = STATE_PASS;

    if (vector_len(cell->vel) > MIN_VEL)
        cell->state = max(cell->state, STATE_ACTI);

    if (cell->den > MIN_DEN)
        cell->state = max(cell->state, STATE_ACTI);
}

#define CELL_ASIGN_NEIGHBORS\
    Cell* R = chunk_cell_get(cell->chunk, (Vector){cell->pos.x + 1, cell->pos.y    }, false);\
    Cell* L = chunk_cell_get(cell->chunk, (Vector){cell->pos.x - 1, cell->pos.y    }, false);\
    Cell* T = chunk_cell_get(cell->chunk, (Vector){cell->pos.x    , cell->pos.y + 1}, false);\
    Cell* B = chunk_cell_get(cell->chunk, (Vector){cell->pos.x    , cell->pos.y - 1}, false)

#define NULL_CHECK(check_val, non_null, null) (check_val == NULL? null : non_null)

void cell_update_neighbors(Cell* cell, void(*cell_stage)(Cell*, int, int), int solve_dep, int fill_dep) {
    cell_stage(cell_call(chunk_cell_get(cell->chunk, (Vector){cell->pos.x + 1, cell->pos.y    }, true)), solve_dep, ++fill_dep);
    cell_stage(cell_call(chunk_cell_get(cell->chunk, (Vector){cell->pos.x - 1, cell->pos.y    }, true)), solve_dep, ++fill_dep);
    cell_stage(cell_call(chunk_cell_get(cell->chunk, (Vector){cell->pos.x    , cell->pos.y + 1}, true)), solve_dep, ++fill_dep);
    cell_stage(cell_call(chunk_cell_get(cell->chunk, (Vector){cell->pos.x    , cell->pos.y - 1}, true)), solve_dep, ++fill_dep);
}

void cell_stage0(Cell* cell) {
    cell->call_count = 0;
    
    cell->solve_dep1 = 0;
    cell->solve_dep2 = 0;
    cell->solve_dep4 = 0;
    cell->solve_dep5 = 0;

    cell->vel0 = cell->vel;
    cell->den0 = cell->den;
}

void cell_stage1(Cell* cell, int solve_dep, int fill_dep) {
    if (cell->chunk == NULL)
        return;

    // only update necessary
    if (solve_dep < cell->solve_dep1 || fill_dep >= LIMIT_FILL)
        return;

    cell->solve_dep1++;

    // update neighbors if cell is active
    if (cell->state == STATE_ACTI)
        cell_update_neighbors(cell, cell_stage1, solve_dep, fill_dep);

    float a = delta_time * VISC;
    float c = 1 + 4 * a;

    // get the values of the neighbors
    CELL_ASIGN_NEIGHBORS;

    // set vel0
    cell->vel0.x = (cell->vel.x + a * (L->vel0.x + R->vel0.x + B->vel0.x + T->vel0.x)) / c;
    cell->vel0.y = (cell->vel.y + a * (L->vel0.y + R->vel0.y + B->vel0.y + T->vel0.y)) / c;

    // udpate cellState
    cell_set_state(cell);
}

void cell_stage2(Cell* cell, int solve_dep, int fill_dep) {
    if (cell->chunk == NULL)
        return;

    // only update necessary
    if (solve_dep < cell->solve_dep2 || fill_dep >= LIMIT_FILL)
      return;

    cell->solve_dep2++;

    // get the values of the neighbors
    CELL_ASIGN_NEIGHBORS;

    cell->div0 = L->vel0.x - R->vel0.x + B->vel0.x - T->vel0.x;
    cell->div = 0;

    // update neighbors if cell is active
    if (cell->state == STATE_ACTI)
        cell_update_neighbors(cell, cell_stage2, solve_dep, fill_dep);

    float a = 1;
    float c = 4;

    cell->div = (cell->div0 + a * (L->div + R->div +B->div + T->div)) / c;

    // set vel
    cell->vel.x = cell->vel0.x - (0.5f * R->div - L->div);
    cell->vel.y = cell->vel0.y - (0.5f * T->div - B->div);

    // udpate cellState
    cell_set_state(cell);
}

void cell_stage3(Cell* cell) {
    if (cell->chunk == NULL)
        return;

    // calculate the distance traveled
    Vector ds = vector_mlt(cell->vel, delta_time);

    // calculate the new position
    Vector target = vector_sub(cell->pos, ds);

    // calculate the positions
    int L = floor(target.x);
    int R = L + 1;
    int B = floor(target.y);
    int T = B + 1;

    // calculate the offsets to use them as weights
    float weightR = target.x - L;
    float weightL = 1.0f - weightR;
    float weightT = target.y - B;
    float weightB = 1.0f - weightT;

    // get the cells
    Cell* LT = chunk_cell_get(cell->chunk, (Vector){L, T}, false);
    Cell* LB = chunk_cell_get(cell->chunk, (Vector){L, B}, false);
    Cell* RT = chunk_cell_get(cell->chunk, (Vector){R, T}, false);
    Cell* RB = chunk_cell_get(cell->chunk, (Vector){R, B}, false);

    // modify vel0 with subpixel percision
    // this is done with the offset that was calculated before by using it as a weight

    cell->vel0.x =
        weightL * (weightT * LT->vel.x + weightB * LB->vel.x) +
        weightR * (weightT * RT->vel.x + weightB * RB->vel.x);

    cell->vel0.y =
        weightL * (weightT * LT->vel.y + weightB * LB->vel.y) +
        weightR * (weightT * RT->vel.y + weightB * RB->vel.y);

    // udpate cellState
    cell_set_state(cell);
}

void cell_stage4(Cell* cell, int solve_dep, int fill_dep) {
    if (cell->chunk == NULL)
        return;

    // only update necessary
    if (solve_dep < cell->solve_dep4 || fill_dep >= LIMIT_FILL)
      return;

    cell->solve_dep4++;

    // get the values of the neighbors
    CELL_ASIGN_NEIGHBORS;

    cell->div0 = L->vel0.x - R->vel0.x + B->vel0.x - T->vel0.x;
    cell->div = 0;

    // update neighbors if cell is active
    if (cell->state == STATE_ACTI)
        cell_update_neighbors(cell, cell_stage4, solve_dep, fill_dep);

    float a = 1;
    float c = 4;

    cell->div = (cell->div0 + a * (L->div + R->div + B->div + T->div)) / c;

    // set vel
    cell->vel.x = cell->vel0.x - (0.5f * (R->div - L->div));
    cell->vel.y = cell->vel0.y - (0.5f * (T->div - B->div));

    // udpate cellState
    cell_set_state(cell);
}

void cell_stage5(Cell* cell, int solve_dep, int fill_dep) {
    if (cell->chunk == NULL)
        return;
        
    // only update necessary
    if (solve_dep < cell->solve_dep5 || fill_dep >= LIMIT_FILL)
        return;

    cell->solve_dep5++;

    // update neighbors if cell is active
    if (cell->state == STATE_ACTI)
        cell_update_neighbors(cell, cell_stage1, solve_dep, fill_dep);

    float a = delta_time * DIFF;
    float c = 1 + 4 * a;

    // get the values of the neighbors
    CELL_ASIGN_NEIGHBORS;

    // set den0
    cell->den0 = (cell->den + a * (L->den0 + R->den0 + B->den0 + T->den0)) / c;

    // udpate cellState
    cell_set_state(cell);
}

void cell_stage6(Cell* cell) {
    if (cell->chunk == NULL)
        return;
        
    // calculate the distance traveled
    Vector ds = vector_mlt(cell->vel, delta_time);

    // calculate the new position
    Vector target = vector_sub(cell->pos, ds);

    // calculate the positions
    int L = floor(target.x);
    int R = L + 1;
    int B = floor(target.y);
    int T = B + 1;

    // calculate the offsets to use them as weights
    float weightR = target.x - L;
    float weightL = 1.0f - weightR;
    float weightT = target.y - B;
    float weightB = 1.0f - weightT;

    // get the cells
    Cell* LT = chunk_cell_get(cell->chunk, (Vector){L, T}, false);
    Cell* LB = chunk_cell_get(cell->chunk, (Vector){L, B}, false);
    Cell* RT = chunk_cell_get(cell->chunk, (Vector){R, T}, false);
    Cell* RB = chunk_cell_get(cell->chunk, (Vector){R, B}, false);

    // modify den with subpixel percision
    // this is done with the offset that was calculated before by using it as a weight
    cell->den =
        weightL * (weightT * LT->den0 + weightB * LB->den0) +
        weightR * (weightT * RT->den0 + weightB * RB->den0);

    // udpate cellState
    cell_set_state(cell);
}