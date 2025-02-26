#!/bin/bash

# Function to convert CamelCase to snake_case
to_snake_case() {
	local name="$1"
	echo "$name" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]'
}

# Function to convert CamelCase to UPPER_SNAKE_CASE
to_upper_snake_case() {
	local name="$1"
	echo "$name" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//' | tr '[:lower:]' '[:upper:]'
}

# Create a new header file
add_header() {
	local header_name="$1"
	local include_dir="$2/include"
	local file_name=$(to_snake_case "$header_name")
	local guard_name=$(to_upper_snake_case "$header_name")_H

	mkdir -p "$include_dir"
	cat <<EOL > "$include_dir/$file_name.h"
// $file_name.h
#ifndef $guard_name
#define $guard_name

#include "core.h"

#endif // $guard_name
EOL
	echo "Created $include_dir/$file_name.h"
}

# Create a new source file (and its header)
add_source() {
	local source_name="$1"
	local source_type="$2"
	local project_dir="$3"
	local src_dir="$project_dir/src"
	local include_dir="$project_dir/include"
	local file_name=$(to_snake_case "$source_name")
	local guard_name=$(to_upper_snake_case "$source_name")_H

	mkdir -p "$include_dir"
	if [ "$source_type" == "struct" ]; then
		cat <<EOL > "$include_dir/$file_name.h"
// $file_name.h
#ifndef $guard_name
#define $guard_name

#include "core.h"

struct ${file_name}_s {
	string name;
	object data;
};

typedef struct ${file_name}_s* $source_name;

typedef struct I$source_name {
	void (*destroy)($source_name self);
} I$source_name;

extern const I$source_name $source_name;

#endif // $guard_name
EOL
	else
		cat <<EOL > "$include_dir/$file_name.h"
// $file_name.h
#ifndef $guard_name
#define $guard_name

#include "core.h"

typedef struct I$source_name {
	void (*doSomething)(int value);
} I$source_name;

extern const I$source_name $source_name;

#endif // $guard_name
EOL
	fi
	echo "Created $include_dir/$file_name.h"

	mkdir -p "$src_dir"
	if [ "$source_type" == "struct" ]; then
		cat <<EOL > "$src_dir/$file_name.c"
// $file_name.c
#include "$file_name.h"
#include <stdlib.h>

static void destroy${source_name}($source_name self) {
	if (self) {
		free(self->name);
		free(self->data);
		free(self);
	}
}

const I$source_name $source_name = {
	.destroy = destroy${source_name}
};
EOL
	else
		cat <<EOL > "$src_dir/$file_name.c"
// $file_name.c
#include "$file_name.h"

static void doSomething${source_name}(int value) {
	// Add implementation here
}

const I$source_name $source_name = {
	.doSomething = doSomething${source_name}
};
EOL
	fi
	echo "Created $src_dir/$file_name.c"
}

# Create a new unit test file
add_unit() {
	local unit_name="$1"
	local project_dir="$2"
	local test_dir="$project_dir/test"
	local file_name=$(to_snake_case "$unit_name")

	mkdir -p "$test_dir"
	cat <<EOL > "$test_dir/test_$file_name.c"
// test_$file_name.c
#include "sigtest.h"
#include "$file_name.h"

void ${file_name}_test(void) {
	// Assert.isTrue(condition, "fail message");
	// Assert.isFalse(condition, "fail message");
	// Assert.areEqual(obj1, obj2, INT, "fail message");
	// Assert.areEqual(obj1, obj2, PTR, "fail message");
	// Assert.areEqual(obj1, obj2, STRING, "fail message");
}

// Register test cases
__attribute__((constructor)) void init_sigtest_tests(void) {
	register_test("${file_name}_test", ${file_name}_test);
}
EOL
	echo "Created $test_dir/test_$file_name.c"
}
