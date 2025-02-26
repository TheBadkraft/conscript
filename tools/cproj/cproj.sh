#!/bin/bash

# Set version
VERSION="1.0.0"

# Source ctemplates.sh
if [ -f "$(dirname "$0")/ctemplates.sh" ]; then
  source "$(dirname "$0")/ctemplates.sh"
else
  echo "Error: ctemplates.sh not found in $(dirname "$0")"
  exit 1
fi

# Help switch
if [[ "$1" == "-h" && -z "$2" ]]; then
  echo "Usage: $0 [-i <header_name>] [-c <type> <source_name>] [-u <unit_name>] [-l] [<project_name>]"
  echo "Creates a minimal C project structure with a Makefile."
  echo ""
  echo "Arguments:"
  echo "  <project_name>  Name of the project (optional with -i/-c/-u, required otherwise)."
  echo ""
  echo "Options:"
  echo "  -i <header_name>	  Create a new header file."
  echo "  -c <type> <source_name> Create a new source file (and its header)."
  echo "						Types: 'struct' (with struct), 'plain' (no struct)."
  echo "  -u <unit_name>		Create a new unit test file."
  echo "  -l				   Create a library project."
  echo "  -h				   Display this help message (without args)."
  echo "  -v				   Display the script version."
  exit 0
fi

# Version switch
if [[ "$1" == "-v" ]]; then
  echo "cproj.sh version $VERSION"
  exit 0
fi

# Parse options
NEW_HEADER=""
NEW_SOURCE=""
SOURCE_TYPE=""
NEW_UNIT=""
IS_LIBRARY=""
if [[ "$1" == "-i" ]]; then
  shift
  NEW_HEADER="$1"
  shift
elif [[ "$1" == "-c" ]]; then
  shift
  SOURCE_TYPE="$1"
  shift
  NEW_SOURCE="$1"
  shift
elif [[ "$1" == "-u" ]]; then
  shift
  NEW_UNIT="$1"
  shift
elif [[ "$1" == "-l" ]]; then
  shift
  IS_LIBRARY="yes"
fi

# Validate source type
if [[ "$SOURCE_TYPE" != "struct" && "$SOURCE_TYPE" != "plain" && -n "$NEW_SOURCE" ]]; then
  echo "Error: Invalid source type '$SOURCE_TYPE'. Use 'struct' or 'plain'."
  exit 1
fi

# Determine project directory and validate
if [ -n "$1" ]; then
  PROJECT_NAME="$1"
  PROJECT_DIR="$(pwd)/$PROJECT_NAME"
  if [ -d "$PROJECT_DIR" ] && { [ ! -d "$PROJECT_DIR/src" ] || [ ! -d "$PROJECT_DIR/include" ]; }; then
	echo "Error: Directory '$PROJECT_DIR' exists but is not a valid project (missing src/ or include/)."
	exit 1
  fi
elif [ -n "$NEW_HEADER" ] || [ -n "$NEW_SOURCE" ] || [ -n "$NEW_UNIT" ]; then
  PROJECT_DIR="$(pwd)"
  PROJECT_NAME="$(basename "$PROJECT_DIR")"
  if [ ! -d "$PROJECT_DIR/src" ] || [ ! -d "$PROJECT_DIR/include" ]; then
	echo "Error: Not in a valid project directory (missing src/ or include/)."
	exit 1
  fi
else
  echo "Error: Project name is required when not using -i, -c, -u, or -l."
  exit 1
fi

# Create directory structure (if new project)
if [ ! -d "$PROJECT_DIR" ]; then
  mkdir -p "$PROJECT_DIR"/{bin,build,include,src,test}

  # Makefile (library or app-specific)
  if [ -n "$IS_LIBRARY" ]; then
	cat <<EOL > "$PROJECT_DIR/Makefile"
# Compiler and flags
CC = gcc
CFLAGS = -Wall -g -fPIC -Iinclude
LDFLAGS = -shared
TST_CFLAGS = -Wall -g -Iinclude
TST_LDFLAGS = -lsigtest -L/usr/lib -l$PROJECT_NAME -L\$(BIN_DIR)

# Directories
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
BIN_DIR = bin
TEST_DIR = test
TST_BUILD_DIR = \$(BUILD_DIR)/test

