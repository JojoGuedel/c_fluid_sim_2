#include <math.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>

#include "Utils/vector.h"

#include "cell.h"
#include "chunk.h"
#include "global.h"

int IX(Vector pos) {
    return (int)(pos.x + pos.y * SIZE_CHUNK);
}

Chunk* chunk_create(Vector pos) {
    Chunk* chunk = malloc(sizeof(Chunk));

    chunk->pos.x = floor(pos.x / (float)SIZE_CHUNK) * SIZE_CHUNK;
    chunk->pos.y = floor(pos.y / (float)SIZE_CHUNK) * SIZE_CHUNK;

    chunk->state = STATE_INAC;
    chunk->cells = malloc(sizeof(Cell) * SIZE_CHUNK * SIZE_CHUNK);

    if (chunk->cells == NULL)
        exit(-1);

    for(int y = 0; y < SIZE_CHUNK; y++)
        for(int x = 0; x < SIZE_CHUNK; x++)
            chunk->cells[IX((Vector){x, y})] = cell_create(vector_add(chunk->pos, (Vector){x, y}), chunk); 
    
    return chunk;
}

void chunk_destroy(Chunk* chunk) {
    free(chunk->cells);
    free(chunk);
}

bool chunk_contains(Chunk* chunk, Vector pos) {
    if (pos.x < chunk->pos.x || pos.x >= chunk->pos.x + SIZE_CHUNK)
      return false;
    if (pos.y < chunk->pos.y || pos.y >= chunk->pos.y + SIZE_CHUNK)
      return false;

    return true;
}

Cell* chunk_cell_get(Chunk* chunk, Vector pos, bool force) {
    if (chunk_contains(chunk, pos))
        return &chunk->cells[IX(vector_sub(pos, chunk->pos))];

    return cell_get(pos, force);
}

void chunk_set_state(Chunk* chunk) {
    chunk->state = STATE_INAC;

    for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++) {
        chunk->state = max(chunk->state, chunk->cells[i].state);

        if (chunk->state == STATE_ACTI)
            break;
    }
}

void chunk_stage0(Chunk* chunk) {
    for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++)
        cell_stage0(&chunk->cells[i]);
}

void chunk_stage1(Chunk* chunk) {
    for (int p = 0; p < LIMIT_SOLVE; p++)
        for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++)
            cell_stage1(&chunk->cells[i], p, 0);
}

void chunk_stage2(Chunk* chunk) {
    for (int p = 0; p < LIMIT_SOLVE; p++)
        for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++)
            cell_stage2(&chunk->cells[i], p, 0);
}

void chunk_stage3(Chunk* chunk) {
    for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++)
        cell_stage3(&chunk->cells[i]);
}

void chunk_stage4(Chunk* chunk) {
    for (int p = 0; p < LIMIT_SOLVE; p++)
        for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++)
            cell_stage4(&chunk->cells[i], p, 0);
}

void chunk_stage5(Chunk* chunk) {
    for (int p = 0; p < LIMIT_SOLVE; p++)
        for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++)
            cell_stage5(&chunk->cells[i], p, 0);
}

void chunk_stage6(Chunk* chunk) {
    for (int i = 0; i < SIZE_CHUNK * SIZE_CHUNK; i++)
        cell_stage6(&chunk->cells[i]);
}
