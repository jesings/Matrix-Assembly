all: matrix.o draw.o edgy.o byte2str.o prgrid.o bresenham.o
	gcc -o matrix -lc -lgcc draw.o matrix.o edgy.o byte2str.o prgrid.o bresenham.o
	./matrix
	convert image.ppm image.png
	rm image.ppm
	display image.png
draw.o: draw.S
	gcc -c -g draw.S
matrix.o: matrix.S
	gcc -c -g matrix.S
edgy.o: edgy.S
	gcc -c -g edgy.S
bresenham.o: bresenham.S
	gcc -c -g bresenham.S
byte2str.o: byte2str.S
	gcc -c -g byte2str.S
prgrid.o: prgrid.S
	gcc -c -g prgrid.S
