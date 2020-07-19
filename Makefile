GNUMAKEFLAGS := -s

all: cmake
	cmake --build _build -j$(N=$(($(nproc)-1)); echo $(($N > 1 ? $N : 1)))

%: cmake
	make -C _build $@

clean: cmake
	make -C _build clean
	rm -rf _build

cmake:
	mkdir -p _build && cd _build && cmake ..
