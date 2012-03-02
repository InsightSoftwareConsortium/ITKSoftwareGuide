The source code for this section can be found in the file
``NeighborhoodIterators5.cxx``.

This example introduces slice-based neighborhood processing. A slice, in
this context, is a 1D path through an ND neighborhood. Slices are
defined for generic arrays by the {std::slice} class as a start index, a
step size, and an end index. Slices simplify the implementation of
certain neighborhood calculations. They also provide a mechanism for
taking inner products with subregions of neighborhoods.

Suppose, for example, that we want to take partial derivatives in the
:math:`y` direction of a neighborhood, but offset those derivatives by
one pixel position along the positive :math:`x` direction. For a
:math:`3\times3`, 2D neighborhood iterator, we can construct an
{std::slice}, {(start = 2, stride = 3, end = 8)}, that represents the
neighborhood offsets :math:`(1,
-1)`, :math:`(1, 0)`, :math:`(1, 1)` (see
Figure {fig:NeighborhoodIteratorFig2}). If we pass this slice as an
extra argument to the {NeighborhoodInnerProduct} function, then the
inner product is taken only along that slice. This “sliced” inner
product with a 1D {DerivativeOperator} gives the desired derivative.

The previous separable Gaussian filtering example can be rewritten using
slices and slice-based inner products. In general, slice-based
processing is most useful when doing many different calculations on the
same neighborhood, where defining multiple iterators as in
Section {sec:NeighborhoodExample4} becomes impractical or inefficient.
Good examples of slice-based neighborhood processing can be found in any
of the ND anisotropic diffusion function objects, such as
{CurvatureNDAnisotropicDiffusionFunction}.

The first difference between this example and the previous example is
that the Gaussian operator is only initialized once. Its direction is
not important because it is only a 1D array of coefficients.

::

    [language=C++]
    itk::GaussianOperator< PixelType, 2 > gaussianOperator;
    gaussianOperator.SetDirection(0);
    gaussianOperator.SetVariance( ::atof(argv[3]) * ::atof(argv[3]) );
    gaussianOperator.CreateDirectional();

Next we need to define a radius for the iterator. The radius in all
directions matches that of the single extent of the Gaussian operator,
defining a square neighborhood.

::

    [language=C++]
    NeighborhoodIteratorType::RadiusType radius;
    radius.Fill( gaussianOperator.GetRadius()[0] );

The inner product and face calculator are defined for the main
processing loop as before, but now the iterator is reinitialized each
iteration with the square {radius} instead of the radius of the
operator. The inner product is taken using a slice along the axial
direction corresponding to the current iteration. Note the use of
{GetSlice()} to return the proper slice from the iterator itself.
{GetSlice()} can only be used to return the slice along the complete
extent of the axial direction of a neighborhood.

::

    [language=C++]
    ImageType::Pointer input = reader->GetOutput();
    faceList = faceCalculator(input, output->GetRequestedRegion(), radius);

    for (unsigned int i = 0; i < ImageType::ImageDimension; ++i)
    {
    for ( fit=faceList.begin(); fit != faceList.end(); ++fit )
    {
    it = NeighborhoodIteratorType( radius, input, *fit );
    out = IteratorType( output, *fit );
    for (it.GoToBegin(), out.GoToBegin(); ! it.IsAtEnd(); ++it, ++out)
    {
    out.Set( innerProduct(it.GetSlice(i), it, gaussianOperator) );
    }
    }

    Swap the input and output buffers
    if (i != ImageType::ImageDimension - 1)
    {
    ImageType::Pointer tmp = input;
    input = output;
    output = tmp;
    }
    }

This technique produces exactly the same results as the previous
example. A little experimentation, however, will reveal that it is less
efficient since the neighborhood iterator is keeping track of extra,
unused pixel locations for each iteration, while the previous example
only references those pixels that it needs. In cases, however, where an
algorithm takes multiple derivatives or convolution products over the
same neighborhood, slice-based processing can increase efficiency and
simplify the implementation.