# Source files
SRCS = \$(wildcard \$(SRC_DIR)/*.c)
OBJS = \$(patsubst \$(SRC_DIR)/%.c, \$(BUILD_DIR)/%.o, \$(SRCS))
TST_SRCS = \$(wildcard \$(TEST_DIR)/*.c)
TST_OBJS = \$(patsubst \$(TEST_DIR)/%.c, \$(TST_BUILD_DIR)/%.o, \$(TST_SRCS))

# Library and test targets
TARGET = \$(BIN_DIR)/lib$PROJECT_NAME.so
TST_TARGET = \$(TST_BUILD_DIR)/run_tests

# Default target
all: \$(TARGET)

# Link the library
\$(TARGET): \$(OBJS)
	@mkdir -p \$(BIN_DIR)
	\$(CC) \$(OBJS) -o \$(TARGET) \$(LDFLAGS)

# Compile source files
\$(BUILD_DIR)/%.o: \$(SRC_DIR)/%.c
	@mkdir -p \$(BUILD_DIR)
	\$(CC) \$(CFLAGS) -c \$< -o \$@

# Compile test source files
\$(TST_BUILD_DIR)/%.o: \$(TEST_DIR)/%.c
	@mkdir -p \$(TST_BUILD_DIR)
	\$(CC) \$(TST_CFLAGS) -c \$< -o \$@

# Link test executable
\$(TST_TARGET): \$(TST_OBJS) \$(TARGET)
	@mkdir -p \$(TST_BUILD_DIR)
	\$(CC) \$(TST_OBJS) -o \$(TST_TARGET) \$(TST_LDFLAGS)

# Run tests
test: \$(TST_TARGET)
	@\$(TST_TARGET)

# Install to /usr/lib and /usr/include
install: test \$(TARGET)
	cp \$(TARGET) /usr/lib/
	cp \$(INCLUDE_DIR)/$PROJECT_NAME.h /usr/include/

# Clean build artifacts
clean:
	rm -rf \$(BUILD_DIR) \$(BIN_DIR)

.PHONY: all test install clean
EOL
  else
	cat <<EOL > "$PROJECT_DIR/Makefile"
# Compiler and flags
CC = gcc
CFLAGS = -Wall -g -Iinclude
LDFLAGS = -lsigcore
TST_CFLAGS = \$(CFLAGS)
TST_LDFLAGS = \$(LDFLAGS) -lsigtest -L/usr/lib

# Directories
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
BIN_DIR = bin
TEST_DIR = test
TST_BUILD_DIR = \$(BUILD_DIR)/test

# Source files
SRCS = \$(wildcard \$(SRC_DIR)/*.c)
OBJS = \$(patsubst \$(SRC_DIR)/%.c, \$(BUILD_DIR)/%.o, \$(SRCS))
TST_SRCS = \$(wildcard \$(TEST_DIR)/*.c)
TST_OBJS = \$(patsubst \$(TEST_DIR)/%.c, \$(TST_BUILD_DIR)/%.o, \$(TST_SRCS))

# Executables
TARGET = \$(BIN_DIR)/$PROJECT_NAME
TST_TARGET = \$(TST_BUILD_DIR)/run_tests

# Default target
all: \$(TARGET)

# Link the main executable
\$(TARGET): \$(OBJS)
	@mkdir -p \$(BIN_DIR)
	\$(CC) \$(OBJS) -o \$(TARGET) \$(LDFLAGS)

# Compile main source files
\$(BUILD_DIR)/%.o: \$(SRC_DIR)/%.c
	@mkdir -p \$(BUILD_DIR)
	\$(CC) \$(CFLAGS) -c \$< -o \$@

# Compile test source files
\$(TST_BUILD_DIR)/%.o: \$(TEST_DIR)/%.c
	@mkdir -p \$(TST_BUILD_DIR)
	\$(CC) \$(TST_CFLAGS) -c \$< -o \$@

# Link test executable
\$(TST_TARGET): \$(TST_OBJS) \$(OBJS)
	@mkdir -p \$(TST_BUILD_DIR)
	\$(CC) \$(TST_OBJS) \$(OBJS) -o \$(TST_TARGET) \$(TST_LDFLAGS)

# Run tests
test: \$(TST_TARGET)
	@\$(TST_TARGET)

# Clean build artifacts
clean:
	rm -rf \$(BUILD_DIR) \$(BIN_DIR)

# Run the executable
run: \$(TARGET)
	./\$(TARGET)

.PHONY: all clean run test
EOL
  fi

  # Core header with typedefs (only for app projects)
  if [ -z "$IS_LIBRARY" ]; then
	cat <<EOL > "$PROJECT_DIR/include/core.h"
// core.h
#ifndef CORE_H
#define CORE_H

#include <sigcore.h>

#endif // CORE_H
EOL

	# Simple main.c
	cat <<EOL > "$PROJECT_DIR/src/main.c"
#include "core.h"
#include <stdio.h>

int main(void) {
	string greeting = "Hello, $PROJECT_NAME!";
	printf("%s\\n", greeting);
	return 0;
}
EOL
  else
	# sigcore.h for library project
	cat <<EOL > "$PROJECT_DIR/include/$PROJECT_NAME.h"
// $PROJECT_NAME.h
#ifndef SIGCORE_H
#define SIGCORE_H

#include <stdint.h>

typedef void* object;
typedef uintptr_t addr;
typedef char* string;

// List
struct list_s {
	addr* bucket;
	addr last;
	addr cap;
};

typedef struct list_s* List;

typedef struct IList {
	List (*new)(int capacity);
	void (*destroy)(List self);
	void (*add)(List self, addr item);
	addr (*get)(List self, int index);
	void (*remove)(List self, addr item);
	int (*count)(List self);
	int (*capacity)(List self);
} IList;

extern const IList List;

// Mem
struct mem_s {
	List allocations;  // Tracks allocated addresses
};

typedef struct mem_s* Mem;

typedef struct IMem {
	Mem (*new)(void);
	void (*destroy)(Mem self);
	object (*alloc)(Mem self, size_t size);
	void (*free)(Mem self, object ptr);
} IMem;

extern const IMem Mem;

// Map
struct map_s {
	string* keys;
	addr* values;
	int count;
	int capacity;
};

typedef struct map_s* Map;

typedef struct IMap {
	Map (*new)(int capacity);
	void (*destroy)(Map self);
	void (*put)(Map self, string key, addr value);
	addr (*get)(Map self, string key);
	int (*count)(Map self);
} IMap;

extern const IMap Map;

#endif // SIGCORE_H
EOL
  fi

  # .gitignore
  cat <<EOL > "$PROJECT_DIR/.gitignore"
build/
bin/
EOL

  echo "Created C project '$PROJECT_NAME' at '$PROJECT_DIR'"
fi

# Handle -i, -c, and -u
if [ -n "$NEW_HEADER" ]; then
  add_header "$NEW_HEADER" "$PROJECT_DIR"
elif [ -n "$NEW_SOURCE" ]; then
  add_source "$NEW_SOURCE" "$SOURCE_TYPE" "$PROJECT_DIR"
elif [ -n "$NEW_UNIT" ]; then
  add_unit "$NEW_UNIT" "$PROJECT_DIR"
fi
