// renderer.c
#include "renderer.h"
#include <stdlib.h>

static void destroyrenderer(renderer self) {
    if (self) {
        free(self->name);
        free(self->data);
        free(self);
    }
}

const Irenderer renderer = {
    .destroy = destroyrenderer
};
