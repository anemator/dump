libpreload.so: preload.c
	gcc -shared -fPIC -o $@ $^

main: main.c
	gcc -o $@ $<

.PHONY: all
all: libpreload.so main

run: all
	./main
	LD_PRELOAD=$(PWD)/libpreload.so ./main

clean:
	rm -fv main *.so
