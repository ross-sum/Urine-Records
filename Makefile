#########################################################
#             Make file for Light Switches              #
#########################################################

# Use standard variables to define compile and link flags
ACC=gprbuild
TA=urine_records
TS=$(TA).gpr
BA=tobase64
BS=$(BA).gpr
HOST_TYPE := $(shell uname -m)
ifeq ($(HOST_TYPE),amd)
	TARGET=sparc
else ifeq ($(HOST_TYPE),x86_64)
	TARGET=amd64
else ifeq ($(HOST_TYPE),x86)
	TARGET=x86
else ifeq ($(HOST_TYPE),i686)
	TARGET=x86
else ifeq ($(HOST_TYPE),arm)
	TARGET=pi
else ifeq ($(HOST_TYPE),armv7l)
	TARGET=pi
endif
BIN=/usr/local/bin
ETC=/usr/local/etc
VAR=/var/local
TD=obj_$(TARGET)
ifeq ("$1.",".")
	FLAGS=-Xhware=$(TARGET)
else
	FLAGS=-Xhware=$(TARGET) $1
endif
ifeq ($(TARGET),pi)
	FLAGS+=-largs -lwiringPi
endif

urinerecords:
	$(ACC) -P $(TS) $(FLAGS)

tobase64s:
	$(ACC) -P $(BS) $(FLAGS)

# Define the target "all"
all:
	urinerecords:
	tobase64s:

# Clean up to force the next compilation to be everything
clean:
	gprclean -P $(TS)
	gprclean -P $(BS)

dist-clean: distclean

distclean: clean

install:
	cp $(TD)/$(TA) $(BIN)
	cp $(TD)/$(BA) $(BIN)
	cp $(TD)/$(TA).xml $(VAR)
	cp $(TD)/$(TA).xsd $(ETC)
	mkdir -p $(ETC)/init.d/
	cp $(TD)/$(TA).rc $(ETC)/init.d/$(TA)
	mkdir -p $(ETC)/default/
	cp $(TD)/$(TA).default $(ETC)/default/$(TA)
	mkdir -p $(ETC)/systemd/system/
	cp $(TD)/$(TA).service $(ETC)/systemd/system/

