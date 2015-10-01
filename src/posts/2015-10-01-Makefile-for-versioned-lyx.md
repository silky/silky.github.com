---
title: Versioned LyX documents
author: Noon van der Silk
---

Oftentimes one needs to write a document with math symbols in it. The standard tool of choice is some variant of TeX, either writing it online in one of the growing-list of collaborative editors:

 - [Overleaf](https://www.overleaf.com/)
 - [ShareLaTeX](https://www.sharelatex.com/)
 - [Authorea](https://www.authorea.com/)

But one program, that runs locally, that I can't stop using is [LyX](http://www.lyx.org/).

I really like LyX because of the "What-you-see-is-(pretty much)-what-you-get" nature of it.

One thing I wanted to share was a small technique that I used to get a version
number in all of the pdfs that I generated from my LyX documents. The idea was
that when I sent my document to obtain feedback from various interested
parties, I could easily see which version they had commented on.

What I wanted as a footer that would be included on every page, that contained the version number.

The approach is:

1. In the "LaTeX Preamble" setting of the LyX document, include (something like)

````
\usepackage{fancyhdr}
\pagestyle{fancy}
\cfoot{\tiny{|VERSION|}}
\rfoot{\thepage}
\rhead{}
````

2. Build your LyX documents by the command line with a `Makefile`. My `Makefile` looks like so:

````
BUILD_NUMBER_FILE := build-number.txt
BUILD_NUMBER      := $(shell cat $(BUILD_NUMBER_FILE))
BUILD_DATE        := $(shell date +%d%b%Y)
VER_STRING        := $(BUILD_DATE)-build$(BUILD_NUMBER)
LYXFILE           := coolness
TEMPDIR           := /tmp

all: pdf

# Switch in the new version number, compile with LyX and
# bring it here.
pdf: buildnumber
	sed "s/|VERSION|/$(VER_STRING)/g" $(LYXFILE).lyx >$(TEMPDIR)/$(LYXFILE).lyx
	lyx -e pdf2 $(TEMPDIR)/$(LYXFILE).lyx
	cp $(TEMPDIR)/$(LYXFILE).pdf .

# Build number file. Increment each build.
buildnumber:
	@if ! test -f $(BUILD_NUMBER_FILE); then echo 0 > $(BUILD_NUMBER_FILE); fi
	@echo $$(($$(cat $(BUILD_NUMBER_FILE)) + 1)) > $(BUILD_NUMBER_FILE)
````

3. Build with the `make` command and profit!

Note that there is a `build-number.txt` file that is incremented on each build,
so you don't need to do that manually.

I've put together a sample project [here](https://gist.github.com/silky/9accc6e6a5dbbc029669), so you can clone that gist and type `make` and see it in action!
