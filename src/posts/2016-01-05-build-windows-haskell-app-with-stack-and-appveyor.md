---
title: Building a windows-executable Haskell program with stack and AppVeyor
author: Noon van der Silk
---

In this post we'll see how to setup a CI build that generates Windows executables for stack-based Haskell projects.

So imagine you love Haskell and you have written a Haskell program, you've hosted it on [GitHub](https://github.com) and you've dilligently set up a CI build on [Travis](https://travis-ci.org) that uses [stack](https://github.com/commercialhaskell/stack) to build/test/etc.

Now, because stack is great and life is good, people can build your project from the source largely without issue. But suppose now that you'd like to provide Windows binaries for download. It so happens that we live in an age where this is completely automatable! Let's see how.

The essence of my approach is to use the CI system [AppVeyor](http://www.appveyor.com/) (essentially like a Travis for Windows), and the following `appveyor.yml` file (full file below, I'll go through details next):

~~~~ {.yaml .numberLines}
build: off

before_build:
- curl -ostack.zip -L --insecure http://www.stackage.org/stack/windows-i386
- 7z x stack.zip stack.exe
- sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules
# Appveyor doesn't clone recursively.
- git submodule update --init --recursive

skip_tags: true

build_script:
# Suppress output from stack setup, as there is a lot and it's not necessary.
- stack setup --no-terminal > nul
- stack build --only-snapshot --no-terminal
- stack --local-bin-path . install haskmas
# Set a magical environment variable
- cmd: for /f %%i in ('stack exec -- haskmas -v') do set HASKMAS_VERSION=%%i

artifacts:
- path: haskmas.exe

# Auto-deploy
deploy:
  - provider: GitHub
    tag: 'haskmas-$(HASKMAS_VERSION)'
    release: 'Release haskmas-$(HASKMAS_VERSION)'
    auth_token:
      secure: FZXhwa1ucQwyFtswv/XNUJkclAxoz4YGGu69dSOEEkwG7Rlh/Gho66SJtOUJ57kN
    artifact: haskmas.exe
    on:
      branch: master
~~~~

Details:

- Line 1 disables the _standard_ build process which would use MSBuild.
- Lines 3-8 obtain the stack executable, and also perform a small hack which converts my `ssh`-based git submodules to `https`-based ones, that can be cloned without needing to mess about with ssh keys.
- Line 10 prevents AppVeyor from building when it sees a new tag (later in the script we end up making a new tag when we push a release)
- Lines 12-16 perform the typical stack build, and also install the `haskmas.exe` file that we will mark as an artifact
- Line 18 is a magic command that sets the environmen variable `HASKMAS_VERSION` to the value of the output of the command `stack exec -- haskmas -v`. This is my "hack" to obtain the cabal-version of the `haskmas` library, which I use as part of the tag that gets released on the [GitHub releases page](https://github.com/silky/haskmas/releases)
- Line 21 simply marks the `haskmas.exe` as an artifact; this means AppVeyor will hang on to it after the build completes.
- and finally, lines 24-32 specify that, for each build that completes, AppVeyor should push a release with the tag `haskmas-<cabal_version_of_haskmas>` to the GitHub releases page! (Note: that probably we would want to be a bit more elaborate about when we push to the releases page; making sure that we include proper release notes, etc.)

You can see from the releases on the `haskmas` project istelf that I fumbled around with this setup a bit. Mostly I observed that the manual release process on AppVeyor doesn't quite operate the way I'd've [hoped](https://github.com/appveyor/ci/issues/593); but in any case AppVeyor is a pretty convenient service; it's very nice to see something for Windows in this space.

I based my configuration off of the one for the [stack tool itself](https://github.com/commercialhaskell/stack/blob/master/appveyor.yml). Note that there is some mention of caching in there that might speed up the build (my build takes ~17 minutes on AppVeyor compared to ~2 minutes on travis).

All-in-all, technical details about automatically pushing releases aside, AppVeyor+stack is a really nice way to build Windows binaries from exactly the same source as your linux binaries. The only outstanding item to do is to combine artifacts from travis and AppVeyor into a single entity that can be released dually; but on the other hand tooling could always be written to perform this semi-manually, from your working computer, when you are ready to release.

The repo is here: [haskmas](https://github.com/silky/haskmas). As a side benefit, I made the haskmas program take command line arguments to control how it operates! So now you don't need to compile it to get a tree of arbitrary depth!
