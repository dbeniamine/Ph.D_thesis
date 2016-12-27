include Makefile.def
# Source files
TEXSRC = $(wildcard *.tex)
BIBSRC = $(wildcard *.bib)
# Additional sources
SUBDIRS=tex custom style tikz
TEXSUBSRC = $(foreach d, $(SUBDIRS),$(wildcard $d/*.tex))
TEXALLSRC = $(TEXSRC) $(TEXSUBSRC)
AUX = $(TEXSRC:.tex=.aux)
STANDALONESRC=$(wildcard pgf/*.tex)
STANDALONES=$(STANDALONESRC:.tex=.pdf)

# Commands + arguments
MAIN=thesis.pdf
SLIDES=slides.pdf
PDFS= $(MAIN) $(SLIDES)

all : $(PDFS)

presentation: $(SLIDES)
	killall redshift
	caffeinate pdfpc $(PDFPCARGS) -d 0 $<
	redshift-gtk &

$(STANDALONES):
	make -C pgf

# Note that $(PDF) should only depends on $(BBL) and $(BBL) should depends on
# $(AUX) but as the last compilation re write $(AUX) if we do so, make will
# always think that we need to redo the $(BBL) and $(PDF) targets.
%.pdf : %.tex  $(TEXSUBSRC) %.aux %.bbl $(STANDALONES)
	if [ $@ = $(MAIN) ]; then \
		$(GLOSSARY) $* ; \
		fi
	$(TEX) $*.tex
	$(TEX) $*.tex
	$(TEX) $*.tex

# Bibtex
%.bbl: $(BIBSRC) $(TEXSUBSRC)
	$(BIB) $*.aux

# First compilation
%.aux: %.tex $(TEXSUBSRC)
	$(TEX) $*.tex
	$(TEX) $*.tex

tests: $(PDFS) testbadspace testrefs testbib testbibtex testplaceholders testreffloats testfonts testpdfversion testcountpages testcountbib

testbadspace:
	@echo "Looking bad spaces '\ u8'"
	[ -z "`grep " " $(TEXALLSRC)`" ]
	@echo "PASSED"

testbibtex:
	@echo "Looking for Warnings in bibtex compilation"
	for f in $(AUX); do \
		[ `$(BIB)  $$f | grep -c "^Warning"` -eq 0 ] ;\
		done
	@echo "PASSED"

testbib:
	@echo "Checking for bad citations"
	for f in $(PDFS); do \
		[ `pdfgrep -c '\[\?\]' $$f` -eq 0 ] ; \
		done
	@echo "PASSED"

testrefs:
	@echo "Checking for bad references"
	for f in $(PDFS); do \
		[ `pdfgrep -c '\?\?' $$f` -eq 0 ]; \
		done
	@echo "PASSED"

testfonts:
	@echo "Checking that all fonts are embedded"
	for f in $(PDFS); do \
		[ -z "`pdffonts $$f | awk '{print $$5}' | grep no`" ]; \
		done
	@echo "PASSED"

testpdfversion:
	@echo "Checking version of the produced pdf"
	for f in $(PDFS); do \
		[ "`pdfinfo $$f | grep "PDF version" | awk '{print $$3}'`" = "1.4" ]; \
		done
	@echo "PASSED"

testplaceholders:
	@echo "Checking for remaining placeholders"
	for f in $(PDFS); do \
		[ `pdfgrep -c '<\+\+>' $$f` -eq 0 ]; \
		done
	@echo "PASSED"

testcountbib:
	$(eval BITEMS=$(shell grep -c bibitem $(MAIN:.pdf=.bbl)))
	@echo "Total bibliographic entries: $(BITEMS)"
	[ $(BITEMS) -ge 70 ]
	@echo "PASSED"

testcountpages:
	$(eval PAGES=$(shell pdfinfo $(MAIN) | grep Pages | awk '{print $$2}'))
	@echo "Total pages: $(PAGES)"
	[ $(PAGES) -gt 120 ]
	@echo "PASSED"

testreffloats:
	@echo "Checking if floats are correctly referenced"
	[ `pdfgrep -o "(Table|Figure|Listing|Algorithm) [0-9]\.[0-9]*" thesis.pdf | sort | uniq -c | awk '{if($$1<2){print $$0}}' | wc -l` -eq 0 ]
	@echo "PASSED"


.PHONY: clean distclean

clean:
	rm -rf $(TEMP)
	make -C pgf clean

distclean: clean
	rm -rf $(PDFS)
	make -C pgf distclean
