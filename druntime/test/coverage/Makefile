normal := basic
merge := merge merge_true
TESTS := $(normal) $(merge) no_code merge_override
include ../new_common.mak

NORMAL_TESTS := $(normal:%=$(ROOT)/%.done)
MERGE_TESTS := $(merge:%=$(ROOT)/%.done)

extra_dflags += -cov

DIFF:=diff --strip-trailing-cr
SED:=sed

ifneq (,$(filter $(OS),freebsd osx))
    SED_INPLACE:=-i ''
else
    SED_INPLACE:=-i''
endif

$(NORMAL_TESTS): $(ROOT)/%.done: $(ROOT)/%$(DOTEXE)
	@echo Testing $*
	@$(RM) $(ROOT)/src-$*.lst
	$< $(ROOT)
ifeq (windows,$(OS))
	$(SED) $(SED_INPLACE) 's:^src\\:src/:g' $(ROOT)/src-$*.lst
endif
	$(DIFF) src-$*.lst.exp $(ROOT)/src-$*.lst
	@touch $@

$(MERGE_TESTS): $(ROOT)/%.done: $(ROOT)/%$(DOTEXE)
	@echo Testing $*
	@$(RM) $(ROOT)/src-$*.lst
	$< $(ROOT)
	$< $(ROOT)
ifeq (windows,$(OS))
	$(SED) $(SED_INPLACE) 's:^src\\:src/:g' $(ROOT)/src-$*.lst
endif
	$(DIFF) src-$*.lst.exp $(ROOT)/src-$*.lst
	@touch $@

$(ROOT)/merge_override.done: $(ROOT)/%.done: $(ROOT)/%$(DOTEXE) $(ROOT)/1/src/%.d $(ROOT)/2/src/%.d
	@echo Testing $*
	@$(RM) $(ROOT)/src-$*.lst

	$< $(ROOT) $(ROOT)/1
	$(DIFF) src-$*.lst_1.exp $(ROOT)/src-$*.lst

	$< $(ROOT) $(ROOT)/2
	$(DIFF) src-$*.lst_2.exp $(ROOT)/src-$*.lst

	@touch $@

$(ROOT)/1/$(SRC)/merge_override.d: merge_override.d | $(ROOT)/1/$(SRC)
	cp $< $@
$(ROOT)/2/$(SRC)/merge_override.d: merge_override.d | $(ROOT)/2/$(SRC)
	cp $< $@
	$(SED) $(SED_INPLACE) 's/CHANGE_VAR/CHANGEVAR/g' $@
$(ROOT)/1/$(SRC) $(ROOT)/2/$(SRC):
	mkdir -p $@

$(ROOT)/no_code.done: $(ROOT)/%.done: $(ROOT)/%$(DOTEXE)
	@echo Testing $*
	@$(RM) $(ROOT)/src-$*.lst
	$< $(ROOT)
	$< $(ROOT)
ifeq (windows,$(OS))
	$(SED) $(SED_INPLACE) 's:^src\\:src/:g' $(ROOT)/src-$*.lst
	$(SED) $(SED_INPLACE) 's:^src\\:src/:g' $(ROOT)/src-$*_imp.lst
endif
	$(DIFF) src-$*.lst.exp $(ROOT)/src-$*.lst
	$(DIFF) src-$*_imp.lst.exp $(ROOT)/src-$*_imp.lst
	@touch $@
$(ROOT)/no_code$(DOTEXE): no_code_imp.d
