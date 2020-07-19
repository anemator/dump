CXX=clang++ -pedantic -Weverything

all:
	$(CXX) -fPIC base.cpp -shared -o libbase.so
	$(CXX) -fno-common -L$(shell pwd) -lbase main.cpp -o main
	LD_LIBRARY_PATH=$(PWD) ./main
