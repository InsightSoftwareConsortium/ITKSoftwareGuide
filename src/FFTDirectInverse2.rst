The source code for this section can be found in the file
``FFTDirectInverse2.cxx``.

This example illustrates how to compute the direct Fourier transform
followed by the inverse Fourier transform using the FFTW library.

First we set up the types of the input and output images.

::

    [language=C++]
    const unsigned int      Dimension = 2;
    typedef unsigned char   OutputPixelType;
    typedef unsigned short  OutputPixelType;
    typedef float           WorkPixelType;

    typedef itk::Image< WorkPixelType,  Dimension > InputImageType;
    typedef itk::Image< WorkPixelType,  Dimension > WorkImageType;
    typedef itk::Image< OutputPixelType,Dimension > OutputImageType;

