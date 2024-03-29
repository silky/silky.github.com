---
title: Stepping down from SciRate maintainership
author: Noon van der Silk
date: 2022-03-29
---

#### Background

I can't remember when I first stumbled across [SciRate](https://scirate.com/).

I'd had a fascination with scientific papers
for many years, well before actually attending university (as a mature-age
student) and starting to learn more formally. I would store them in a
variety of ways, print them out and hang them up in my house; send them to
myself on a mailing list that I created just for that purpose, or a public
subreddit where I would post the papers I wanted to read, so I wouldn't forget
about them. Evidently, the "bookmarking" feature in the browser wasn't one I
found particularly useful.

Eventually, I discovered [JabRef](https://www.jabref.org/), which I used for
several years. I stored all the papers that I was interested in (at the time,
quantum computing), and learned all about bibliography management. I even
stored all the PDFs, and the metadata from the JabRef system, in git, horribly
offending bitbuckets storage limits by having a repository ~10GB in size (I
think it doesn't clone successfully anymore; it's been several years since
I tried.)

After some time I became tired with JabRef, and built my own (very very
terrible) reference management program: [super-reference](https://github.com/silky/super-reference).

Eventually, I discovered [SciRate](https://scirate.com/). I think the version
I found was called "SciRate 2". It was in the hands of Bill Rosgen. I got
incredibly excited and signed up immediately. Because the code was open-source
(I actually can't remember, but I think it might've been a personally-hosted git
 repository somewhere), I added possibly one of my first "impactful" changes:
MathJax support! This was neat; now we could see rendered math while reading
abstracts and titles! I think [arXiv.org](https://arxiv.org/) only added this
feature a few years ago.

But, aside from this very minor hacking on the code, I immediately started
finding SciRate actually useful! I could browse it every day; see which papers
would pop up, and track papers I was interested in. Fairly quickly, it became
a very addictive habit for me. I began to learn the time of day that it would
update, and made sure I would scour the website shortly after to browse the
"freshest" papers.

I did this for several years (actually, I only stopped recently, maybe a few
months ago). I read many papers (but not every one that I would "scite");
made several nice connections, and even used my personal SciRate data to teach
my first deep learning workshops. SciRate stuck with me as my interests varied
from quantum computing, theoretical physics, black holes, philosophy, AI, deep
learning, computer vision, generative art, category theory, astrophysics, and
the stranger maths papers. For a while my favourite thing was discovering the
"best paper title" of the week.

The most memorable moment was when, many years later (after the scirate3
re-write), I met people who "knew" me from SciRate, only because they had
seen that I would "scite" a lot of papers (in fact, someone told me that they
didn't think I was a real person; only a scite-making bot.) To date, [I've
amassed more than one hundred thousand "scites"](https://scirate.com/noonsilk).
And yes, most of this was done by clicking manually; but in the last year or
two I've used a custom program I wrote: [the
scirate-cli](https://github.com/silky/scirate-cli).

In any case, by a very strange coincidence, during my Masters program I
happened to learn that SciRate was undergoing a re-write, amazingly by a
company based in Melbourne (where I lived); just down the road from my
university!  I happened to have a conversation with the founder of that
company, [Ben Toner](https://bentoner.com/), relating to my masters project,
but it was a curious connection.

That re-write ended up going, in my view, quite well. But I think, at some
point, it stopped being funded, and fell on the shoulders of
[mispy](https://github.com/mispy-archive). Mispy funded SciRate for a while,
out of their own pocket, until I decided to take it over from them.

That was, now, 5 years ago.

All I've really been doing in the mean time is keeping things afloat.
Upgrading the various packages as is required; managing the server, and
the occasional bugfixes.

The only interesting thing I did, in recent times, was to [add a "jobs"
feature](https://github.com/scirate/scirate/commit/2e7ecbce9ee6db4d70d88597b61b6b2101968ba9)
to SciRate. This was actually moderately successful, but in the end it was
more effort for me to maintain than it was worth, so I disabled it.

#### Current

SciRate needs a new maintainer. I've decided that, personally, my focus has to
shift elsewhere. You can read about that in the [Addendum](#addendum) below.

Here's what you'll need to do:

1. Take ownership of the [scirate](https://github.com/scirate/scirate)
   repository,
2. Update the codebase occasionally, maintain deployments, fix the occasional
   bug,
3. Manage the error emails that come in,
4. Restart the server when it dies,
5. ???
6. **Extend it in interesting ways!**

The last one is actually quite important! SciRate has lacked any real new
features for a very long time; but there's certainly some interesting things
that could be done! Notable among them could be:

- [Support for "reading groups"](https://github.com/scirate/scirate/issues/366),
- [A recommendation engine](https://github.com/scirate/scirate/issues/382),
- ...?

The world is (somewhat) your oyster. Clearly there are some rules on how we'd
like SciRate to develop; after all, there is a solid and growing user base,
who have some expectation on how it will operate.

In any case, if you're interested in getting involved, reach out to
[Aram](https://web.mit.edu/aram/www) and myself by sending us an email:

- [noonsilk@gmail.com](mailto:noonsilk@gmail.com)
- [aram@mit.edu](mailto:aram@mit.edu)

We'd love to hear from you.

---

#### Addendum <a name="addendum"></a>

The central reason I've decided to stop spending time on SciRate is because of
the climate emergency. I've been reading [a lot of
books](https://betweenbooks.com.au/tags/climate.html) and it's become
increasingly important to me to spend my energy learning more and doing more
([or less!](https://en.wikipedia.org/wiki/Jevons_paradox)) in this space. If
you're interested in this too, then please reach out; I'd love to chat!
