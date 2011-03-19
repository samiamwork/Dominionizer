PRODUCT_NAME := cardlistmaker
CONFIG ?= Debug
PRODUCT_DIR = build/$(CONFIG)
PRODUCT = $(PRODUCT_DIR)/$(PRODUCT_NAME)
IMGMAKER = $(PRODUCT_DIR)/imagemaker
SRC = cardlistmaker.m
OBJ = $(addprefix $(PRODUCT_DIR)/,$(SRC:.m=.o))
IMGMAKER_SRC = imagemaker.m
IMGMAKER_OBJ = $(addprefix $(PRODUCT_DIR)/,$(IMGMAKER_SRC:.m=.o))
FRAMEWORKS = -framework Foundation -framework Quartz -framework ApplicationServices
CFLAGS = -g -c -Wall -Wextra -Werror -Wno-unused-parameter
LDFLAGS = $(FRAMEWORKS)
CC = gcc
LD = gcc

all: $(PRODUCT) $(IMGMAKER)

.PHONY: all test clean

test: $(PRODUCT)
	./$(PRODUCT) cardlist.txt
	./$(IMGMAKER)

clean:
	rm -rf build

$(PRODUCT_DIR):
	mkdir -p $@

$(PRODUCT_DIR)/%.o: %.m | $(PRODUCT_DIR)
	$(CC) $(CFLAGS) $< -o $@

$(PRODUCT): $(OBJ)
	$(LD) $^ $(LDFLAGS) -o $@

$(IMGMAKER): $(IMGMAKER_OBJ)
	$(LD) $^ $(LDFLAGS) -o $@


