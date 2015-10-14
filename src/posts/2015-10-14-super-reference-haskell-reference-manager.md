---
title: Super Reference! Web Haskell-based reference management
author: Noon van der Silk
---

Today I'm announcing a (very) alpha version of my web-based reference management system, [super-reference](https://github.com/silky/super-reference)!

Super-reference is a system which:

 1. Reads a bibtex file and lets you search the bibtex entries in it
 2. Provides an interface to open associated PDFs or visit associated links
 3. Maintains a list of 'currently reading' PDFs by synching a folder (for me, a dropbox folder)

Here's a screenshot of the main (only) page:

![](https://raw.github.com/silky/super-reference/master/screenshot.png)

About
--

Super-reference is built around my workflow for getting the latest papers.

A high-level overview of my workflow is:

 1. Find an interesting paper
 2. Obtain the pdf file for this paper, (preferably from [arXiv](https://arxiv.org))
 3. Save this pdf on my computer, and get the `bibtex` data for the file somehow
 4. At some point in the future, be interested in finding this PDF by searching for the title, or browsing through a list

All the while I'd like to maintain a list of "papers I'm currently reading" and have them available on my tablet.

Items 1-3 take place *outside* of super-reference. My workflow for finding new papers and saving them on my computer is a little specialised, but happily you don't need to follow this protocol if you want to get utility out of super-reference --- you simply need a `bibtex` file to point it at.

Here's my new paper obtaining workflow (yours may be different):

 1. Browse [SciRate](https://scirate.com) regularly, and "scite" interesting papers
 2. Periodically run [scirate3_scaper](https://github.com/silky/scirate3_scraper) to bring down all the papers I've scited recently, and their bibtex entries
 3. Combine all these bibtex entries ino my *One True* bibtex file

Using super-reference
--

Let's suppose now you have a *One True* bibtex file called `all.bib`.

Grab yourself down a copy of the repository by following the [instructions](https://github.com/silky/super-reference/README.md).

Once you have the environment set up you can run a dev server with `yesod devel`. You will then be able to visit the website! Supposing you pointed the config file at your `all.bib` file, you will then be looking at all your interesting papers! If there's a link associated with the entry, a link will be displayed, and if there is a PDF file, clicking on the entry name will open the PDF (with it's location given by the `file` entry in the relevant bibtex entry).

You can click the `star` link to move the PDF up into the "currently reading" section. (Note: At the moment there is no visual indication of this, but it will be shown next time the page loads.)

Improvements
--

Currently there is a lot of outstanding work to do on super-reference; but it's in a working
state for me, so I thought I should release it.

If you have any feature requests/improvements/etc feel free to log an issue (or a
pull request) over at the repository: [super-reference](https://github.com/silky/super-reference).

