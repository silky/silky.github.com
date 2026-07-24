---
title: Make Reviews Possible Again With This One Simple Trick
author: Noon van der Silk
date: 2026-07-24
---

You probably already know what it is: stacked PRs.

But first, let's discuss the problem.

### AI-generated code is hard to review

Pretty much everyone using AI has this problem at the moment; it's moderately
easy to generate code that is mostly coherent, mostly tackles the problem
you're solving, and in fact it's so easy, we mostly get a little over-excited
and do too much at once.

This is creating stress on the reviewers, on several fronts. There's just the
plain apathy of staring a giant diff that _probably_ does what the author
says, _even_ passes your test suites, but also _probably_ contains some
quirky/not-your-codebase's-idiom things that you'd challenge if you were
motivated.

There's also the loss of knowledge; it's just straight-up extremely difficult
to read such large pieces of work and understand everything. Especially when
you can't totally trust that every line and comment comes from some deep
fundamental understanding of the (human) author.

There's many other problems; not all of which will be addressed by this idea;
but the key idea here that we will go for is: less is better.


### Standard techniques

There are many and ever-growing techniques to deal with this problem:

1. *Just add more tests*: Theory is, if it works then It Works. This can be
   risky or great, depending on your testing infrastructure. But we all know
   that tests don't cover everything that it's possible to express with code.

2. *Just do less*: Just have smaller PRs. This is hard, because it seems modern
   AI systems tend to be a little bit purposefully addictive/gamified: they're
   often finding new things to do while doing a piece of work. It's also at
   odds with most work pressures: deliver more better faster.

3. *Group-reviews*: Get everyone on a call (or in person?!), and talk through
   the code. This can be useful, but you can't do it for everything. Also, it
   doesn't work for some team members and thinking styles.

4. *Author and merger responsibility*: You can just make a declaration, that,
   say, if a (big) PR is found to introduce a bag big or some misunderstanding,
   you just fire the author the and merger. Or maybe something less drastic,
   like downvote them on their performance reviews. In any case, this one is
   punitive and pressure-based. It makes authors and reviewers _more_ nervous;
   and doesn't really empower them in any meaningful way. Ultimately, it will
   just slow you down, and upset people.


### An old idea: create stacked branches

I'm not inventing stacked branches here. Many many people love them, there's
[jj](https://docs.jj-vcs.dev/latest/), created in part to get more joy from
them, and [startups](https://www.ersc.io/) focused around the idea.

A stacked branch is conceptually simple:

- Think about the large bit of work you did,
- Break it into (coherent) chunks (each one perhaps passing CI alone),
- Create a branch per chunk,
- Have each branch depend on the prior one: 1 ← 2 ← 3 ← ...
- Submit them as PRs in that order

Now, you have each coherent change readable by itself; they can be merged in
order, and everything will be fine.

You can read more [here](https://gist.github.com/thoughtpolice/9c45287550a56b2047c6311fbadebed2).


### The new workflow

Manually maintaining stacked branches is a little annoying. Yes you can use `jj`;
but then you have to learn to use `jj`, convince everyone in your team to
learn it, and _still_ do manual busywork.

Alternatively, you can try and predict all the changes you're likely to make,
make individual branches and just keep switching around. This is of course
extremely inconvenient and annoying.

But, happily, _creating_ stacked branches from a single monolithic branch is
fairly mechanical, boring, easy to describe, ...
What a great use-case for your AI tooling then!

So the new workflow is simply this:

1. Create a branch (`some-performance-work`),

2. Hack liberally,

3. Ask your AI something like:

   > Can you reframe this work into a sequence of stacked PRs. Try and
   > categorise all the changes into 4-5 chunks, and then make branches based
   > on that. Please number the branches like `some-performance-work-1`.

4. Push all the branches and create the PRs.

5. Bask in the joy of simple reviewing

I've been experimenting with this a little, and it works quite well! Note that
in my particular workflow, I wait until I've done the entire piece of work,
and split it after the fact. Splitting it before requires a bit more `jj`
busywork than I care to get into at the moment.


### Open questions and downsides

Here's a dot-point list of open questions, downsides, and trivia to think
about.

- GitHub's UI is annoying for stacked PRs: They should thread them, like Gmail
  did back in the day. It would be so much nicer. There's a world of
  improvements alternative source-control companies could make here that would
  make this all so much more pleasant.

- CI could be super annoying/wasteful/slow: Depending on what you do, you
  might accidentaly waste hours on rebuilds with this style. One should spend
  some time thinking about it. (Advertisement: Actually, I think this is an
  interesting open area of research, and if you're struggling with it or
  want to talk more, reach out to me via [Invariant.Club](https://invariant.club/)!)

- Atomic stacking: Perhaps you shouldn't have the first one merge direct to
`main`, you should instead target it to some `xxx-stacked` _new_ branch,
  that's based on `main`, but allows you to do some final re-orgs as you go.
  Otherwise, you tend to need to merge _every step_ of a stacked branch set
  basically at the same time, because you want coherence and mostly these
  things are coherent only once _everything_ is complete; i.e. if you merge
  steps 1-4 of a 5-step stack, do you actually _need_ all those steps if you
  reject step 5? Targetting a new branch gives you some flexibility here. It
  also gives you a final clear PR history that shows before-and-after
  benefits; something you might not get depending on how you merge otherwise.

  Further, you might also want to protect your merged stack queue from being
  interrupted by some other unrelated merge to the `main` branch, that happens
  while you're merging your stack.

- It's easier post-fact: I personally find it hard to do this from the start.
  In fact one could argue, if I could do it from the start, I'd have separate
  PRs already!

- Maybe learn `jj`, or maybe don't worry. It's probably very useful to master
  `jj` if you want to get into this more. But don't let _not_ mastering it
  stop you from benefiting now.

### Conclusion

In general, there's a wide world to explore in this domain of AI-assisted work
partitioning for efficient review and compilation. Looking forward to seeing
more work in this area!
