The source code for this section can be found in the file
``BSplineWarping2.cxx``.

This example illustrates how to deform a 3D image using a
\doxygen{BSplineTransform}.

.. index::
   single: BSplineTransform

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

    #include "itkResampleImageFilter.h"

    #include "itkBSplineTransform.h"
    #include "itkTransformFileWriter.h"

::

    [language=C++]
    const     unsigned int   ImageDimension = 3;

    typedef   unsigned char                            PixelType;
    typedef   itk::Image< PixelType, ImageDimension >  FixedImageType;
    typedef   itk::Image< PixelType, ImageDimension >  MovingImageType;

    typedef   itk::ImageFileReader< FixedImageType  >  FixedReaderType;
    typedef   itk::ImageFileReader< MovingImageType >  MovingReaderType;

    typedef   itk::ImageFileWriter< MovingImageType >  MovingWriterType;


    FixedReaderType::Pointer fixedReader = FixedReaderType::New();
    fixedReader->SetFileName( argv[2] );

    try
    {
    fixedReader->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Exception thrown " << std::endl;
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }


    MovingReaderType::Pointer movingReader = MovingReaderType::New();
    MovingWriterType::Pointer movingWriter = MovingWriterType::New();

    movingReader->SetFileName( argv[3] );
    movingWriter->SetFileName( argv[4] );


    FixedImageType::ConstPointer fixedImage = fixedReader->GetOutput();


    typedef itk::ResampleImageFilter< MovingImageType,
    FixedImageType  >  FilterType;

    FilterType::Pointer resampler = FilterType::New();

    typedef itk::LinearInterpolateImageFunction<
    MovingImageType, double >  InterpolatorType;

    InterpolatorType::Pointer interpolator = InterpolatorType::New();

    resampler->SetInterpolator( interpolator );

    FixedImageType::SpacingType   fixedSpacing    = fixedImage->GetSpacing();
    FixedImageType::PointType     fixedOrigin     = fixedImage->GetOrigin();
    FixedImageType::DirectionType fixedDirection  = fixedImage->GetDirection();

    resampler->SetOutputSpacing( fixedSpacing );
    resampler->SetOutputOrigin(  fixedOrigin  );
    resampler->SetOutputDirection(  fixedDirection  );


    FixedImageType::RegionType fixedRegion = fixedImage->GetBufferedRegion();
    FixedImageType::SizeType   fixedSize =  fixedRegion.GetSize();
    resampler->SetSize( fixedSize );
    resampler->SetOutputStartIndex(  fixedRegion.GetIndex() );


    resampler->SetInput( movingReader->GetOutput() );

    movingWriter->SetInput( resampler->GetOutput() );

We instantiate now the type of the \code{BSplineTransform} using as template
parameters the type for coordinates representation, the dimension of the
space, and the order of the B-spline.

::

    [language=C++]

    const unsigned int SpaceDimension = ImageDimension;
    const unsigned int SplineOrder = 3;
    typedef double CoordinateRepType;

    typedef itk::BSplineTransform<
    CoordinateRepType,
    SpaceDimension,
    SplineOrder >     TransformType;

    TransformType::Pointer bsplineTransform = TransformType::New();

::

    [language=C++]

    const unsigned int numberOfGridNodes = 8;

    TransformType::PhysicalDimensionsType   fixedPhysicalDimensions;
    TransformType::MeshSizeType             meshSize;

    for( unsigned int i=0; i< SpaceDimension; i++ )
    {
    fixedPhysicalDimensions[i] = fixedSpacing[i] * static_cast<double>(
    fixedSize[i] - 1 );
    }
    meshSize.Fill( numberOfGridNodes - SplineOrder );

    bsplineTransform->SetTransformDomainOrigin( fixedOrigin );
    bsplineTransform->SetTransformDomainPhysicalDimensions(
    fixedPhysicalDimensions );
    bsplineTransform->SetTransformDomainMeshSize( meshSize );
    bsplineTransform->SetTransformDomainDirection( fixedDirection );


    typedef TransformType::ParametersType     ParametersType;
    const unsigned int numberOfParameters =
    bsplineTransform->GetNumberOfParameters();

    const unsigned int numberOfNodes = numberOfParameters / SpaceDimension;

    ParametersType parameters( numberOfParameters );

The B-spline grid should now be fed with coeficients at each node. Since
this is a two dimensional grid, each node should receive two
coefficients. Each coefficient pair is representing a displacement
vector at this node. The coefficients can be passed to the B-spline in
the form of an array where the first set of elements are the first
component of the displacements for all the nodes, and the second set of
elemets is formed by the second component of the displacements for all
the nodes.

In this example we read such displacements from a file, but for
convinience we have written this file using the pairs of :math:`(x,y)`
displacement for every node. The elements read from the file should
therefore be reorganized when assigned to the elements of the array. We
do this by storing all the odd elements from the file in the first block
of the array, and all the even elements from the file in the second
block of the array. Finally the array is passed to the B-spline
transform using the \code{SetParameters()}.

::

    [language=C++]
    std::ifstream infile;

    infile.open( argv[1] );

    for( unsigned int n=0; n < numberOfNodes; n++ )
    {
    infile >>  parameters[n];                   X coordinate
    infile >>  parameters[n+numberOfNodes];     Y coordinate
    infile >>  parameters[n+numberOfNodes*2];   Z coordinate
    }

    infile.close();

Finally the array is passed to the B-spline transform using the
\code{SetParameters()}.

::

    [language=C++]

    bsplineTransform->SetParameters( parameters );

At this point we are ready to use the transform as part of the resample
filter. We trigger the execution of the pipeline by invoking \code{Update()}
on the last filter of the pipeline, in this case writer.

::

    [language=C++]
    resampler->SetTransform( bsplineTransform );

    try
    {
    movingWriter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Exception thrown " << std::endl;
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

