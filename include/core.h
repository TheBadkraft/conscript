// core.h
#ifndef CORE_H
#define CORE_H

#include <stdint.h>
#include <stdio.h>
#include <sigcore.h>

typedef struct renderer_s* renderer;

typedef struct IRenderer {
    renderer (*init)(FILE*);				//	initialize a renderer with output stream (e.g., file, buffer)
    void (*add)(renderer, string);	//	add a log message
    void (*render)(renderer);				//	output all messages to stream
    void (*free)(renderer);					//	free renderer and logs
} IRenderer;

extern const IRenderer Renderer;
#endif // CORE_H
