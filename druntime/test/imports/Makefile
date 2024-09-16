TESTS := bug18193

include ../new_common.mak

$(ROOT)/%.done: %.d
	@echo Testing $*
	$(COMPILE.d) -deps=$@ -version=Shared -o- $<
