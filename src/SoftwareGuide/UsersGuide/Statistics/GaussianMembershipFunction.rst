The source code for this section can be found in the file
``GaussianMembershipFunction.cxx``.

The Gaussian probability density function {Statistics}
{GaussianMembershipFunction} requires two distribution parameters—the
mean vector and the covariance matrix.

We include the header files for the class and the {Vector}.

::

    [language=C++]
    #include "itkVector.h"
    #include "itkGaussianMembershipFunction.h"

We define the type of the measurement vector that will be input to the
Gaussian membership function.

::

    [language=C++]
    typedef itk::Vector< float, 2 > MeasurementVectorType;

The instantiation of the function is done through the usual {New()}
method and a smart pointer.

::

    [language=C++]
    typedef itk::Statistics::GaussianMembershipFunction< MeasurementVectorType >
    DensityFunctionType;
    DensityFunctionType::Pointer densityFunction = DensityFunctionType::New();

The length of the measurement vectors in the membership function, in
this case a vector of length 2, is specified using the
{SetMeasurementVectorSize()} method.

::

    [language=C++]
    densityFunction->SetMeasurementVectorSize( 2 );

We create the two distribution parameters and set them. The mean is [0,
0], and the covariance matrix is a 2 x 2 matrix:
:math:`\begin{pmatrix}
4 & 0 \cr
0 & 4
\end{pmatrix}
` We obtain the probability density for the measurement vector: [0, 0]
using the {Evaluate(measurement vector)} method and print it out.

::

    [language=C++]
    DensityFunctionType::MeanVectorType mean( 2 );
    mean.Fill( 0.0 );

    DensityFunctionType::CovarianceMatrixType cov;
    cov.SetSize( 2, 2 );
    cov.SetIdentity();
    cov *= 4;

    densityFunction->SetMean( mean );
    densityFunction->SetCovariance( cov );

    MeasurementVectorType mv;
    mv.Fill( 0 );

    std::cout << densityFunction->Evaluate( mv ) << std::endl;

