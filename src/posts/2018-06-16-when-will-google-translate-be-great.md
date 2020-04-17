---
title: When will Google Translate be great? 
author: Noon van der Silk
---

I've been reading "[Surfaces and
Essences](https://www.amazon.com/Surfaces-Essences-Analogy-Fuel-Thinking/dp/0465018475/)" by Doug Hofstadter and Emmanuel Sander. 

<center>
<a href="https://www.amazon.com/Surfaces-Essences-Analogy-Fuel-Thinking/dp/0465018475/"><img src="/images/surfaces-and-essences.png" /></a>
</center>

You can essentially judge this book by it's cover: It argues that analogies
are the key technique we use to think and understand. I quite love this book,
in particular because it presents lots of interesting ideas for people
interested in the topic, and for people interested in AI and machine learning.

The reason I enjoy this book so much is because I think it presents a very
strong task for machine learning people to tackle; namely to build a system
that is capable of this analogical reasoning. One thing that's true of
**all** modern machine learning systems it that their knowlege is very
"narrow" and, almost all of the time, the bounds of it are determined
entirely before training.

In any case, we're focused right now on translation. Doug recently wrote about his thoughts here:
[The Shallowness of Google Translate](https://www.theatlantic.com/technology/archive/2018/01/the-shallowness-of-google-translate/551570/). 

I'm not going to go into a lot of detail here; I just want to track the
progress of a specific phrase that Doug and Emmanuel hvea in the book. They
started tracking it in 2004, and it being 2018 now; 14 years later! I wanted
to see how things had progressed.

Here's the complex paragraph (in French) and the task is to translate it into
English:

**Original**

> Parfois, le succès ne fut pas au rendez-vous. On a beau y penser très fort,
> le bon numéro ne sort pas forcément. Sagan prenait échecs d'auteur
> dramatique comme les revers casino, avec respect pour les caprices de la
> banque et du ciel. Il faut bien pedre un peu, pour mieux savourer la
> gagne du lendemain.  Qui ne l'a pas vue &laquo; récupérer &raquo; en quelques quarts
> d'heure les pertes de toute une nuit ne peut comprendre comme c'est
> joyeux de narguer le sort.


**Human-translation by Doug and Emmanuel**

> Sometimes things just didn't work out right; no matter how hard she wished for
> it, the dice simply wouldn't come up her way. But Sagan always took her
> failures as a playwright much as she took her gambling losses, acknowledging
> the arbitrary whims of the house and of divine fate. After all, everyone has
> to lose now and then, so that the next day's victory will taste all the
> sweeter. And if you never saw her win back a whole night's losses, often in
> well under an hour, you just can't have any idea of the glee she took in
> laughing in the face of destiny.

Then here are the translations over the years (the first two coming from the book
itself):

**Google Translate, 2004**

> Sometimes, success was not with go. One thinks of it in vain very extremely,
> the good number does not leave inevitable. Sagan took the failures of dramatic
> author like in the reverses of casino, with respect for the whims of the bank
> and the sky. It is necessary well to lose a little, for better enjoying gains
> it following day. Who did not see it "recovering" in a few fifteen minutes the
> losses of a whole night cannot include/understand as they is merry of narguer
> the fate.

_Verdict_: Terrible.


**Google Translate, 2009**

> Sometimes, success was not there. It was nice to think very hard, the proper
> number does not necessarily spell. Sagan took the failures as a dramatist such
> as backhand casino, with respect to the whims of the Bank and the sky. It must
> be losig a little, better enjoy the gains overnight. Who did not see "recover"
> in a few minutes lost a whole night can not understand how happy it is the
> sort of taunt.
 
_Verdict_: Still terrible.

**Google Translate, 2018**

> Sometimes the success was not there. We can think about it very well, the
> good number does not necessarily come out. Sagan took dramatic draftsman's
> chess like the casino setbacks, with respect for the whims of the bank and
> the sky. It is necessary to lose a little, to better savor the gain of
> tomorrow. Whoever has not seen her "recover" in a few quarters of an hour
> the losses of a whole night can not understand how happy it is to taunt the
> spell.

_Verdict_: _Still_ terrible, 14 years later!

It's very interesting to think about how to build systems that could
conveivably translate phrases like this "properly", by using the ideas
from the book.
