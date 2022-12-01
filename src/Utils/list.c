#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "list.h"

List* list_create(int max_capacity) {
    List* list = malloc(sizeof(List));

    list->data = NULL;

    list->count = 0;
    list->size = 0;

    list->max_capacity = max_capacity;

    return list;
}

void list_destory(List* list) {
    if (list->data != NULL)
        free(list->data);
    
    free(list);
}

void* list_get(List* list, int index) {
    if (index < 0 || index >= list->count)
        return NULL;
    
    return list->data[index];
}

bool list_set(List* list, int index, void* data) {
    if (index < 0 || index >= list->count)
        return false;
    
    list->data[index] = data;
    return true;
}

bool list_add(List* list, void* data) {
    if (list->size == 0) {
        if (list->max_capacity <= list->size)
            return false;

        list->data = malloc(sizeof(void*));
        list->size++;
    }

    // check if size needs to be increased
    if (list->size <= list->count) {
        if (list->max_capacity <= list->size)
            return false;

        int new_size = min(list->size * 2, list->max_capacity);

        void** temp = malloc(sizeof(void*) * new_size);
        memcpy(temp, list->data, sizeof(void*) * list->count);
        free(list->data);

        list->data = temp;
        list->size = new_size;
    }

    list->data[list->count++] = data;
    return true;
}

bool list_remove(List* list, int index) {
    if (index < 0 || index >= list->count)
        return false;

    memmove(list->data + index, list->data + index + 1, list->count - (index + 1));

    list->count--;

    // deallocate if necessary
    // if (list->count * 2 < list->size) {
    //     int new_size = list->size / 2;

    //     void** temp = malloc(sizeof(void*) * new_size);
    //     memcpy(temp, list->data, sizeof(void*) * list->count);
    //     free(list->data);

    //     list->data = temp;
    //     list->size = new_size;
    // }

    return true;
}