The source code for this section can be found in the file
``FourierDescriptors1.cxx``.

Fourier Descriptors provide a mechanism for representing a closed curve
in space. The represented curve has infinite continuiity because the
parametric coordinate of its points are computed from a Fourier Series.

In this example we illustrate how a curve that is initially defined by a
set of points in space can be represented in terms for Fourier
Descriptors. This representation is useful for several purposes. For
example, it provides a mechanmism for interpolating values among the
points, it provides a way of analyzing the smoothness of the curve. In
this particular example we will focus on this second application of the
Fourier Descriptors.

The first operation that we should use in this context is the
computation of the discrete fourier transform of the point coordinates.
The coordinates of the points are considered to be independent functions
and each one is decomposed in a Fourier Series. In this section we will
use :math:`t` as the parameter of the curve, and will assume that it
goes from :math:`0` to :math:`1` and cycles as we go around the
closed curve. :math:`\textbf{V(t)} = \left( X(t), Y(t) \rigth)
`

We take now the functions :math:`X(t)`, :math:`Y(t)` and interpret
them as the components of a complex number for wich we compute its
discrete fourier series in the form

:math:`V(t) = \sum_{k=0}^{N} \exp(-\frac{2 k \pi \textbf{i}}{N}) F_k
`

Where the set of coefficients :math:`F_k` is the discrete spectrum of
the complex function :math:`V(t)`. These coefficients are in general
complex numbers and both their magnitude and phase must be considered in
any further analysis of the spectrum.

The class {vnl\_fft\_1D} is the VNL class that computes such transform.
In order to use it, we should include its header file first.

::

    [language=C++]
    #include "vnl/algo/vnl_fft_1d.h"

We should now instantiate the filter that will compute the Fourier
transform of the set of coordinates.

::

    [language=C++]
    typedef vnl_fft_1d< double > FFTCalculator;

The points representing the curve are stored in a {VectorContainer} of
{Point}.

::

    [language=C++]
    typedef itk::Point< double, 2 >  PointType;

    typedef itk::VectorContainer< unsigned int, PointType >  PointsContainer;

    PointsContainer::Pointer points = PointsContainer::New();

In this example we read the set of points from a text file.

::

    [language=C++]
    std::ifstream inputFile;
    inputFile.open( argv[1] );

    if( inputFile.fail() )
    {
    std::cerr << "Problems opening file " << argv[1] << std::endl;
    }

    unsigned int numberOfPoints;
    inputFile >> numberOfPoints;

    points->Reserve( numberOfPoints );

    typedef PointsContainer::Iterator PointIterator;
    PointIterator pointItr = points->Begin();

    PointType point;
    for( unsigned int pt=0; pt<numberOfPoints; pt++)
    {
    inputFile >> point[0] >> point[1];
    pointItr.Value() = point;
    ++pointItr;
    }

This class will compute the Fast Fourier transform of the input an it
will return it in the same array. We must therefore copy the original
data into an auxiliary array that will in its turn contain the results
of the transform.

::

    [language=C++]
    typedef vcl_complex<double>              FFTCoefficientType;
    typedef vcl_vector< FFTCoefficientType > FFTSpectrumType;

The choice of the spectrum size is very important. Here we select to use
the next power of two that is larger than the number of points.

The Fourier Transform type can now be used for constructing one of such
filters. Note that this is a VNL class and does not follows ITK notation
for construction and assignment to SmartPointers.

::

    [language=C++]
    FFTCalculator  fftCalculator( spectrumSize );

::

    [language=C++]
    FFTCalculator  fftCalculator( spectrumSize );

Fill in the rest of the input with zeros. This padding may have
undesirable effects on the spectrum if the signal is not attenuated to
zero close to their boundaries. Instead of zero-padding we could have
used repetition of the last value or mirroring of the signal.

::

    [language=C++]
    for(unsigned int pad=numberOfPoints; pad<spectrumSize; pad++)
    {
    signal[pad] = 0.0;
    }

Now we print out the signal as it is passed to the transform calculator

::

    [language=C++]
    std::cout << "Input to the FFT transform" << std::endl;
    for(unsigned int s=0; s<spectrumSize; s++)
    {
    std::cout << s << " : ";
    std::cout << signal[s] << std::endl;
    }

The actual transform is computed by invoking the {fwd\_transform} method
in the FFT calculator class.

::

    [language=C++]
    fftCalculator.fwd_transform( signal );

Now we print out the results of the transform.

::

    [language=C++]
    std::cout << std::endl;
    std::cout << "Result from the FFT transform" << std::endl;
    for(unsigned int k=0; k<spectrumSize; k++)
    {
    const double real = signal[k].real();
    const double imag = signal[k].imag();
    const double magnitude = vcl_sqrt( real * real + imag * imag );
    std::cout << k << "  " << magnitude << std::endl;
    }

