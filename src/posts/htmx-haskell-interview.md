---
title: "HTMX and Servant: Seamless and powerful handling of HTTP errors in HTMX"
author: Noon van der Silk
date: 2024-05-06
---

As part of the interview process for a company I was recently rejected by, I
wrote a blog post about HTMX and Haskell (and, JavaScript, but that was just a
requirement :D).

I think the post is interesting in any case, so here it is :) The Haskell
component is in the `Bonus content`. If you want to skip straight to the code,
you can just go direct to the repo:
[htmx-servant-js-example](https://github.com/silky/htmx-servant-js-post).

# Seamless and powerful handling of HTTP errors in HTMX

[HTMX](https://htmx.org/) is a popular front-end JavaScript library that can
be used to create simple dynamic UIs. But how robust is it? Is it ready for
production use? And what are its features, anyway? Let's explore it
together by building an image conversion app.


## Problem

You are building a dynamic UI and calling endpoints that will either fail or
return some content to render. You want to handle both these cases with the
simplest code possible.

A typical workflow somewhere in your code is to query the endpoint, check the
status of what happened, and act accordingly:

```javascript
fetch(url)
  .then( (result) => {
    if (result.ok) {
      // Everything is good!
    } else {
      // Something else ...
    }
})
```

It's a bit of a hassle to write this logic all over the place. Can HTMX help
us out here? How does it look for something non-trivial, and what are the
caveats we should be aware of?

## Solution

Let's take the example of uploading an image and converting it from a PNG to a
JPG.

Naturally, HTMX can do the happy-path, when there are no errors, easily. We
define the form, with the [HTMX attributes](https://htmx.org/reference/) to
define how the DOM changes based on the result:

```html
<!-- index.html -->
<script src="https://unpkg.com/htmx.org@1.9.11"></script>
...
<body>
  <form
    hx-encoding="multipart/form-data"
    hx-post="/upload"
    hx-target="#result"
    hx-swap="innerHTML"
    >
    <input type="file" name="image" accept="image/png" />
    <button>Upload</button>
  </form>
  <div id="result"></div>
</bod>
```

On the server, at the `/upload` route, we return an HTML element:

```javascript
// server.js endpoint definition
app.post("/upload", async function(req, resp) {
  // image conversion steps; new image in `newPath`.
  // ...
  // send the resulting path back as an "img" tag
  resp.send(`<img src="${newPath}" />`);
  });
```

Here's what it looks like:

<center><img width="600" src="/images/happy-path.gif" /></center>

It's interesting to note:

- It looks pretty smooth!
- We tell HTMX which element to update (via a CSS selector) with `hx-target`,
- We tell it how with [`hx-swap`](https://htmx.org/attributes/hx-swap/) (it's
important that we use `innerHTML` so the main target element persists if we
upload a different image),

These are some questions I'm asking myself at this point:

- What would happen if we didn't return a HTML element from the response?
- What would happen if we didn't return HTTP status 200?

We can actually already answer the first question, given what we know about
`innerHTML`: whatever text is returned from our `/upload` route is
directly set as the `innerHTML`, so we best make sure it's valid HTML :)

For our second question, let's just try it!

```javascript
// update server.js to just through an error:
app.post("/upload", async function(req, resp) {
  return resp.status(500).send(`Sorry, no thanks.`);
}
```

Then:

<center><img width="600" src="/images/500-error.gif" /></center>

We can see that nothing gets rendered, and we see the errors in the console.

With what we've seen so far, we would be justified in assuming that the text
`Sorry, no thanks` might have come through to the `<div id="result">` element,
but in fact if the response is a HTTP error code HTMX doesn't perform
subsequent steps (typically a good idea when something has gone wrong!)

Luckily, there is an extension:
[response-targets](https://htmx.org/extensions/response-targets/) that we can
use to get the behaviour we are after. Phew! We can make the following
modifications to our `index.html` page:

```html
<!-- index.html -->
<script src="https://unpkg.com/htmx.org@1.9.11"></script>
<script src="https://unpkg.com/htmx.org@1.9.11/dist/ext/response-targets.js"></script>
...

<body hx-ext="response-targets">
  <form
    hx-encoding="multipart/form-data"
    hx-post="/upload"
    hx-target="#result"
    hx-target-error="#result"
    hx-swap="innerHTML"
    >
    <input type="file" name="image" accept="image/png" />
    <button>
      Upload
    </button>
  </form>
  <div id="result"></div>
</body>
```

What did we do?

- We added a dependency on `dist/ext/response-targets.js`
- We added `hx-ext="response-targets" to the _parent_ of the elements we want to
  use it on ([read more about hx-ext](https://htmx.org/attributes/hx-ext/); I
  forgot this initially and was wondering why it didn't work!)
- We used the catch-all `hx-target-error` to send all errors to the
`id="result"` element, just for simplicity ([you can target specific error
codes if you wish](https://htmx.org/extensions/response-targets/#wildcard-resolution)).

Here's how it looks now:

<center><img width="600" src="/images/render-error.gif" /></center>

Success! We see the error rendered in the page! And in the case that we don't
hit an error, we will still render the image directly as well. That's exactly
what we wanted! :)


## Discussion

It's pretty nice to use HTMX to handle HTTP errors from your API: use
[response-targets](https://htmx.org/extensions/response-targets/) to pick up
specific errors, or all of them, and render the contents directly in the page!

A small detail that I came across along the way is the difference between
`outerHTML` and `innerHTML` and what you might consider _repeated behaviour_
while preserving the most "meaningful" structure for your HTMX documents.

The scenario is this: Imagine you want to repeatedly convert images; then you
need to make sure that the HTML element of `hx-target` persists; with
`innerHTML` it always will, but with `outerHTML` it will be replaced. The
advantage of `outerHTML` is it's a bit more "meaningful" to replace an `<img>`
tag with another `<img>` tag; and likewise. But, ultimately, it's up to you to
pick the style you prefer.


## Bonus content: The server is now in Haskell

HTMX is, after all, a front-end technology, so we can continue to use it if we
have our server in a different language.

It turns out Haskell will let us express one interesting requirement
of using HTMX: our routes should return _HTML_, not, say, JSON, or plain text.

In the [Servant](https://www.servant.dev/) ecosystem, you would having
something like the following[^imports] to define the `/upload` endpoint:

```haskell
-- Main.hs
data Routes mode = Routes
  { upload :: mode :- "upload" :> MultipartForm Mem (MultipartData Mem) :> Post '[HTML] Html
  , ...
  }
```

And then something like this 👇 (with a few details left out) to do what the
JavaScript `server.js` was doing before: read exactly one image from the form,
throw an error if not, and otherwise take the image, convert it to
a JPG, and return the new path as an `<img ... />` tag:

```haskell
-- Main.hs
uploadAndConvert :: MultipartData Mem -> Handler Html
uploadAndConvert form = do
  newPath <- case (files form) of
    [] -> oops "No files uploaded!"
    f : [] -> liftIO $ do
      let jpg = ...
          newPath = ...
      BIO.writeFile newPath jpg
      pure newPath
    ...
  pure $ [shamlet| <img src=#{newPath} /> |]
    where
      oops m = throwError $ err500 { errBody = m }
```

It is a requirement of the type system to make sure that this particular
endpoint returns _HTML_! It's then a small exercise to ensure that any _error_
content comes through with the appropriate HTML wrapping :) Happy Haskelling!

[^imports]: Note we've left off important import statements, but you can find
these in the [full code snippet](https://github.com/silky/htmx-servant-js-post/tree/main/haskell-image-converter/src/Main.hs).
