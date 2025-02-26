// renderer.h
#ifndef RENDERER_H
#define RENDERER_H

#include "core.h"

struct renderer_s {
    string name;
    object data;
};

typedef struct renderer_s* renderer;

typedef struct Irenderer {
    void (*destroy)(renderer self);
} Irenderer;

extern const Irenderer renderer;

#endif // RENDERER_H
