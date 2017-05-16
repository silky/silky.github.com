---
title: The Internet High 5 Machine Launched! 
author: Noon van der Silk
---

So a few days ago I put [The Internet High 5 Machine!](https://high5.cool)
live, finally!

It's been a few years in the making (it turns out the first commit I made was
in 2015.)

It started as a fun idea I had, for a way to share successes with friends
overseas. The idea would be that you both have a machine, and then you somehow
control their machine to give them a High 5, physically.

I let the idea sit for a while, and picked it up again as I was near the end
of my recent degree. 

My approach was to build the website and necessary tools in Haskell, so that I
had a concrete project with which to learn. I didn't know Haskell very well at
the time, so it seemed like a good opportunity.

I looked around at a few web frameworks, but I had previously played with
[Yesod](https://www.yesodweb.com/) to build
[super-reference](https://github.com/silky/super-reference), so I opted to go
with that. I actually still quite like Yesod, even though there are some more
innovative things ([servant](https://haskell-servant.github.io/)) that I think
I will explore in the future.

I would say I generally quite enjoyed the Haskell/Yesod experience, but I did
have to make a somewhat-inappropriate number of PRs to random projects to get
it all pulled together. In any case, it at least demonstrated to me that Yesod
is a stable foundation on which to build, and that the Haskell ecosystem is
very friendly and quite good to work with.

One of the main ways I made progress initially was to look at other
well-written Yesod projects, and for this purpose I found
[pi-base](https://github.com/jamesdabbs/pi-base.hs) completely invaluable.
Interestingly, their in the process of shifting to servant :)

I put together the core bit of "client-side" high5 code in Haskell as well,
and that's open source
[here](https://github.com/internet-high-five-machine/high5-driver). This
serves as a reference implementation of what I'm referring to as the "High 5
Protocol":

<!--
https://knsv.github.io/mermaid/live_editor/
sequenceDiagram
    participant Client
    participant  high5.cool
    Client->>high5.cool: connect "email@example.org" "token-goes-here"
    loop Healthcheck
        high5.cool->>+Client: ping
        Client->>-high5.cool: pong
    end
    opt High 5 Action
        high5.cool->>+Client: high5 1
        Client->>-high5.cool: high5-success | high5-failure
    end
-->

<div style='text-align: center'>
![Figure 1. A view of the High 5 protocol. The "Healthcheck" step only happens when
you've got the "receive" page open on the high5.cool website.](../images/high5-protocol-1.png)
</div>

This is a simply a list of expected conversations that you can have over a
websocket connection with the [high5.cool](https://high5.cool) website. If you
integrate anything with this protocol, you can activate it via the High 5'ing
action *on* the website.

One of the ideas that I can now completely check-off is that anyone can place
a "High 5 Me" button on their website (as I've now done on mine). I made a
setting in the website so that you can allow "anonymous" high 5s (those from
people not yet registered with the site). In this way, anyone who appreciates
anything you've done can give you feedback in a fun way!

There's some badges and other such things in the "[profile](https://high5.cool/profile/)" section of the
High 5 website.

If you have any feedback on the website, then send me an
[email](mailto:noonsilk@gmail.com); I'd love to hear from you! (Alternatively,
just send me a [High
5!](https://high5.cool/high5/754d8358-fe0b-5e5c-8407-beec85b1a603))

For the time being, I'll let the website site for a while and add a few
features that are missing; and hopefully we'll have some more things to
announce in a few months!
