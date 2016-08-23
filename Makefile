# Source files
TEXSRC = $(wildcard *.tex)
BIBSRC = $(wildcard *.bib)
# Additional sources
SUBDIRS=tex custom style
TEXSUBSRC = $(foreach d, $(SUBDIRS),$(wildcard $d/*.tex))
TEXALLSRC = $(TEXSRC) $(TEXSUBSRC)

# Intermediate files
PDF = $(TEXSRC:.tex=.pdf)
AUX = $(TEXSRC:.tex=.aux)
BBL = $(TEXSRC:.tex=.bbl)
GLS = $(TEXSRC:.tex=.GLS)



# Temporary files
TEMP=*.bbl *.blg *.synctex.gz *.aux *.toc *.ptc *.out *.lot *.lof *.log *.ist *.acn *.acr *.alg *.tdo *.loa *.lol
# Avoid removing temp files
.INTERMEDIATE: $(TEMP)

# Commands + arguments
TEX = pdflatex -interaction=nonstopmode -synctex=1
BIB = bibtex
GLOSSARY = makeglossaries
TEXCOMPILE = $(TEX) $(TEXSRC)
BIBCOMPILE = $(BIB) $(AUX)

all : $(PDF)

# Note that $(PDF) should only depends on $(BBL) and $(BBL) should depends on
# $(AUX) but as the last compilation re write $(AUX) if we do so, make will
# always think that we need to redo the $(BBL) and $(PDF) targets.
$(PDF) : $(AUX) $(GLS) $(BBL)
	$(TEXCOMPILE)
	$(TEXCOMPILE)

# Glossary
$(GLS): $(TEXALLSRC)
	$(GLOSSARY) $(TEXSRC:.tex=)

# Bibtex
$(BBL): $(BIBSRC) $(TEXALLSRC)
	$(BIBCOMPILE)

# First compilation
$(AUX): $(TEXSRC) $(TEXSUBSRC)
	$(TEXCOMPILE)
	$(TEXCOMPILE)

.PHONY: clean distclean

clean:
	rm -rf $(TEMP)

distclean: clean
	rm -rf $(PDF)
