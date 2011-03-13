PRODUCT_NAME := cardlistmaker
CONFIG ?= Debug
PRODUCT_DIR = build/$(CONFIG)
PRODUCT = $(PRODUCT_DIR)/$(PRODUCT_NAME)
SRC = cardlistmaker.m
OBJ = $(addprefix $(PRODUCT_DIR)/,$(SRC:.m=.o))
FRAMEWORKS = -framework Foundation
CFLAGS = -g -c -Wall -Wextra -Werror -Wno-unused-parameter
LDFLAGS = $(FRAMEWORKS)
CC = gcc
LD = gcc

all: $(PRODUCT)

.PHONY: all test clean

test: $(PRODUCT)
	./$(PRODUCT) cardlist.txt

clean:
	rm -rf build

$(PRODUCT_DIR):
	mkdir -p $@

$(PRODUCT_DIR)/%.o: %.m | $(PRODUCT_DIR)
	$(CC) $(CFLAGS) $< -o $@

$(PRODUCT): $(OBJ)
	$(LD) $^ $(LDFLAGS) -o $@

