LBITS := $(shell getconf LONG_BIT)

UNAME := $(shell uname)

CFLAGS = -Wall -O3 -I src -I native/include -fPIC -I sdk/public

ifndef ARCH
	ARCH = $(LBITS)
endif

ifndef HASHLINK_SRC
	HASHLINK_SRC = ../../../hashlink
endif

LIBARCH=$(ARCH)
LIBHL=libhl.xxx
ifeq ($(UNAME),Darwin)
OS=osx
# universal lib in osx32 dir
LIBARCH=32
LIBHL=libhl.dylib
else
OS=linux
CFLAGS += -std=c++0x
LIBHL=libhl.so
endif

SDKVER=142
#SDKURL=https://partner.steamgames.com/downloads/steamworks_sdk_${SDKVER}.zip

LFLAGS = -lhl -lsteam_api -lstdc++ -L native/lib/$(OS)$(LIBARCH) -L ../../../hashlink -L sdk/redistributable_bin/$(OS)$(LIBARCH)

SRC = native/cloud.o native/common.o native/controller.o native/friends.o native/gameserver.o \
	native/matchmaking.o native/networking.o native/stats.o native/ugc.o

all: ${SRC}
	${CC} ${CFLAGS} -shared -o steam.hdll ${SRC} ${LFLAGS}

prepare:
	rm -rf native/lib/$(OS)$(LIBARCH)
	mkdir -p native/include
	mkdir -p native/lib/$(OS)$(LIBARCH)
	cp $(HASHLINK_SRC)/src/hl.h native/include/
	cp $(HASHLINK_SRC)/$(LIBHL) native/lib/$(OS)$(LIBARCH)/

	chmod +x sdk/tools/ContentBuilder/builder_linux/steamcmd.sh
	chmod +x sdk/tools/ContentBuilder/builder_linux/linux32/steamcmd
	chmod +x sdk/tools/ContentBuilder/builder_linux/linux32/steamerrorreporter
	
	git clone git@git.motion-twin.com:deadcells/SteamContentBuilder.git
	rm -rf sdk/tools/ContentBuilder/scripts/
	mv SteamContentBuilder/.git* sdk/tools/ContentBuilder/
	mv SteamContentBuilder/* sdk/tools/ContentBuilder/
	rmdir SteamContentBuilder 

.SUFFIXES : .cpp .o

.cpp.o :
	${CC} ${CFLAGS} -o $@ -c $<
	
clean_o:
	rm -f ${SRC}

clean: clean_o
	rm -f steam.hdll

