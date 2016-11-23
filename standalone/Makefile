include ../Makefile.inc

SRC=$(wildcard *.tex)
PDF=$(SRC:.tex=.pdf)

all: $(PDF)

%.pdf: %.tex
	$(TEX) $<

.PHONY: clean

clean:
	rm -rf $(TEMP)

distclean: clean
	rm -rf $(PDF)
