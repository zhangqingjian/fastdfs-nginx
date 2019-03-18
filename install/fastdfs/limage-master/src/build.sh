${X}gcc -c -O2 $C limage.c -I../lua-headers
${X}gcc *.o -shared -o ../bin/clib/$D -L../bin/ $L
${X}ar rcs ../bin/$A *.o
rm *.o
