// test_renderer.c
#include <sigtest.h>
#include "core.h"

    // Assert.isTrue(condition, "fail message");
    // Assert.isFalse(condition, "fail message");
    // Assert.areEqual(obj1, obj2, INT, "fail message");
    // Assert.areEqual(obj1, obj2, PTR, "fail message");
    // Assert.areEqual(obj1, obj2, STRING, "fail message");


void renderer_init(void) {
		char buffer[256] = {0};
		FILE* stream = fmemopen(buffer, sizeof(buffer), "w+");
		Assert.isTrue(stream != NULL, "failed to create memory stream");
		
		renderer r = Renderer.init(stream);
		Assert.isTrue(r != NULL, "renderer failed to initialize");
		
		Renderer.free(r);
		fclose(stream);
}

// Register test cases
__attribute__((constructor)) void init_sigtest_tests(void) {
    register_test("renderer_init", renderer_init);
}
