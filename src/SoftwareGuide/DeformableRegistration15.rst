The source code for this section can be found in the file
``DeformableRegistration15.cxx``.

This example illustrates a realistic pipeline for solving a full
deformable registration problem.

First the two images are roughly aligned by using a transform
initialization, then they are registered using a rigid transform, that
in turn, is used to initialize a registration with an affine transform.
The transform resulting from the affine registration is used as the bulk
transform of a BSplineTransform. The deformable registration is
computed, and finally the resulting transform is used to resample the
moving image.

The following are the most relevant headers to this example.

::

    [language=C++]
    #include "itkCenteredTransformInitializer.h"
    #include "itkVersorRigid3DTransform.h"
    #include "itkAffineTransform.h"
    #include "itkBSplineTransform.h"
    #include "itkRegularStepGradientDescentOptimizer.h"

::

    [language=C++]
    #include "itkCenteredTransformInitializer.h"
    #include "itkVersorRigid3DTransform.h"
    #include "itkAffineTransform.h"
    #include "itkBSplineTransform.h"
    #include "itkRegularStepGradientDescentOptimizer.h"

Next we set the parameters of the RegularStepGradientDescentOptimizer
object.

::

    [language=C++]
    optimizer->SetMaximumStepLength( 10.0 );
    optimizer->SetMinimumStepLength(  0.01 );

    optimizer->SetRelaxationFactor( 0.7 );
    optimizer->SetNumberOfIterations( 50 );

Once the registration has finished with the low resolution grid, we
proceed to instantiate a higher resolution {BSplineTransform}.

Now we need to initialize the BSpline coefficients of the higher
resolution transform. This is done by first computing the actual
deformation field at the higher resolution from the lower resolution
BSpline coefficients. Then a BSpline decomposition is done to obtain the
BSpline coefficient of the higher resolution transform.

We now pass the parameters of the high resolution transform as the
initial parameters to be used in a second stage of the registration
process.

::

    [language=C++]
    registration->SetInitialTransformParameters( bsplineTransformFine->GetParameters() );
    registration->SetTransform( bsplineTransformFine );


    The BSpline transform at fine scale has a very large number of parameters,
    we use therefore a much larger number of samples to run this stage. In this
    case, however, the number of transform parameters is closer to the number
    of pixels in the image. Therefore we use the geometric mean of the two numbers
    to ensure that the number of samples is larger than the number of transform
    parameters and smaller than the number of samples.

    Regulating the number of samples in the Metric is equivalent to performing
    multi-resolution registration because it is indeed a sub-sampling of the
    image.
    const unsigned long numberOfSamples =
    static_cast<unsigned long>(
    vcl_sqrt( static_cast<double>( numberOfBSplineParameters ) *
    static_cast<double>( numberOfPixels ) ) );

    metric->SetNumberOfSpatialSamples( numberOfSamples );


    try
    {
    memorymeter.Start( "Deformable Registration Fine" );
    chronometer.Start( "Deformable Registration Fine" );

    registration->Update();

    chronometer.Stop( "Deformable Registration Fine" );
    memorymeter.Stop( "Deformable Registration Fine" );
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

