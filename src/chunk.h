#ifndef CHUNK_H
#define CHUNK_H

#include <stdbool.h>

#include "Utils/vector.h"

#include "global.h"
#include "state.h"

typedef struct Cell Cell;

struct Chunk {
    State state;
    Cell* cells;

    Vector pos;
};

typedef struct Chunk Chunk;

Chunk* chunk_create(Vector pos);

bool chunk_contains(Chunk* chunk, Vector pos);
Cell* chunk_cell_get(Chunk* chunk, Vector pos, bool force);

void chunk_set_state(Chunk* chunk);

void chunk_stage0(Chunk* chunk);
void chunk_stage1(Chunk* chunk);
void chunk_stage2(Chunk* chunk);
void chunk_stage3(Chunk* chunk);
void chunk_stage4(Chunk* chunk);
void chunk_stage5(Chunk* chunk);
void chunk_stage6(Chunk* chunk);
void stage7(Chunk* chunk);

#endif