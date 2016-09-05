# Source files
TEXSRC = $(wildcard *.tex)
BIBSRC = $(wildcard *.bib)
# Additional sources
SUBDIRS=tex custom style tikz
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

tests: $(PDF) testbadspace testrefs testbib testbibtex testplaceholders testfonts testpdfversion testcountpages testcountbib

testbadspace:
	@echo "Looking bad spaces '\ u8'"
	[ -z "`grep " " $(TEXALLSRC)`" ]
	@echo "PASSED"

testbibtex:
	@echo "Looking for Warnings in bibtex compilation"
	[ `$(BIBCOMPILE) | grep -c "^Warning"` -eq 0 ]
	@echo "PASSED"

testbib:
	@echo "Checking for bad citations"
	[ `pdfgrep -c '\[\?\]' $(PDF)` -eq 0 ]
	@echo "PASSED"

testrefs:
	@echo "Checking for bad references"
	[ `pdfgrep -c '\?\?' $(PDF)` -eq 0 ]
	@echo "PASSED"

testfonts:
	@echo "Checking that all fonts are embedded"
	[ -z "`pdffonts $(PDF) | awk '{print $$5}' | grep no`" ]
	@echo "PASSED"

testpdfversion:
	@echo "Checking version of the produced pdf"
	[ "`pdfinfo $(PDF) | grep "version" | awk '{print $$3}'`" = "1.4" ]
	@echo "PASSED"

testplaceholders:
	@echo "Checking for remaining placeholders"
	[ `pdfgrep -c '<\+\+>' $(PDF)` -eq 0 ]
	@echo "PASSED"

testcountbib:
	$(eval BITEMS=$(shell grep -c bibitem $(TEXSRC:.tex=.bbl)))
	@echo "Total bibliographic entries: $(BITEMS)"
	[ $(BITEMS) -ge 70 ]
	@echo "PASSED"

testcountpages:
	$(eval PAGES=$(shell pdfinfo $(PDF) | grep Pages | awk '{print $$2}'))
	@echo "Total pages: $(PAGES)"
	[ $(PAGES) -gt 110 ]
	@echo "PASSED"

.PHONY: clean distclean

clean:
	rm -rf $(TEMP)

distclean: clean
	rm -rf $(PDF)
