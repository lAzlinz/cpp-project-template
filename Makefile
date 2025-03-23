CXX := g++
SRC_DIR := src
BIN_DIR := bin
INCLUDE_DIR := include
LIB_DIR := lib
TARGET := $(BIN_DIR)/main.exe

define find_cpp_files
    $(wildcard $(1)/*.cpp) $(foreach d,$(wildcard $(1)/*),$(call find_cpp_files,$d))
endef

define MAKE_DIR
	@if not exist "$(dir $@)" mkdir "$(dir $@)"
endef

ALL_LIB_DIRS := $(wildcard $(LIB_DIR)/*)
LIB_INCLUDE_DIRS := $(foreach lib_dir,$(ALL_LIB_DIRS),$(lib_dir)/$(INCLUDE_DIR))

SRCS := $(call find_cpp_files,$(SRC_DIR))
OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(BIN_DIR)/%.o,$(SRCS))

CXXFLAGS := -Wall -I$(INCLUDE_DIR) $(foreach lib_include,$(LIB_INCLUDE_DIRS),-I$(lib_include)) -std=c++17
LDFLAGS = $(foreach lib_dir, $(ALL_LIB_DIRS),-L$(lib_dir) -l$(patsubst $(LIB_DIR)/%,%,$(lib_dir)))

define COMPILE
	$(CXX) $(CXXFLAGS) -c $< -o $@
endef

compile_all: $(TARGET)

$(BIN_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(MAKE_DIR)
	$(COMPILE)

$(TARGET): $(OBJS)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)

# COMPILING A LIBRARY
LIB_NAME ?= 

LIB_SRCS := $(call find_cpp_files,$(LIB_DIR)/$(LIB_NAME)/src)
LIB_OBJS := $(patsubst $(LIB_DIR)/$(LIB_NAME)/$(SRC_DIR)/%.cpp,$(LIB_DIR)/$(LIB_NAME)/$(BIN_DIR)/%.o,$(LIB_SRCS))
LIB_TARGET := $(LIB_DIR)/$(LIB_NAME)/lib$(LIB_NAME).a

$(LIB_DIR)/$(LIB_NAME)/$(BIN_DIR)/%.o: $(LIB_DIR)/$(LIB_NAME)/$(SRC_DIR)/%.cpp
	$(MAKE_DIR)
	$(COMPILE)

$(LIB_TARGET): $(LIB_OBJS)
	ar rcs $@ $^

compile_lib: $(LIB_TARGET)

run: $(TARGET)
	@$<

.PHONY: compile_all compile_lib run
