#ifndef CELL_H
#define CELL_H

#include <stdbool.h>

#include "Utils/vector.h"

#include "global.h"

typedef struct Chunk Chunk;

struct Cell {
    State state;
    Chunk* chunk;
    int call_count;

    Vector pos;
    Vector vel, vel0;
    float den, den0;
    float div, div0;

    int solve_dep1;
    int solve_dep2;
    int solve_dep4;
    int solve_dep5;
};

typedef struct Cell Cell;

Cell cell_create(Vector pos, Chunk* chunk);

Cell* cell_get(Vector pos, bool force);

void cell_stage0(Cell* cell);
void cell_stage1(Cell* cell, int solve_dep, int fill_dep);
void cell_stage2(Cell* cell, int solve_dep, int fill_dep);
void cell_stage3(Cell* cell);
void cell_stage4(Cell* cell, int solve_dep, int fill_dep);
void cell_stage5(Cell* cell, int solve_dep, int fill_dep);
void cell_stage6(Cell* cell);

extern Cell* CELL_EMPTY;

#endif