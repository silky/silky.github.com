---
title: Quantum neural networks
author: Noon van der Silk
---
 
Recently, I've been spending a lot of time thinking about machine learning,
and in particular deep learning. But before that, I was mostly concerning
myself with quantum computing, and specifically the algorithmic/theory side of
quantum computing.

In the last few days there's been a flurry of papers on quantum machine
learning/quantum neural networks, and related topics. Infact, there's been a
fair bit of research in the last few years (see the [Appendix](#appendix) at the end for
a few links), and I thought I'd take this opportunity to have a look at what
people are up to.

The papers we'll be discussing are:

- [arXiv:1612.01045 - Quantum generalisation of feedforward neural networks](https://scirate.com/arxiv/1612.01045) by Wan, Dahlsten, Kristjánsson, Gardner and Kim.
- [arXiv:1612.01789 - Quantum gradient descent and Newton's method for constrained polynomial optimization](https://scirate.com/arxiv/1612.01789) by Rebentrost, Schuld, Petruccione and Lloyd,
- [arXiv:1612.02806 - Quantum autoencoders for efficient compression of quantum data](https://scirate.com/arxiv/1612.02806) by Romero, Olson and Aspuru-Guzik,

But first, let's take a look at the paper that got me interested in machine
learning in the first place!

## arXiv:1307.0411 - Quantum algorithms for supervised and unsupervised machine learning

The paper, [Quantum algorithms for supervised and unsupervised machine
learning](https://scirate.com/arxiv/1307.0411) by Lloyd, Mohseni and
Rebentrost in 2013, was one of my first technical exposures to machine
learning. It's an interesting one because it demonstrates that for certain
types of clustering algorithms there is a quantum algorithm that exhibits an
exponential speed-up over the classical counterpart.

**Aside**: Gaining complexity-theoretic speed-ups is the central task of (quantum)
complexity theory. The speedup in this paper is interested, but it "only"
demonstrates a speed-up on a problem that is already known to be
*efficient*[^1] for classical computers, so it *doesn't* provide evidence that
quantum computers are fundamentally more powerful than classical ones, by the
standard notions in computer science.

[^1]: Here *efficient* means that the problem is in the complexity class caled
    $\textbf{P}$. Problems that are efficient for quantum computers are in the
    complexity class $\textbf{BQP}$. One of the main outstanding questions in
    the field is "Are quantum computers more powerful than classical ones?"
    and this can be phrased as comparing the class $\textbf{P}$ and
    $\textbf{BQP}$.

The `Supervised clustering` problem that is tackled in the paper is as
follows:

> Given some vector $\vec{u} \in \mathbb{R}^N$, and two sets of vectors $V$
> and $W$, then given $M$ representative samples from $V$: $\vec{v}_j \in V$
> and $\vec{w}_k \in W$, figure out which set $\vec{u}$ should go in to, by
> comparing the distances to these vectors.

In pictures it looks like so:

<div style='text-align: center'>
![Figure 1. An example of the supervised clustering problem
with $\vec{u} \in \mathbb{R}^2$ and $M=3$. We've drawn 3 points
from $V$, the (unknown) dashed purple region, and 3 points from $W$, the dashed pink region.](../images/supervised-clustering.png)
</div>

Classically, if we think about where we'd like to put $\vec{u}$, we could
compare  the distance to all the points $\vec{v_1}, \vec{v_2}, \vec{v_3}$ and
to all the points $\vec{w_1}, \vec{w_2},\vec{w_3}$. In the specific example
I've drawn, doing so will show that, out of the two sets, $\vec{u}$ belongs in
$V$.

In general, we can see that, using this approach, we would need to look at all
$M$ data points, and we'd need to compare each dimension of the $N$ dimensions
of each vector $\vec{v_j}, \vec{w_k}, \vec{u}$; i.e. we'd need to look at at
least $M\times N$ pieces of information. In other words, we'd compute the
distance

\begin{align*}
    d(\vec{u}, V) = \left| \vec{u} - \frac{1}{M}\sum_{j=1}^{M} \vec{v_j} \right|
\end{align*}

By looking at the problem slightly more formally, we find that classically the
best known algorithm takes "something like"[^2] $\texttt{pol}y(M\times N)$ steps,
where "$\texttt{poly}$" means that the true running time is a polynomial of
$M\times N$.

[^2]: <em>"Something like" x</em> here is a very informal term for the more formal
statement that the running time is $O(x)$. See [Big O
Notation](https://en.wikipedia.org/wiki/Big_O_notation) for more.

Quantumly, the paper demonstrates an algorithm that lets us solve this problem
in "something like" $\log(M\times N)$ time steps. This is a significant
improvement, in a practical sense. To get an idea, if we took $100$ samples
from a $N = 350$-dimensional space, then $M\times N = 35,000$ and $\log(M
\times N) \approx 10$.

The quantum algorithm works by constructing a state in a certain state so
that, when measured, the distance that we wanted, $d(\vec{u}, V)$, is the
probability that we achieve a certain measurement outcome. In this way, we can
build this certain state, and measure it, several times, and use this
information to approximate the required distances. And, the paper shows that this
whole process can be done in "something like" a running time of $\log(M\times
N)$.

There's more contirbutions in the paper than just this; so it's worth a look
if you're interested.



## arXiv:16.12.01045 - Quantum generalisation of feedforward neural networks

So this paper is pretty cool. We can get a feel for what it's doing by first
considering the following network:

<div style='text-align: center'>
![Figure 2. A simple classical neural network](../images/basic-nn.png)
</div>

This network has two inputs, $x_1, x_2$, three learnable weights, $w_1, w_2,
w_3$, one output value $y$, and an activation function $f$.

Classically one would feed in a series of training examples $(x_1, x_2, y)$
and update the weights according to some loss function to achieve the best
result for the given data.

Quantumly, there are some immediate problems with doing this, if we switch
the inputs $x$ to be quantum states, instead of classical real variables.

The problems are:

- Quantum operations need to be reversible; $f$ as written is not (at the
  very least, it takes two inputs and squashes them down to one output).
- Quantum states need to be normalised; so multiplying them by arbitrary
  weights won't be productive.
- You can't copy arbitrary quantum states due to the [No-Cloning
  theorem](https://en.wikipedia.org/wiki/No-cloning_theorem), so this
  restricts the type of networks that can be written down.

The way this paper solves these problems is to transition Figure 2 from a
classical non-reversible network to a reversible quantum one:

<div style='text-align: center'>
![Figure 3. The transition from classical, to reversible classical, to
quantum.](../images/transition-to-quantum-nn.png)
</div>

The final network takes in an arbitrary quantum state of two qubits, $x_1,
x_2$, and then adjoins an ancilla state $|0\rangle$, applies some unitary
operation $U$, and emits a combined final state
$|\psi\rangle^{\text{Out}}_{x_1,x_2,y}$ where the final qubit $y$ contains the
result we're interested in.

At this point, one might reasonably ask: How is this different to a quantum
circuit? It appears to me that the only difference is that $U$ is actually
unknown, and *it* is trainable! Note that this is also a somewhat radical
difference from classical neural networks: there, we don't normally think of
the activation functions (defined as $f$ above) as trainable parameters; but
quantumly, in this paper, that's exactly how we think of them!

It turns out that unitary matrices can be parameterised by a collection of
real variables $\alpha$. Consider an arbitrary unitary matrix operating on
two qubits, then $U$ can be written as:

\begin{align*}
    U = \exp\left[ i \left(
             \sum_{j_1,j_2=0,0}^{3,3} \alpha_{j_1, j_2} \times \left(\sigma_{j_1}
             \otimes \sigma_{j_2}\right) \right) \right]
\end{align*}

where $\sigma_i, i \in {1,2,3}$ are the usual [Pauli
matrices](https://en.wikipedia.org/wiki/Pauli_matrices) and $\sigma_0$ is the
$2\times 2$ identity matrix. So one can then make these parameters
$\alpha_{j_1, j_2}$ the *trainable* parameters! It turns out that in the paper
they don't train these parameters explicitly, instead they pick a less general
way of writing down unitary matricies, and they construct, by hand, a unitary
for two qubits. It's not clear why they've done this, and it would not be fun
to have to build a special trainable unitary matrix for each node/neuron of
your architecture depending on its input.

In any case, the main contribution of this paper seems to me to be the idea
that we can *learn* unitary matricies for our particular problem. They go on
to demonstrate that this idea works to build a quantum autoencoder, and to
make a neural network discover unitary matricies that perform the quantum
teleportation protocol.

Overall it's a promising technique that would be fun to try out.


## arXiv:1612.01789 - Quantum gradient descent and Newton's method for constrained polynomial optimization

Those of you familiar with neural networks will
know that the central idea used to train them is [Gradient
Descent](https://en.wikipedia.org/wiki/Gradient_descent).




## Appendix <a id="appendix"></a>

More interesting quantum machine learning papers:

- [1611.09347 - Quantum Machine Learning](https://scirate.com/arxiv/1611.09347) (most recent review)
- [1610.08251 - Quantum-enhanced machine learning](https://scirate.com/arxiv/1610.08251)
- [1605.05370 - Training A Quantum Optimizer](https://scirate.com/arxiv/1605.05370)
- [1603.08675 - Quantum Recommender Systems](https://scirate.com/arxiv/1603.08675)
- [1512.06069 - Demonstration of quantum advantage in machine learning](https://scirate.com/arxiv/1512.06069)
- [1512.02900 - Advances in quantum machine learning](https://scirate.com/arxiv/1512.02900)
- [1611.08104 - Quantum Enhanced Inference in Markov Logic Networks](https://scirate.com/arxiv/1611.08104)
- [1609.02542 - Quantum-assisted learning of graphical models with arbitrary pairwise connectivity](https://scirate.com/arxiv/1609.02542)
- [1609.06935 - Quantum Neural Machine Learning - Backpropagation and Dynamics](https://scirate.com/arxiv/1609.06935)
- [1606.02318 - Solving the Quantum Many-Body Problem with Artificial Neural Networks](https://scirate.com/arxiv/1606.02318)
- even more: [SciRate - quantum machine learning](https://scirate.com/search?utf8=%E2%9C%93&q=quantum+machine+learning)!
