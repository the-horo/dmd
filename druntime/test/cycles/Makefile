TESTS:=cycle_ignore cycle_abort cycle_print cycle_deprecate
include ../new_common.mak

$(ROOT)/cycle_ignore.done: retcode=0
$(ROOT)/cycle_ignore.done: lines=0
$(ROOT)/cycle_abort.done: retcode=1
$(ROOT)/cycle_abort.done: lines=$(if $(findstring $(OS),windows),8,7)
$(ROOT)/cycle_print.done: retcode=0
$(ROOT)/cycle_print.done: lines=6
$(ROOT)/cycle_deprecate.done: retcode=1
$(ROOT)/cycle_deprecate.done: lines=$(if $(findstring $(OS),windows),9,8)
$(ROOT)/%.done: $(ROOT)/test_cycles$(DOTEXE)
	@echo Testing $*
	$(TIMELIMIT)$< --DRT-oncycle=$(@F:cycle_%.done=%) > $@ 2>&1; test $$? -eq $(retcode)
	test `cat $@ | wc -l` -eq $(lines)

$(ROOT)/test_cycles$(DOTEXE): $(SRC)/*.d
