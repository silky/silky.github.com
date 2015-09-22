---
title: GHCi Colouriser
author: Noon Silk
---

Behold, a colourful GHCi ([install it for yourself](https://github.com/silky/ghci-color)):

![](https://raw.github.com/silky/ghci-color/master/cap2.png)

This is done by using a simple little `sed` wrapper around the ordinary `ghci --interactive`,
see [here](https://github.com/silky/ghci-color/blob/master/ghci-color) for the script.

Note in particular the quirk that we must capture any `SIGINT` that gets sent through and discard it, when we are invoking `sed`, otherwise `sed` itself will quit and our GHCi session will break.

You can use it `cabal repl` (being mindful of [this bug](https://github.com/haskell/cabal/issues/1905)) by using `cabal repl --with-ghc=ghci-color`. I've bound an alias `repl` to this.
