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
GLS = $(TEXSRC:.tex=.acr)



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
$(AUX): $(TEXALLSRC)
	$(TEXCOMPILE)
	$(TEXCOMPILE)

tests: $(PDF) testrefs testbib testfonts testpdfversion testcountpages testcountbib

testbib:
	[ `pdfgrep -c '\[\?\]' $(PDF)` -eq 0 ]

testrefs:
	[ `pdfgrep -c '\?\?' $(PDF)` -eq 0 ]

testfonts:
	[ -z "`pdffonts $(PDF) | awk '{print $$5}' | grep no`" ]

testpdfversion:
	[ "`pdfinfo $(PDF) | grep "version" | awk '{print $$3}'`" = "1.4" ]

testcountbib:
	[ `grep -c bibitem $(TEXSRC:.tex=.bbl)` -ge 70 ]

testcountpages:
	[ `pdfinfo $(PDF) | grep Pages | awk '{print $$2}'` -gt 110 ]


.PHONY: clean distclean

clean:
	rm -rf $(TEMP)

distclean: clean
	rm -rf $(PDF)
