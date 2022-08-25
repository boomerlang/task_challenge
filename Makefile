ERLC=/usr/local/bin/erlc
ERLC_FLAGS= -o ebin

MODULES = gen_module mochijson2 mochinum srvchl_app srvchl_sup srvchl_ctl

EBIN_FILES=$(MODULES:%=ebin/%.beam) 

all: $(EBIN_FILES) 

ebin/%.beam: src/%.erl
	$(ERLC) $(ERLC_FLAGS) $<
	
clean:
	rm -f $(EBIN_FILES)
