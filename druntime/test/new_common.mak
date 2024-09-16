# set explicitly in the make cmdline in druntime/Makefile (`test/%/.run` rule):
OS:=
MODEL:=
BUILD:=
DMD:=
DRUNTIME:=
DRUNTIMESO:=
LINKDL:=
QUIET:=
TIMELIMIT:=
PIC:=
SHARED:=

# Variables that can be specified by users, with the same meaning as used by GNU make
# $(CC)      $(CXX)      $(DMD)       # the compiler
# $(CFLAGS)  $(CXXFLAGS) $(DFLAGS)    # flags for the compiler
# $(LDFLAGS) ditto       $(LDFLAGS.d) # flags for the compiler when it invokes the linker
# $(LDLIBS)  ditto       $(LDLIBS.d)  # library names given to the compiler when invoking the linker
# $(TARGET_ARCH) ditto   $(TARGET_ARCH.d) # undocumented but used in the implicit rules

# Information for writting addition tests:
#
# Each variable above also has a extra_* flavor that can be used by
# the makefiles. CFLAGS et al are meant for users. Do _not_ put flags
# in there unless the flags don't matter. Use extra_cflags for that
# purpose. When writting recipes either use the $(COMPILE.d) or
# $(LINK.cpp) convenience wrappers or make sure that you respect _all_
# relevant variables. The pattern rules below should handle most cases
# of compilation so you should only need to specify the tests'
# recipes.

########## Misc setup ##########

# Windows: set up bash shell
ifeq (windows,$(OS))
    include ../../../compiler/src/osmodel.mak
endif

SRC:=src
VPATH = $(SRC)
GENERATED:=./generated
ROOT:=$(GENERATED)/$(OS)/$(BUILD)/$(MODEL)
OBJDIR = $(ROOT)

# non-empty if linking shared druntime. Useful for usage in $(if)
is_linking_shared := $(filter 1,$(LINK_SHARED))
druntime_for_linking := $(if $(is_linking_shared),$(DRUNTIMESO:.dll=.lib),$(DRUNTIME))
DRUNTIME_DEP := $(if $(is_linking_shared),$(DRUNTIMESO),$(DRUNTIME))
# GNU make says that compiler variables like $(DMD) can contain arguments, technically.
DMD_DEP := $(firstword $(DMD))

ifneq ($(strip $(QUIET)),)
.SILENT:
endif

########## Default build commands ##########

# Similar to the implicit rules defined by GNU make
COMPILE.c = $(CC) $(extra_cflags) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.cpp = $(CXX) $(extra_cxxflags) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH.d) -c
COMPILE.d = $(DMD) $(extra_dflags) $(DFLAGS) $(TARGET_ARCH) -c

LINK.c = $(CC) $(extra_cflags) $(CFLAGS) $(CPPFLAGS) $(extra_ldflags) $(LDFLAGS) $(TARGET_ARCH)
LINK.cpp = $(CXX) $(extra_cxxflags) $(CXXFLAGS) $(CPPFLAGS) $(extra_ldflags) $(LDFLAGS) $(TARGET_ARCH)
LINK.d = $(DMD) $(extra_dflags) $(DFLAGS) $(extra_ldflags.d) $(LDFLAGS.d) $(TARGET_ARCH.d)
LINK.o = $(CC) $(extra_ldflags) $(LDFLAGS) $(TARGET_ARCH)

OUTPUT_FLAG = -o #<- important space: OUTPUT_FLAG = "-o "
OUTPUT_FLAG.d = -of=

OUTPUT_OPTION = $(OUTPUT_FLAG)$@
OUTPUT_OPTION.d = $(OUTPUT_FLAG.d)$@

ifeq (windows,$(OS))
    DOTEXE:=.exe
    DOTDLL:=.dll
    DOTLIB:=.lib
    DOTOBJ:=.obj
else
    DOTEXE:=
    DOTDLL:=$(if $(findstring $(OS),osx),.dylib,.so)
    DOTLIB:=.a
    DOTOBJ:=.o
endif

# Default values for the D counterparts of the standard variables
LDLIBS.d = $(LDLIBS:%=-L%)
TARGET_ARCH.d = $(TARGET_ARCH)

