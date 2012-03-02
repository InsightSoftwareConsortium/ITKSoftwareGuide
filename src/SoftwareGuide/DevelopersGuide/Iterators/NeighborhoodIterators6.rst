The source code for this section can be found in the file
``NeighborhoodIterators6.cxx``.

Some image processing routines do not need to visit every pixel in an
image. Flood-fill and connected-component algorithms, for example, only
visit pixels that are locally connected to one another. Algorithms such
as these can be efficiently written using the random access capabilities
of the neighborhood iterator.

The following example finds local minima. Given a seed point, we can
search the neighborhood of that point and pick the smallest value
:math:`m`. While :math:`m` is not at the center of our current
neighborhood, we move in the direction of :math:`m` and repeat the
analysis. Eventually we discover a local minimum and stop. This
algorithm is made trivially simple in ND using an ITK neighborhood
iterator.

To illustrate the process, we create an image that descends everywhere
to a single minimum: a positive distance transform to a point. The
details of creating the distance transform are not relevant to the
discussion of neighborhood iterators, but can be found in the source
code of this example. Some noise has been added to the distance
transform image for additional interest.

The variable {input} is the pointer to the distance transform image. The
local minimum algorithm is initialized with a seed point read from the
command line.

::

    [language=C++]
    ImageType::IndexType index;
    index[0] = ::atoi(argv[2]);
    index[1] = ::atoi(argv[3]);

Next we create the neighborhood iterator and position it at the seed
point.

::

    [language=C++]
    NeighborhoodIteratorType::RadiusType radius;
    radius.Fill(1);
    NeighborhoodIteratorType it(radius, input, input->GetRequestedRegion());

    it.SetLocation(index);

Searching for the local minimum involves finding the minimum in the
current neighborhood, then shifting the neighborhood in the direction of
that minimum. The {for} loop below records the {Offset} of the minimum
neighborhood pixel. The neighborhood iterator is then moved using that
offset. When a local minimum is detected, {flag} will remain false and
the {while} loop will exit. Note that this code is valid for an image of
any dimensionality.

::

    [language=C++]
    bool flag = true;
    while ( flag == true )
    {
    NeighborhoodIteratorType::OffsetType nextMove;
    nextMove.Fill(0);

    flag = false;

    PixelType min = it.GetCenterPixel();
    for (unsigned i = 0; i < it.Size(); i++)
    {
    if ( it.GetPixel(i) < min )
    {
    min = it.GetPixel(i);
    nextMove = it.GetOffset(i);
    flag = true;
    }
    }
    it.SetCenterPixel( 255.0 );
    it += nextMove;
    }

Figure {fig:NeighborhoodExample6} shows the results of the algorithm for
several seed points. The white line is the path of the iterator from the
seed point to the minimum in the center of the image. The effect of the
additive noise is visible as the small perturbations in the paths.

    |image| |image1| |image2| [Finding local minima] {Paths traversed by
    the neighborhood iterator from different seed points to the local
    minimum. The true minimum is at the center of the image. The path of
    the iterator is shown in white. The effect of noise in the image is
    seen as small perturbations in each path. }
    {fig:NeighborhoodExample6}

.. |image| image:: NeighborhoodIterators6a.eps
.. |image1| image:: NeighborhoodIterators6b.eps
.. |image2| image:: NeighborhoodIterators6c.eps
