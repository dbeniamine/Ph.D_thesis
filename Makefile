# Files
TEXSRC = $(wildcard *.tex)
BIBSRC = $(wildcard *.bib)
PDF = $(TEXSRC:.tex=.pdf)
AUX = $(TEXSRC:.tex=.aux)
BBL = $(TEXSRC:.tex=.bbl)
BLG = $(TEXSRC:.tex=.bbl)

# Tikz Files
TIKZSRC = $(wildcard tikz/*.tex)
TIKZPDF = $(TIKZSRC:.tex=.pdf)

# Temporary files
TEMP=*.bbl *.blg *.synctex.gz *.aux *.toc *.ptc *.out *.lot *.lof *.log
# Tell make not to remove them
.INTERMEDIATE: %.bbl %.blg %.synctex.gz %.aux %.toc %.ptc %.out %.lot %.lof %.log


# Commands + arguments
TEX = pdflatex -interaction=nonstopmode -synctex=1
BIB = bibtex
TEXCOMPILE = $(TEX) $(TEXSRC)
BIBCOMPILE = $(BIB) $(AUX)

all : $(PDF)

# Finalize:
# Note that $(PDF) should only depends on $(BBL) and $(BBL) should depends on
# $(AUX) but as the last compilation re write $(AUX) if we do so, make will
# always think that we need to redo the $(BBL) and $(PDF) targets.
$(PDF) : $(AUX) $(BBL)
	$(TEXCOMPILE)
	$(TEXCOMPILE)

# Bibtex
$(BBL): $(BIBSRC)
	$(BIBCOMPILE)

# First compilation
$(AUX): $(TIKZPDF) $(TEXSRC) $(TEXSUBSRC)
	$(TEXCOMPILE)
	$(TEXCOMPILE)

# Tikz images
tikz/%.pdf: tikz/%.tex
	cd tikz; $(TEX) $(shell basename $^)

.PHONY: clean distclean

clean:
	rm -rf $(TEMP)
	cd tikz; rm -rf $(TEMP)

distclean: clean
	rm -rf $(PDF)
	rm -rf $(TIKZPDF)
