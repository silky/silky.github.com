---
title: Some tools for working with Github upstream repos
author: Noon van der Silk
---

So at the last [MFUG](http://www.meetup.com/Melbourne-Functional-User-Group-MFUG/) Hack Night, I 
was convinced it was time to start hacking on [my dream](https://github.com/silky/ideas "git console dashboard idea") of a Github
dashboard-esque thing that would tell me when the various clones I had had
upstream changes.

So of course, the first thing I tried to do was to pick a programming
language. At first, we thought of a [Node](http://nodejs.org)-based local website. But I don't know
Node and I don't like JavaScript. It being a functional hack night, I next
considered [Elm](http://elm-lang.org) but stopped for two reasons: 

  1) The elm-lang website examples currently crash,
  2) I don't know Elm well enough (or at all, really.)

So I was stuck. I felt like the only way forward was a local-website
dashboard-like interface. I could do it in python, but I'd prefer to do it in
a functional language. But I didn't know any functional language well enough.
And the ideas for what the dashboard could do were getting numerous, making me
feel overwhelmed at the idea of actually implementing it (I really can only
afford to allocate a few short hours to this project.)


So in the end, I didn't get started, and left the evening having accomplished
nothing but having a good time talking to people - a pretty nice way to spend
the night, but disheartening because I came out of it with the same number
of programs that I went in with.

On the way home, on the tram, though, I thought perhaps a better place to
start was to think about exactly what I wanted to do, and write down a usage
plan for the tools that I felt I needed.

In the spirit of
Linux/[djb](http://cr.yp.to/djb.html)/[sordina](https://github.com/sordina), I
figured I'd try and have several self-contained programs, and then combine
them in various ways to get the result I wanted.

What I wanted was:

  1. A way to see if a repo I have forked has upstream changes,
  2. Merging these changes in, if I so wish.

It turns out in order to do this I thought I wanted a tool to clone all the
repositories I had on Github (I've forked a lot of things.) But in fact, after
I'd actually written the tool, `clone-all`, and used it, I realised I didn't
want a copy of all those repos locally, simply because there are too many.
Nevertheless, I've kept that one around incase someone else finds it useful.

The other tool, `infer-upstream`, turns out to be useful to derive the
upstream remote, and then I wrote a few bash scripts around it, to automate
the parts I wanted to automate.

So the tools turned out to be:

  * [clone-all](https://github.com/silky/clone-all) - Clones all the Github repos of a specific user,
  * [infer-upstream](https://github.com/silky/infer-upstream) - Determins the source repo of a fork,
  * [fetch_upstreams](https://github.com/silky/infer-upstream/blob/master/fetch_upstreams.sh) - Fetches upstreams of a series of directories, shows a short diff.

Happily, these three things turned out to be remarkably trivial to write, and
require almost no work on my part, aside from having to understand a bit of
Haskell. And I'm pretty happy about that, because I *do* have a little bit of
time to learn Haskell insofaras I think it'll be useful in the future.

clone-all
--

Let's have a look at what `clone-all` does:

````
noon@tmp>clone-all --help 
Usage: clone-all [DIRECTORY] (-u|--user ARG)

Available options:
  -h,--help                Show this help text
  DIRECTORY                Directory to clone everything into
  -u,--user ARG            Name of the user to clone the repos of.

noon@tmp>clone-all . -u cosilky 
Looking up repositories for cosilky ...
Found 1 repositories for cosilky.
1 that you don't already have.
Cloning into 'IPD_Morality'...
remote: Counting objects: 21, done.
remote: Compressing objects: 100% (15/15), done.
remote: Total 21 (delta 5), reused 21 (delta 5)
Receiving objects: 100% (21/21), 14.07 KiB, done.
Resolving deltas: 100% (5/5), done.

````

Unsurprising. Good.


infer-upstream
--

Consider
````
04:14 PM noon@tmp>infer-upstream --help 
Usage: infer-upstream (-r|--repo ARG) (-u|--user ARG)

Available options:
  -h,--help                Show this help text
  -r,--repo ARG            Name of the repository that we will look up.
  -u,--user ARG            Name of the user that we will look this repo up on.
````

So for example:

````
noon@tmp>infer-upstream -r scirate3 -u silky
git@github.com:draftable/scirate3.git
````

So it writes the upstream ssh url to stdout.


Putting them together
--

These two were the only Haskell programs I had to write. And infact,
they are heavily based on sordina's [Commando](https://github.com/sordina/Commando)
program, in terms of how they deal with parameters, etc, so not much work at
all was involved.

In order to accomplish my goal of having correct *upstream* remotes set, for
all my existing repositories, and then being able to get a nice status, it
remains only to write some bash scripts that loop around in my `dev`
directory, doing the appropriate things.

Indeed, this is what I have done in

  * [upstream_everything](https://github.com/silky/infer-upstream/blob/master/upstream_everything.sh)
  * [fetch_upstreams](https://github.com/silky/infer-upstream/blob/master/fetch_upstreams.sh)

The first script - `upstream_everything` - takes a directory, looks for those
folders which are git repositories, then assumes they are Github repositories
and tries to find a source for it, under the assumption it is a fork.
Supposing it finds a source, it creates a new `upstream` remote and moves on.
Supposing it doesn't, it does nothing.

The second script - `fetch_upstreams` - does the thing that I actually wanted:
It looks in the current folder, for a bunch of git repos, and fetches the
changes from the `upstream` remote, and tells you about the differences.

Example of it in action:

````
noon@dev>infer-upstream/fetch_upstreams.sh
fetching upstream for Javascript-Voronoi ...
 1 file changed, 2 insertions(+), 2 deletions(-)
fetching upstream for dogecoin ...
fetching upstream for git-big-picture ...
fetching upstream for Serpent ...
 2 files changed, 13 insertions(+), 11 deletions(-)
fetching upstream for rust ...
remote: Counting objects: 26, done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 26 (delta 13), reused 4 (delta 4)
Unpacking objects: 100% (26/26), done.
From github.com:rust-lang/rust
   0ae4b97..c12d3c0  auto       -> upstream/auto
   b1646cb..0ae4b97  master     -> upstream/master
 15 files changed, 385 insertions(+), 109 deletions(-)
fetching upstream for linux ...
 9737 files changed, 513118 insertions(+), 268283 deletions(-)
fetching upstream for oh-my-zsh ...
 309 files changed, 17219 insertions(+), 1084 deletions(-)
fetching upstream for idris-koans ...
 6 files changed, 103 insertions(+), 11 deletions(-)
fetching upstream for joblint ...
 26 files changed, 671 insertions(+), 325 deletions(-)
fetching upstream for python-quaec ...
 1 file changed, 1 insertion(+), 1 deletion(-)
fetching upstream for Commando ...
 5 files changed, 216 insertions(+), 98 deletions(-)
fetching upstream for scirate3 ...
 321 files changed, 9141 insertions(+), 4436 deletions(-)
fetching upstream for Life ...
 1 file changed, 10 insertions(+), 3 deletions(-)
````

Again, it's completely unsurprising, and ridiculously simple. But importantly,
it's *useful* to me, and does exactly what I want! For the moment I've decided
not to attempt to merge and push these changes automatically, but it's clear
that it would not be hard to add.

In the end, I'm very happy that I've actually finished this, and didn't end up
wasting weeks (or even a weekend!) on writing a big feature-full dashboard
that I would probably stop using.

Maybe you find these tools useful, maybe you don't! But at least I learned
some Haskell and had some fun!
