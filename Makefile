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
OS_TYPE := $(shell uname -o)
ifeq ($(HOST_TYPE),amd)
	TARGET=sparc
else ifeq ($(HOST_TYPE),x86_64)
ifeq ($(OS_TYPE),Cygwin)
	TARGET=win
else
	TARGET=amd64
endif
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
SD=src
TD=obj_$(TARGET)
ifeq ("$1.",".")
	FLAGS=-Xhware=$(TARGET)
else
	FLAGS=-Xhware=$(TARGET) $1
endif
ifeq ($(OS_TYPE),Cygwin)
	FLAGS+=-cargs -I/usr/include/sys
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
	mkdir -p /usr/local/share/icons/hicolor/scalable/apps/
	cp $(SD)/$(TA).png /usr/local/share/icons/hicolor/scalable/apps/

