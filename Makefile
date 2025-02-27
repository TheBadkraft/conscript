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
TST_LOG_DIR = $(TEST_DIR)/logs

# Source files
SRCS = $(filter-out $(SRC_DIR)/client.c, $(wildcard $(SRC_DIR)/*.c))
CLIENT_SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))
CLIENT_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(CLIENT_SRCS))
TST_SRCS = $(wildcard $(TEST_DIR)/*.c)
TST_OBJS = $(patsubst $(TEST_DIR)/%.c, $(TST_BUILD_DIR)/%.o, $(TST_SRCS))
TST_TARGETS = $(patsubst $(TEST_DIR)/%.c, $(TST_BUILD_DIR)/%, $(TST_SRCS))
TST_DEPS_SRCS = $(filter-out $(SRC_DIR)/main.c, $(wildcard $(SRC_DIR)/*.c))
TST_DEPS_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(TST_DEPS_SRCS))

# Default: build client
all: $(CLIENT_TARGET)

# Client build (full game)
client: $(CLIENT_TARGET)

# Server build (no player client)
server: CFLAGS += -DNOPLAYER
server: $(SERVER_TARGET)

$(CLIENT_TARGET): $(CLIENT_OBJS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CLIENT_OBJS) -o $(CLIENT_TARGET) $(LDFLAGS)

$(SERVER_TARGET): $(OBJS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(OBJS) -o $(SERVER_TARGET) $(LDFLAGS)

# Compile source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Compile test files
$(TST_BUILD_DIR)/%.o: $(TEST_DIR)/%.c
	@mkdir -p $(TST_BUILD_DIR)
	$(CC) $(TST_CFLAGS) -c $< -o $@

# Link all tests executable
$(TST_TARGET): $(TST_OBJS) $(CLIENT_OBJS)
	@mkdir -p $(TST_BUILD_DIR)
	$(CC) $(TST_OBJS) $(CLIENT_OBJS) -o $(TST_TARGET) $(TST_LDFLAGS)

# Generic test target (e.g., test_renderer)
$(TST_BUILD_DIR)/test_%: $(TST_BUILD_DIR)/test_%.o $(TST_DEPS_OBJS)
	@mkdir -p $(TST_BUILD_DIR)
	$(CC) $< $(TST_DEPS_OBJS) -o $@ $(TST_LDFLAGS)

# Generic test run (e.g., make test_renderer)
test_%: $(TST_BUILD_DIR)/test_%
	@mkdir -p $(TST_LOG_DIR)
	@$< > $(TST_LOG_DIR)/test_$*.log 2>&1

# Run all tests
test: $(TST_TARGET)
	@mkdir -p $(TST_LOG_DIR)
	@$(TST_TARGET) > $(TST_LOG_DIR)/all_tests.log 2>&1

# Run options
run_client: $(CLIENT_TARGET)
	./$(CLIENT_TARGET)
run_admin: $(CLIENT_TARGET)
	./$(CLIENT_TARGET) admin
run_server: $(SERVER_TARGET)
	./$(SERVER_TARGET)

# Clean
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

.PHONY: all client server test test_% clean run_client run_admin run_server
