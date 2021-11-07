all: lib/something/native_vm/interpreted.so lib/something/native_vm/compiled.so

%.so: %.c
	$(CC) -shared -o $@ $<

clean:
	rm -f lib/something/native_vm/*.so
