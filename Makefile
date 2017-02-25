# General Makefile for LaTeX projects
#
# Makefile or makefile? The manual of GNU make says: "We recommend Makefile
# because it appears prominently near the beginning of a directory listing,
# right near other important files such as README." (GNU make Manual p. 12).
#
# To avoid trouble on systems where the SHELL variable might bei inherited
# from the environment. This is never a problem with GNU make, but the GNU
# make Manual recommends this setting (p. 149).
SHELL = /bin/sh

# subfolders of the project
# FIGURES: contains the jpg and eps files. The jpg files are source files and the according eps files
# will be automatically generated or updated. Never change a eps file directly!
# SOURCE: for includet tex files.
# SHELF: documentations, source material (articles)
# ISHELF: like SHELF, but material, that NOT WILL BE in the dist!
FIGURES := figures
SOURCE := source
SHELF := shelf
ISHELF := shelfignore

# Different make programs have incompatible suffix lists and this sometimes
# creates confusion (GNU make Manual, p. 149). The suffix list is set
# explicitly using only the suffixes needet in this Makefile.
.SUFFIXES:
.SUFFIXES: .tex .bib .eps .jpg .pdf .dvi

# Variables for the main file, includet tex files and the bib file
MAIN := main
BIBCHECK := bibcheck
SOURCES :=  $(wildcard $(SOURCE)/*.tex)
BIBF := $(wildcard *.bib)

# ESSENTIALS are tex files, that are special, includet directly in main.
# BIBESSENTIALS is a subset, includet in bibcheck.tex
BIBESSENTIALS := $(addsuffix .tex,preliminaries bibliography)
ESSENTIALS := $(addsuffix .tex,title abstract macros) $(BIBESSENTIALS)


# grouping the subfolders.
DIRS := $(FIGURES) $(SOURCE) $(SHELF)
DIRSNB := $(ISHELF)

# put list of all picture files in JPG (simple variable)
# ToDo: other file format (pdf, eps, tif) are ignored.
# ToDo: a lot of the jpg files are not used (not included). 
JPG := $(wildcard $(FIGURES)/*.jpg)
EPS := $(JPG:%.jpg=%.eps)

# Variables for auxilliary files
README := Readme.md
GITIG := .gitignore
MKFILE := Makefile
AUXFILES := $(GITIG) $(README) $(MKFILE)

# variables to represent external programs.
PDFLATEX := pdflatex
PDFLATEXFLAGS := -interaction=batchmode
BIBTEX := bibtex 
OPEN := open
ECHO := echo
CONVERT := convert

# With this option (-p) specified, no error will be reported if a directory
# given as an operand already exists.
MKDIR := mkdir -p

# Option -f "forces" a delete, i.e. doesn't error out if the file didn't exist.
# Option -r deletes recursive (for removing directories).
RM := rm -f
RMDIR := rm -rf

# Forming the name of the tarball: Composed of the name of the current
# directory (= project name) and a string for representing the
# actual date and time in a compressed form (at the expend of some
# readability). The name of the tarball will finally be in the form of
# "make_latex-20160315-211620.tar.gz". When GNU make starts it sets the
# variable CURDIR to the pathname of the current working directory (GNU make
# Manual p 51).
TIMESTAMP := $(notdir $(patsubst %/,%,$(CURDIR)))-$(shell date +"%Y%m%d-%H%M%S")

all: $(MAIN).pdf $(BIBCHECK).pdf $(EPS)

# Generate the pdf file. With a bibliograpy file (bib file), four steps are
# needet (Joachim Schlosser: Wissenschaftliche Arbeiten schreiben mit LaTeX,
# S. 170).
# 1. compile the tex file, extracting the bibliogrpahy references
# 2. solve the references with BibTeX
# 3. compilie the tex file and include the bibliography
# 4. compile the tex file and include the references 
#
# If no bib file exists, then the bibtex and consecutive pdflatex runs are not
# necessary. ToDo: not testet yet a situation when more than one bib files are
# present (e.g. in case the variable BIBF contains a list of files rather then
# one file). Maybe it will need the make function "firstword"?
$(MAIN).pdf: $(MAIN).tex $(JPG) $(BIBF) $(SOURCES) $(ESSENTIALS)
	@$(PDFLATEX) $(PDFLATEXFLAGS) $(MAIN).tex
ifneq ("$(wildcard $(BIBF))","")
	-$(BIBTEX) $(MAIN)
	@$(PDFLATEX) $(PDFLATEXFLAGS) $(MAIN).tex
	@$(PDFLATEX) $(PDFLATEXFLAGS) $(MAIN).tex
endif
	@$(OPEN) $(MAIN).pdf


# Generate the bibcheck.pdf
# BIBESSENTIALS are a subset of ESSENTIAL
$(BIBCHECK).pdf: $(BIBCHECK).tex $(BIBF) $(BIBESSENTIALS)
	@$(PDFLATEX) $(PDFLATEXFLAGS) $(BIBCHECK).tex
	-$(BIBTEX) $(BIBCHECK)
	@$(PDFLATEX) $(PDFLATEXFLAGS) $(BIBCHECK).tex
	@$(PDFLATEX) $(PDFLATEXFLAGS) $(BIBCHECK).tex
	@$(OPEN) $(BIBCHECK).pdf

# For main.tex without external tex files or not all external tex files
# as defined in ESSENTIALS hier a "dummy target" with only a printed
# message.
$(ESSENTIALS):
	@$(ECHO) "File <$@> don't exist. Fake entry in 'Makefile'."

# Encapsulate all jpg files in a eps file.
# For include the graphic files with latex.
$(EPS): $(JPG)
	@$(CONVERT) $? eps2:$@

clean:
	$(RM) *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.lot *.lol *.bbl *.blg

distclean: clean
	$(RM) *.pdf *.dvi $(EPS)

# Updates the timestamp of the source files (LaTeX and bib files). For testing
# purposes only. This is an other way to force a compile run. I've build this
# (my first phony target!) before I heard of the -W or --what-if flag of make.
touch:
	touch *.tex *.bib

# Make folders
init: $(DIRS) $(DIRSNB)

$(DIRS) $(DIRSNB):
	$(MKDIR) $@

# $(ISHELF):
#	ECHO "Test" >> $(ISHELF)/shelfignore-info.txt


# Make a tarball with source files (tex, bib), auxilliary AUXFILES (e.g.
# .gitignore, README.md, Makefile) and the jpg files. The variable TIMESTAMP
# is a simple variable (see make GE-PACKT, p. 34). Allocated with := and will
# be set only once. The shell comand lines will do:
# 1. Make a new directory. Name it with a timestamp.
# 2. copy all the source files and auxilliary files (AUXFILES) in the new directory
# 3. copy the jpg files in the directory $(FIGURES) in the new directory
# 3. Make a tarball
# 4. Remove the directory (-r recursive, -f force)
dist:
	$(MKDIR) $(TIMESTAMP)
	-rsync -a *.{tex,bib} $(AUXFILES) $(TIMESTAMP)
	-rsync -r --exclude=*.eps $(DIRS) $(TIMESTAMP)
	tar -czf $(TIMESTAMP).tar.gz $(TIMESTAMP)
	$(RMDIR) $(TIMESTAMP)

# Running git init in an existing repository is safe.
# (see: https://git-scm.com/docs/git-init) 
gitin:
	@git init
ifeq ("$(wildcard $(GITIG))","")
	@$(ECHO) "Create new $(GITIG)."
	@$(ECHO) 'selfignore/' >> $(GITIG)
	@$(ECHO) '*.eps' >> $(GITIG)
else
	@$(ECHO) "$(GITIG) already exists: doing nothing."
endif

gitco:
	@git add .
ifeq ("$M","")
	@git commit -m "Add minor fix"
else
	@git commit -m "$M"
endif

help:
	@$(ECHO) Type "'make help'         to see this list"
	@$(ECHO) Type "'make init'         to make (initialize) the folders $(DIRS)"
	@$(ECHO) Type "'make distclean'    to remove ALL generated files"
	@$(ECHO) Type "'make clean'        to remove generated auxilliary files"
	@$(ECHO) Type "'make dist'         to make a archive with all source files"
	@$(ECHO) Type "'make touch'        to update timestamp of source files (tex, bib)"
	@$(ECHO) Type "'make gitin'        to initialize a git repo with .gitignore file" 
	@$(ECHO) Type "'make gitco'        to commit a small fix, optional add M='Commit-Message'" 
	@$(ECHO) Type "'make -W $(MAIN).tex'  to force a compile run"

# Übliche Pseudoziele gemäss "make ge-packt", S. 159.
.PHONY: all clean distclean touch init dist help gitin gitco
