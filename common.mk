# Common makefile variables
#Commands
TEX = pdflatex -interaction=nonstopmode -synctex=1
BIB = bibtex
TEMP="*.tdo *.idx *.nlo *.log *.lof *.lot *.bbl *.blg *.thm *.pdf *.aux *.backup *.bak *.toc *.out *.ilg *.nls *~ .*~ img/*eps-converted-to.pdf *.ml*  *.mt* *.ma* *.pt* *.pl* *.synctex.gz"


.PRECIOUS: *.tdo *.idx *.nlo *.bbl *.blg *.pdf *.aux *.toc *.out

.PHONY:


