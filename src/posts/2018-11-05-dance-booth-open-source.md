---
title: Simple Dance Booth Open-Sourced (based on TensorFlow.js demo)
author: Noon van der Silk
---

Over on the [Silverpond](https://github.com/silverpond) GitHub account we
recently open-sourced the little
[dance-booth](https://github.com/silverpond/dance-booth) project that we've
been playing with for a while now.

<img src="/images/dance-booth.jpg" width="600" />

It's a very simple little wrapper around their
[PoseNet](https://github.com/tensorflow/tfjs-models/tree/master/posenet) demo.

It's a neat little repo, that runs entirely offline, and, from a webcam or
anything that can be accessed via the browser, can be used
to capture dances in three forms:

- The raw video from the webcam,
- JSON data of the poses per frame,
- Video of the skeleton dancing on the dance floor.

You'll find all of these saved under the date-and-time in the `./saved-videos`
folder. The JSON can be used to recreate the entire dance in any form you
wish; it gives the coords of the various joints.

At the present moment it the dance capture only starts when the people in
frame all raise their hands above their heads. 

Feel free to change and play with as you wish!

