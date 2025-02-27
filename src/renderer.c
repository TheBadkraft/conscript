// renderer.c
#include "core.h"
#include <stdlib.h>

const int DEFAULT_BUFFER_SIZE = 10;
const int DEFAULT_BUFFER_CAP = 50;

struct renderer_s {
    list logs;
    FILE* stream;
};

static renderer initRenderer(FILE* stream) {
	renderer r = Mem.alloc(sizeof(struct renderer_s));
	if (r) {
		r->logs = List.new(DEFAULT_BUFFER_SIZE);
		r->stream = stream ? stream : stdout;		//	fallback to stdout if NULL
	}
	
	return r;
}

static void addLog(renderer r, string msg) {
	if (r && r->logs) {
		List.add(r->logs, (object)msg);
	}
}

static void render(renderer r) {
	if (!r || !r->logs || !r->stream) return;
	iterator it = List.iterator(r->logs);
	
	while (Iterator.hasNext(it)) {
		fprintf(r->stream, "%s\n", (string)Iterator.next(it));
	}
	Iterator.free(it);
}

static void freeRenderer(renderer r) {
	if (r) {
		List.destroy(r->logs);
		Mem.free(r);
	}
}

const IRenderer Renderer = {
	.init = initRenderer,
	.add = addLog,
	.render = render,
	.free = freeRenderer
};

