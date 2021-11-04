all: lib/something/native_vm/interpreted.so

%.so: %.c
	$(CC) -shared -o $@ $<

clean:
	rm -f lib/something/native_vm/*.so
