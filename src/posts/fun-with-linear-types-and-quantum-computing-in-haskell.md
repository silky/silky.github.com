---
title: Fun with linear types and quantum computing in Haskell
author: Noon van der Silk
date: 2021-05-05
---

When the [linear
Haskell](https://www.tweag.io/blog/2020-06-19-linear-types-merged/) extension
was announced, I got excited and started playing around with
[linear-base](https://www.tweag.io/blog/2021-02-10-linear-base/). 

While the linear haskell paper suggests a few ways to use linear types, one of
the must fun ideas to me is to use it for expressing quantum algorithms.

The background is that a theorem, the [No-Cloning
Theorem](https://en.wikipedia.org/wiki/No-cloning_theorem), constrains how
variables in quantum algorithms can be used.

The game, then, is can linear types in Haskell help enforce this rule? Turns
out, yes! Let's have a look:

``` haskell
let a = 2
```
