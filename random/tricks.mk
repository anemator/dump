# Suppose a long running script creates multiple files which are needed
# by some rule. Shelling out from a Makefile to create the files one by
# one is a slow process, usually better off to hand the files over in bulk
# to the script. The issue comes about when running make in parallel: if
# each file rule calls the script to generate all the files directly,
# make is unaware the script creates all the files at once. One way around
# this is to make calling rule an actual file to 'funnel' files through
# to the creation script. Since the funnel creates an actual file, make
# will only rerun the rule if the lock file is modified (which only happens
# when the rule is called) or if one its dependants is modified.
FILES := file1 file2
$(FILES:%=unsafe_%):
	sleep 5
	echo $@

.PHONY: unsafe
unsafe: $(FILES:%=unsafe_%)

$(FILES):
	echo $@

funnel.lock: $(FILES)
	sleep 5
	touch $@
