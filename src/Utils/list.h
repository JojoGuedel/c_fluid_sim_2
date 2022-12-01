#ifndef H_LIST
#define H_LIST

#include <stdbool.h>

typedef struct {
    void** data;

    int count;
    int size;

    unsigned int max_capacity;
} List;

List* list_create(int max_capacity);
void list_destory(List* list);

void* list_get(List* list, int index);
bool list_set(List* list, int index, void* data);

bool list_add(List* list, void* data);
bool list_remove(List* list, int index);

#endif