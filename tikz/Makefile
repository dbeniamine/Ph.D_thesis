include ../common.mk

TIKZSRC = $(wildcard *.tex)
TIKZPDF = $(TIKZSRC:.tex=.pdf)

all: $(TIKZPDF)

%.pdf: %.tex
	$(TEX) $^

clean:
	rm -rf $(TEMP)

distclean: clean
	rm -rf $(TIKZPDF)
