---
title: Autosave Mathematica files for undo purposes
author: Noon van der Silk
---

Anyone who has used Mathematica[^1] for more than 5 minutes probably knows
that the undo functionality will leave you feeling pretty sad. You can very
quickly find yourself having deleted something that you wanted to keep, and
having Control-Z completely ignore your requests to go back in time.

I was complaining about this on Google+ a while back when I realised that
there is a very easy solution - Autosave copies of your Mathematica files
somehow, and then rollback to a different version if you want one!

"Brilliant", I thought, I'll just write a Mathematica plugin to do this! Ah,
but infact it turns out I can be even lazier than that, and get this
functionality entirely outside of Mathematica, and I can use Haskell and
git in the process (you aren't really having fun until you use Haskell to
solve a minor inconvenience.)

So I happened to have the following programs installed, which are used to
monitor a folder for file changes and to run actions upon file changes,

  * [Commando](https://github.com/sordina/commando)
  * [Conscript](https://github.com/sordina/conscript)

So step (1) is to install these.  Step (2) is to install [git](http://git-scm.com) (or some other
source control system, it doesn't matter which).

Step (3) is to now edit all your Mathematica files in some special directory;
I've chosen `~/mathematica_working`. So I've turned this into a git repository
with `git init`, and then I have the following two scripts in the folder:

``` shell
# start.sh
commando -c echo | grep --line-buffered '.nb' | conscript ./autosave.sh
````

``` shell
# start.sh
git add . && git commit -m "Auto-save."
````

and every time I start working on some Mathematica files, I run `./start`.
This begins tracking changes.

Now, every time I save a document in Mathematica, this setup auto-commits it.
The output in this terminal looks something like this, depending on what you
change:

````
[master eded096] Auto-save.
 1 file changed, 1 insertion(+), 1 deletion(-)
````

So now I have a nice history of changes to Mathematica files. If I
accidentally delete a big chunk of code, or just want to see what I used to
have, I can use all the machinery that the source-control system makes
available to me! And because the Mathematica files are in a plaintext format,
it's not impossible to review the diffs meaningfully! (It's not exactly
amazingly-pleasant though.)


[^1]: This comment based on usage of version 8.
