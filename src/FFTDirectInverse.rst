The source code for this section can be found in the file
``FFTDirectInverse.cxx``.

This example illustrates how to compute the direct Fourier transform
followed by the inverse Fourier transform in order to recover the
original data.

First we set up the types of the input and output images.

::

    [language=C++]
    const   unsigned int      Dimension = 2;
    typedef unsigned short    IOPixelType;
    typedef float             WorkPixelType;

    typedef itk::Image< IOPixelType,  Dimension >  IOImageType;
    typedef itk::Image< WorkPixelType, Dimension > WorkImageType;

