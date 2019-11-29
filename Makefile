LBITS := $(shell getconf LONG_BIT)

UNAME := $(shell uname)

CFLAGS = -Wall -O3 -I src -I native/include -fPIC -I sdk/public

ifndef ARCH
	ARCH = $(LBITS)
endif

LIBARCH=$(ARCH)
ifeq ($(UNAME),Darwin)
OS=osx
# universal lib in osx32 dir
LIBARCH=32
else
OS=linux
CFLAGS += -std=c++0x
endif

SDKVER=142
#SDKURL=https://partner.steamgames.com/downloads/steamworks_sdk_${SDKVER}.zip

LFLAGS = -lhl -lsteam_api -lstdc++ -L native/lib/$(OS)$(LIBARCH) -L sdk/redistributable_bin/$(OS)$(LIBARCH)

SRC = native/cloud.o native/common.o native/controller.o native/friends.o native/gameserver.o \
	native/matchmaking.o native/networking.o native/stats.o native/ugc.o

all: ${SRC}
	${CC} ${CFLAGS} -shared -o steam.hdll ${SRC} ${LFLAGS}

prepare:
	rm -rf native/lib/$(OS)$(LIBARCH)
	
	mkdir -p native/lib
	mkdir -p native/include
	mkdir -p native/lib/$(OS)$(LIBARCH)
	
	cp ../../../hashlink/src/hl.h native/include/
	cp ../../../hashlink/libhl.dylib native/lib/$(OS)$(LIBARCH)/
	#cp -r sdk/redistributable_bin/$(OS)$(ARCH) native/lib/$(OS)$(LIBARCH)

install:
	cp steam.hdll /usr/lib
	cp native/lib/$(OS)$(ARCH)/libsteam_api.* /usr/lib
	
.SUFFIXES : .cpp .o

.cpp.o :
	${CC} ${CFLAGS} -o $@ -c $<
	
clean_o:
	rm -f ${SRC}

clean: clean_o
	rm -f steam.hdll

