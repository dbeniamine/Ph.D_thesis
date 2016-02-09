include common.mk
SUBDIRS=tikz

#Files
TEXSRC = $(wildcard *.tex)
BIBSRC = $(wildcard *.bib)
PDF = $(TEXSRC:.tex=.pdf)
AUX = $(TEXSRC:.tex=.aux)
BBL = $(TEXSRC:.tex=.bbl)
NLO = $(TEXSRC:.tex=.nlo)
NLS = $(TEXSRC:.tex=.nls)


#Commands + arguments
TEXCOMPILE = $(TEX) $(TEXSRC)
BIBCOMPILE = $(BIB) $(AUX)

.PHONY: $(SUBDIRS) clean distclean

$(SUBDIRS) :
	$(MAKE) -c $@


all : all-noclean


all-clean : clean bib-default finalize

all-noclean : bib-default finalize

$(PDF) : $(SUBDIRS) $(TEXSRC) $(TEXSUBSRC) $(BIBSRC) $(PDF)
	$(TEXCOMPILE)
	$(TEXCOMPILE)

bib-default : $(PDF) $(BIBSRC)
	$(BIBCOMPILE)

finalize : $(AUX) $(BBL)
	$(TEXCOMPILE)
	$(TEXCOMPILE)

clean: subclean
	rm -rf $(TEMP)
	for dir in $(SUBDIRS); do \
		$(MAKE) clean -C $$dir; \
	done

distclean: clean
	rm -rf $(PDF)
	for dir in $(SUBDIRS); do \
		$(MAKE) distclean -C $$dir; \
	done