LDFLAGS.d := $(LDFLAGS)
# LDFLAGS.d == -Wl,-O1 -Wl,--as-needed -Wl,-z,pack-relative-relocs
comma := ,
empty :=
space := $(empty) $(empty)
LDFLAGS.d := $(subst $(comma),$(space),$(LDFLAGS.d))
# LDFLAGS.d == -Wl -O1 -Wl --as-needed -z pack-relative-relocs
LDFLAGS.d := $(filter-out -Wl,$(LDFLAGS.d))
# LDFLAGS.d == -O1 --as-needed -z pack-relative-relocs
LDFLAGS.d := $(LDFLAGS.d:%=-L%)
# LDFLAGS.d == -L-O1 -L--as-needed -L-z -Lpack-relative-relocs

########## Default pattern rules ##########

$(OBJDIR)/%$(DOTOBJ): %.c | $(OBJDIR)
	$(COMPILE.c) $(OUTPUT_OPTION) $< $(extra_sources)
$(OBJDIR)/%$(DOTOBJ): %.cpp | $(OBJDIR)
	$(COMPILE.d) $(OUTPUT_OPTION) $< $(extra_sources)
$(OBJDIR)/%$(DOTOBJ): %.d $(DMD_DEP) $(DRUNTIME_DEP)
	$(COMPILE.d) $(OUTPUT_OPTION.d) $< $(extra_sources)

$(OBJDIR)/%$(DOTEXE): %.c | $(OBJDIR)
	$(LINK.c) $< $(extra_sources) $(extra_ldlibs) $(LDLIBS) $(OUTPUT_OPTION)
$(OBJDIR)/%$(DOTEXE): %.cpp | $(OBJDIR)
	$(LINK.cpp) $< $(extra_sources) $(extra_ldlibs) $(LDLIBS) $(OUTPUT_OPTION)
$(OBJDIR)/%$(DOTEXE): %.d $(DMD_DEP) $(DRUNTIME_DEP)
	$(LINK.d) $< $(extra_sources) $(extra_ldlibs.d) $(LDLIBS.d) $(OUTPUT_OPTION.d)
$(OBJDIR)/%$(DOTEXE): %.o | $(OBJDIR)
	$(LINK.o) $< $(extra_sources) $(extra_ldlibs) $(LDLIBS) $(OUTPUT_OPTION)

########## Default build flags ##########

ifeq ($(BUILD),debug)
    CFLAGS = $(if $(filter windows,$(OS)),/Zi,-g)
    CXXFLAGS :::= $(CFLAGS)
    DFLAGS = -g -debug
else
    CFLAGS = $(if $(filter windows,$(OS)),/O2,-O3)
    CXXFLAGS :::= $(CFLAGS)
    DFLAGS = -O -release
endif
CFLAGS += $(if $(filter windows,$(OS)),/Wall,-Wall)
DFLAGS += -w

extra_cflags += $(PIC)
extra_cxxflags += $(PIC)
extra_dflags += $(PIC) -I../../src -I../../import -I$(SRC) -preview=dip1000

# A lot of the tests perform assert checks. Preserve them even with -release
extra_dflags += -check=assert

extra_ldflags.d += $(if $(filter windows,$(OS)),-dllimport=all)
extra_ldlibs.d += -L$(druntime_for_linking)

extra_ldflags.d += -defaultlib=
extra_ldlibs.d += $(if $(filter-out windows,$(OS)),-L-lpthread -L-lm $(LINKDL))

model_flag := $(if $(filter-out default,$(MODEL)),-m$(MODEL))
TARGET_ARCH = $(model_flag) $(if $(filter osx64,$(OS)$(MODEL)),--target=x86_64-darwin-apple)
TARGET_ARCH.d = $(model_flag)

########## Other common code ##########

.PHONY: all cleam
all: $(TESTS:%=$(OBJDIR)/%.done)

$(OBJDIR)/%.done: $(OBJDIR)/%$(DOTEXE)
	$(TIMELIMIT)./$< $(run_args)
	@touch $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

# Preserve the executable files after running the tests
.NOTINTERMEDIATE: $(OBJDIR)/%$(DOTEXE)

clean:
	$(RM) -r $(OBJDIR)

$(DMD_DEP): ;
$(DRUNTIME_DEP): ;
