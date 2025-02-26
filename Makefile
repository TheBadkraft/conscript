CC = gcc
CFLAGS = -Wall -g -Iinclude
LDFLAGS = -lsigcore -L/usr/lib
TST_CFLAGS = $(CFLAGS) -I/usr/include
TST_LDFLAGS = $(LDFLAGS) -lsigtest

SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
BIN_DIR = bin
TEST_DIR = test
TST_BUILD_DIR = $(BUILD_DIR)/test

# Source files
SRCS = $(filter-out $(SRC_DIR)/client.c, $(wildcard $(SRC_DIR)/*.c))
CLIENT_SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))
CLIENT_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(CLIENT_SRCS))
TST_SRCS = $(wildcard $(TEST_DIR)/*.c)
TST_OBJS = $(patsubst $(TEST_DIR)/%.c, $(TST_BUILD_DIR)/%.o, $(TST_SRCS))

# Targets
CLIENT_TARGET = $(BIN_DIR)/conscript
SERVER_TARGET = $(BIN_DIR)/conscript_server
TST_TARGET = $(TST_BUILD_DIR)/run_tests

# Default: build client
all: $(CLIENT_TARGET)

# Client build (full game)
$(CLIENT_TARGET): $(CLIENT_OBJS)
    @mkdir -p $(BIN_DIR)
    $(CC) $(CLIENT_OBJS) -o $(CLIENT_TARGET) $(LDFLAGS)

# Server build (no client)
$(SERVER_TARGET): $(OBJS)
    @mkdir -p $(BIN_DIR)
    $(CC) -DNOPLAYER $(OBJS) -o $(SERVER_TARGET) $(LDFLAGS)

# Compile source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
    @mkdir -p $(BUILD_DIR)
    $(CC) $(CFLAGS) -c $< -o $@

# Compile test files
$(TST_BUILD_DIR)/%.o: $(TEST_DIR)/%.c
    @mkdir -p $(TST_BUILD_DIR)
    $(CC) $(TST_CFLAGS) -c $< -o $@

# Link all tests
$(TST_TARGET): $(TST_OBJS) $(CLIENT_OBJS)
    @mkdir -p $(TST_BUILD_DIR)
    $(CC) $(TST_OBJS) $(CLIENT_OBJS) -o $(TST_TARGET) $(TST_LDFLAGS)

# Single test (e.g., test_game)
$(TST_BUILD_DIR)/test_%: $(TST_BUILD_DIR)/test_%.o $(CLIENT_OBJS)
    @mkdir -p $(TST_BUILD_DIR)
    $(CC) $< $(CLIENT_OBJS) -o $@ $(TST_LDFLAGS)

# Build options
client: $(CLIENT_TARGET)
server: $(SERVER_TARGET)
test: $(TST_TARGET)
test_%: $(TST_BUILD_DIR)/test_%
    @$<

# Run options
run_client: $(CLIENT_TARGET)
    ./$(CLIENT_TARGET)
run_admin: $(CLIENT_TARGET)
    ./$(CLIENT_TARGET) --admin
run_server: $(SERVER_TARGET)
    ./$(SERVER_TARGET)

# Clean
clean:
    rm -rf $(BUILD_DIR) $(BIN_DIR)

.PHONY: all client server test test_% clean run_client run_admin run_server
