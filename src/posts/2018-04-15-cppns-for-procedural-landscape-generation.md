---
title: CPPNs for Procedural Landscape Generation!
author: Noon van der Silk
---

<center><i>(Code related to this post: [cppn-3d](https://github.com/silky/cppn-3d/).)</i></center>

<br />

<center> 
<img src="/images/cppn/funky.png" /> 
<img src="/images/cppn/funky-3d-sized.png" /> 
</center>

So I've been obsessed with [CPPN's](https://en.wikipedia.org/wiki/Compositional_pattern-producing_network) 
ever since I saw this series of blogposts by [Hardmaru](https://github.com/hardmaru):

- [Neural Network Generative Art in Javascript](http://blog.otoro.net/2015/06/19/neural-network-generative-art/)
- [Generating Abstract Patterns with
TensorFlow](http://blog.otoro.net/2016/03/25/generating-abstract-patterns-with-tensorflow/)
- [Generating Large Images from Latent
Vectors](http://blog.otoro.net/2016/04/01/generating-large-images-from-latent-vectors/)
- [Generating Large Images from Latent Vectors - Part
Two](http://blog.otoro.net/2016/06/02/generating-large-images-from-latent-vectors-part-two/)
- [The Frog of CIFAR
10](http://blog.otoro.net/2016/04/06/the-frog-of-cifar-10/)

One of the main reasons I loved this idea so much is that almost all machine
learning that you see concerns itself with fixed output dimensions; at least
for images. The cool thing about the CPPN is that it maps _pixel coordinates_,
along with some configurably latent-vector $\vec{z}$, to _rgb values_:

$$
\text{cppn}(x, y, \vec{z}) = (r,g,b)
$$

This is cool because, there is a value defined for every point! So you can use
these things to create arbitrarily-large pictures! Furthermore, for a given
$\vec{z}$  we can make higher-resolution images by evaluating the network
over different widths.

At Silverpond we've put this idea to good use in our upcoming event at
[Melbourne Knowledge
Week](https://mkw.melbourne.vic.gov.au/events/ai-fashion-designer/).

In any case, here I'd like to document my playing-around with the idea of
using CPPNs to generate 3d landscapes. 

I've put together some pieces of code here:
[cppn-3d](https://github.com/silky/cppn-3d). Thanks to the amazing
[MyBinder](mybinder.org) you can even [run the notebook online, right
now,](https://mybinder.org/v2/gh/silky/cppn-3d/master?filepath=python%2FGenerate%20Maps.ipynb)
and start generating your own cool images!

To use the Python code, say, take a look at the
[notebook](https://github.com/silky/cppn-3d/blob/master/python/Generate%20Maps.ipynb)
and you'll see something like this (after imports):



```
latent_dim = 9
TAXICAB    = ft.partial(np.linalg.norm, axis=0, ord=1)
EUCLIDEAN  = ft.partial(np.linalg.norm, axis=0, ord=2)
INF        = ft.partial(np.linalg.norm, axis=0, ord=np.inf)

norms = []

c = Config( net_size   = 20
          , num_dense  = 5
          , latent_dim = latent_dim
          , colours    = 3
          , input_size = 1 + 1 + len(norms) + latent_dim
          , norms      = norms
          , activation_function = tf.nn.tanh
          )

size   = 512
width  = size
height = size

m = build_model(c)
z = np.random.normal(0, 1, size=c.latent_dim)

sess.run(tf.global_variables_initializer())

yss = forward(sess, c, m, z, width, height)
ys  = stitch_together(yss)
```

The magic here is that we can get quite different pictures by mucking around
with the params: `net_size`, `num_dense`, `norms`, `activation_function` and
basically just about anything!

The very simplistic idea I had was that we can generate images with nice
smooth colours, then just map those colours to heights, and that's the end of
it! I did this in [three.js](https://threejs.org/) and
[TensorFlow.js](https://js.tensorflow.org/) at first, with some terrible code:

<center>
<img width="512" src="/images/cppn/ex1.png" />
</center>

It worked! You can also [play with this
live](https://silky.github.io/cppn-3d/javascript/index.html) if you wish; it
does a kind of cool animation, albeit kinda slowly.

Of course, what I really wanted was to get a feel for how "walkable" or
"playable" the resulting map would be. So I found my way to Unity3D, and
half-wrote half-googled a tiny script to load in the image as a height map:

``` c#
using System.IO;
using UnityEngine;

public class TerrainHeight : MonoBehaviour {
    public int height  = 400;
    public int width   = 400;
    public int depth   = 200;
    public string cppnImage = "/home/noon/dev/cppn-3d/python/multi-2.png";


	void Start () {
        Terrain terrain     = GetComponent<Terrain>();
        terrain.terrainData = GenerateTerrain(terrain.terrainData);
	}
	

	TerrainData GenerateTerrain (TerrainData data) {
        data.size = new Vector3(width, depth, height);
		data.SetHeights(0, 0, GenerateHeights());
        return data;
	}


    public static Texture2D LoadPng (string filePath) {
        byte[] data       = File.ReadAllBytes(filePath);
        Texture2D texture = new Texture2D(2, 2);
        texture.LoadImage(data);
        return texture;
    }


    float[,] GenerateHeights () {
        float[,] heights = new float[width, height];
        Texture2D image = LoadPng(cppnImage);
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                Color colour = image.GetPixel(x, y);

                float height = colour.r
                             + colour.g
                             + colour.b;

                heights[x, y] = height / 3;
            }
        }

        return heights;
    }
}
```

In Unity3D, you attach this script to a terrain, then when you run it, it will
set that piece of terrain to have the given heights you want!

<center> <img src="/images/cppn/viewpoint.png" /> </center>

Looks alright! Obviously my general Unity skills need work, but at least it
looks something like a landscape! Here's a few more of the top view generate
by a bunch of similarly produced images:

<center> <img src="/images/cppn/a.png" /> 
<img src="/images/cppn/b.png" /> 
<img src="/images/cppn/c.png" /> 
<img src="/images/cppn/d.png" /> 
<img src="/images/cppn/e.png" /> 
<img src="/images/cppn/f.png" /> 
<img src="/images/cppn/g.png" /> 
</center>

The images that generated these (not in order) are in the
[maps](https://github.com/silky/cppn-3d/tree/master/python/maps) folder:


<center> <img width="250" src="/images/cppn/night-pond.png" /> 
<img width="250" src="/images/cppn/egg.png" /> 
<img width="250" src="/images/cppn/purple-rain.png" /> 
<img width="250" src="/images/cppn/raddish.png" /> 
<img width="250" src="/images/cppn/rose.png" /> 
<img width="250" src="/images/cppn/sharp-purple.png" /> 
<img width="250" src="/images/cppn/smooth-sand.png" /> 
</center>

Anyway, I hope someone finds this useful! I hope I can play with this idea a
bit more! I think there's a lot of juice to squeeze here, in terms of using
CPPNs to generate different levels of detail; to add much more detail to the
Unity terrain by making decisions based on height (such as where water goes,
where snow starts, etc). Furthermore, it would also be neat to auto-generate
town locations, and just about everything! Then of course there's all the
details of the CPPN itself to play with; the layer structure, adding more
variables, using different norms to highlight different regions of the
resulting image; the mind boggles at the options!

I hope this demonstrates how fun CPPNs can be!


### Aside

As an aside, early in the day I was experimenting with producing large tiled
images. 

The basic idea is conveyed here: 

<center>
<img src="/images/cppn/next-tile.png" />
</center>

On the left I have a particular image that I've generated. I want to continue
this image downwards by one tile. On the right is the same image with the next
tile.

This idea was due to [Gala](https://www.linkedin.com/in/galacamacho/) (who
works for [Neighbourlytics](https://www.neighbourlytics.com/)): basically,
given that we have the optimisation machinery at hand, why not just attempt to
find a new image, from the network, whose border matches at the point we're
interested in.

Initially, my idea was that I could do this by optimising over the z vector
$\vec{z}$ only; i.e. leave all the other parameters of the network alone. This 
turned out not to work at all. I'm actually not quite sure why, because my
experience with CPPNs is that if $\vec{z}$ is large, then you can get a whole
bunch of variation by modifying it. In any case, I tried it, and while it did
manage to make _some_ progress, it was never really particularly good.

When that approach didn't work, I used the one that generated the tile
connections from above: I just optimised with respect to the entire CPPN
network. 

There were a few problems with this approach, unfortunately:

1. The tiles it generated were less "interesting": In the image above, the one
   of the left is made of 3 tiles. The top one is the starting one; note it's
   complexity. The following two tiles are very low in interesting-ness, but
   the final one is actually not bad. This perhaps makes sense, as when the
   optimiser only has to match one colour, it can allow itself some richness
   in the other region.

2. It didn't work when I tried to match up _two_ boundaries:

<center>
<img width="250" src="/images/cppn/multi-1.png" />
<img width="250" src="/images/cppn/multi-2.png" />
<img width="250" src="/images/cppn/multi-3.png" />
<img width="250" src="/images/cppn/multi-4.png" />
<img width="250" src="/images/cppn/multi-6.png" />
<img width="250" src="/images/cppn/multi-7.png" />
</center>

In all these pictures, the bottom-right tile is very out of sync with it's two
neighbours. This could definitely be fixed "in post", by simplying blending
it, but it's still slightly unsatisfying that I couldn't solve this within the
CPPN framework. One original idea I had was to solve it by using
(something-like) the interpolation process you see in the [live JS
example](https://silky.github.io/cppn-3d/javascript/index.html). Namely, we
can pick two vectors $\vec{z_1}$ and $\vec{z_2}$ and move smoothly between
them. When you watch this animate, you can feel like there should be some
smoothing operation that would let us draw out a long line in this fashion. I
think the approach would be to take, slice-by-slice, new images from vectors
$\vec{z_{n+1}}$, and use the slices from them to produce a landscape. This
feels slightly odd to me, but perhaps would be nice.

In the end, my realisation was that I can produce very large maps simply by
increasing the richness in the CPPN: increasing the numbers of dense layers,
and "net size" (units in the dense layers), and then just simply making a
high-resolution version of the resulting image:

<center>
<img src="/images/cppn/rich-big.png" />
<a href="/images/cppn/rich-map.png"><img height="512" src="/images/cppn/rich-map.png" /></a>
</center>

In many ways I think I'm still a bit unsatisfied by this approach. I think
ultimately it would be nice to have a grid-layout map:

<center>
<img src="/images/cppn/cppn-map-dream.png" />
</center>

Where each block is controlled by some vector $\vec{z_i}$, and those can be
modified at will. This would definately be possible just by blending in some
standard way between the particular $\vec{z_i}$-values, but I do still think
there should be a CPPN-based solution. One idea
[Lyndon](http://sordina.github.io/) had was by directly constructing the image
from the grid, and then encoding that back into the CPPN, then decoding it, to
get the "closest match" that is still smooth between the borders. I think this
might work, but here we don't have an encoding network.

If you have any ideas along these lines, or find any of this useful, then 
[I'd love to hear from you](/about.html)!


## Bonus Content <small>(17-Apr-2018)</small>

I found a cool plugin in Unity --- [The Terrain
Toolkit](https://assetstore.unity.com/packages/tools/terrain/terrain-toolkit-2017-83490)
--- that lets me easily add textures, and I worked out how to add a water
plane (you just find it in the standard assets, and drag on the "Prefab", and
resize it), so we can give the maps a more earthly look and feel:

<center>
<a href="/images/cppn/texture-1.png"><img height="300" src="/images/cppn/texture-1.png" /></a>
<a href="/images/cppn/texture-2.png"><img height="300" src="/images/cppn/texture-2.png" /></a>
<a href="/images/cppn/texture-3.png"><img height="300" src="/images/cppn/texture-3.png" /></a>
<a href="/images/cppn/texture-4.png"><img height="300" src="/images/cppn/texture-4.png" /></a>
</center>

So cool! (I also updated the code so you can more easily express richer layers
in the CPPN, check out the Jupyter Notebook [Generate
Maps](https://github.com/silky/cppn-3d/blob/master/python/Generate%20Maps.ipynb)
for more deets.)
 
