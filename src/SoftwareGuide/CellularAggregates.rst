Cellular Aggregates
===================

This chapter introduces the use of Cellular Aggregates for performing
image analysis tasks. Cellular Aggregates are an abstraction and
simplification of groups of biological cells. The emulation of cellular
behavior is used for taking advantage of their natural capabilities for
generating shapes, exploring space and cooperating for solving complex
situations.

The main application of Cellular Aggregates in the Insight Toolkit is
image segmentation. The following sections present the basic concepts
used in ITK for implementing Cellular Aggregates.

Overview
--------

In an over-simplified model of a biological cell, the following elements
can be considered to be the fundamental control system of the cell.

-  Genes
-  Proteins

Gene Network Modeling
---------------------

In order to model cell behavior it is necessary to perform simulations
of their internal gene network evolution. A Gene Network is simplified
here in the with the following model

A gene has several regions, namely

- a coding region
- a control region

The control region is composed of regulatory domains. Each domain is a
section of DNA with enough specific characteristics to make it
identifiable among all other domains. Regulatory domains can be
promoters, enhancers, silencers or repressors. In the ITK model, the
categories have been reduced to just enhancers and repressors. Proteins
in the cell, have domains that exhibit certain level of affinity for the
regulatory domains of the gene. The affinity of a particular protein
domain for a regulatory domain of a gene will define the probability of
a molecule of the protein to be bound to the regulatory domain for a
certain period of time. During this time, the regulatory domain will
influence the expression of the gene. Since we simplified the categories
of regulatory domains to just *enhancers* and *repressors*, the actions
of the regulatory domains can be represented by the following generic
expression

.. math::

    \frac{\partial{G}}{\partial t} = \left[ ABCDE + A\over{B} \right]

Where the :math:`\over{B}` represents the repressors and the normal
letters represents the enhancers. It is known from boolean algebra that
any boolean polynomial can be expressed as a sum of products composed by
the polynomial terms and their negations.

The values to be assigned to the letters are the probabilities of this
regulatory domains to be bound by a protein at a particular time. This
probability is estimated as the weighted sum of protein concentrations.
The weights are the affinities of each of the protein domains for the
particular regulatory domain.

For example, for the regulatory domain :math:`A`, we compute the
probability of a protein to be bound on this domain as the sum over all
the proteins, of :math:`A`-complementary domains affinities by the
protein concentration.

.. math::

    A = \sum_i P_i \cdot \sum_j D  \cdot Aff

Where :math:`Aff` is the affinity of the Domain :math:`j-th` of the
:math:`i-th` protein for the :math:`A` regulatory domain. By
considering only one-to-one domains, that is, a domain of a protein has
affinity only for a single type of regulatory domain. The affinity may
be of any value in the range [0,1] but it will be limited to a single
domain.

This is an ad hoc limitation of this model, introduced only with the
goal of simplifying the mathematical construction and increasing
computational performance.

A review on cell regulation through protein interaction domains is made
by Pawson and Nash in \cite{Pawson2003}.
