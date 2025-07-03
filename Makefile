PROJECT := garmingotchi
DEVICE  := instinct3solar45mm

SRC_DIR := ./source
RES_DIR := ./resources
BIN_DIR := ./bin
KEY_DIR := ./keys

PROGRAM  := $(BIN_DIR)/$(PROJECT).prg
DEV_KEY  := $(KEY_DIR)/developer_key.der
MANIFEST := ./manifest.xml
JUNGLE   := ./monkey.jungle

SRC := $(shell find $(SRC_DIR) -name *.mc)
RES := $(shell find $(RES_DIR) $(RES_DIR)-$(DEVICE) -type f)

all: app

key: $(DEV_KEY)

app: $(PROGRAM)

sim: $(PROGRAM)
	monkeydo $(PROGRAM) $(DEVICE)

ciq:
	connectiq &

$(BIN_DIR)/%.prg: $(SRC) $(RES) $(MANIFEST) $(JUNGLE) $(DEV_KEY) | $(BIN_DIR)
	monkeyc -d $(DEVICE) -f $(JUNGLE) -o $@ -y $(DEV_KEY) -w -r

$(KEY_DIR)/%.der: $(KEY_DIR)/%.pem | $(KEY_DIR)
	openssl pkcs8 -topk8 -inform PEM -outform DER -in $< -out $@ -nocrypt

$(KEY_DIR)/%.pem: | $(KEY_DIR)
	openssl genrsa -out $@ 4096

$(BIN_DIR):
$(KEY_DIR):
	mkdir -p $@

clean:
	rm -rf $(BIN_DIR) $(KEY_DIR)

.PHONY: all key app sim ciq clean
