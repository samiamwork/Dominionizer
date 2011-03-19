PRODUCT_NAME := imagemaker
CONFIG ?= Debug
PRODUCT_DIR = build/$(CONFIG)
PRODUCT = $(PRODUCT_DIR)/$(PRODUCT_NAME)
SRC = imagemaker.m
OBJ = $(addprefix $(PRODUCT_DIR)/,$(SRC:.m=.o))
FRAMEWORKS = -framework Foundation -framework Quartz -framework ApplicationServices -framework AppKit
CFLAGS = -g -c -Wall -Wextra -Werror -Wno-unused-parameter
LDFLAGS = $(FRAMEWORKS)
CC = gcc
LD = gcc

all: $(PRODUCT)

.PHONY: all test clean

test: $(PRODUCT)
	./$(PRODUCT)

clean:
	rm -rf build

$(PRODUCT_DIR):
	mkdir -p $@

$(PRODUCT_DIR)/%.o: %.m | $(PRODUCT_DIR)
	$(CC) $(CFLAGS) $< -o $@

$(PRODUCT): $(OBJ)
	$(LD) $^ $(LDFLAGS) -o $@
