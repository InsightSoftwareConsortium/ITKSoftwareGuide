The source code for this section can be found in the file
``ImageRegistration12.cxx``.

This example illustrates the use SpatialObjects as masks for selecting
the pixels that should contribute to the computation of Image Metrics.
This example is almost identical to ImageRegistration6 with the
exception that the SpatialObject masks are created and passed to the
image metric.

The most important header in this example is the one corresponding to
the {ImageMaskSpatialObject} class.

::

    [language=C++]
    #include "itkImageMaskSpatialObject.h"

Here we instantiate the type of the {ImageMaskSpatialObject} using the
same dimension of the images to be registered.

::

    [language=C++]
    typedef itk::ImageMaskSpatialObject< Dimension >   MaskType;

Then we use the type for creating the spatial object mask that will
restrict the registration to a reduced region of the image.

::

    [language=C++]
    MaskType::Pointer  spatialObjectMask = MaskType::New();

The mask in this case is read from a binary file using the
{ImageFileReader} instantiated for an {unsigned char} pixel type.

::

    [language=C++]
    typedef itk::Image< unsigned char, Dimension >   ImageMaskType;

    typedef itk::ImageFileReader< ImageMaskType >    MaskReaderType;

The reader is constructed and a filename is passed to it.

::

    [language=C++]
    MaskReaderType::Pointer  maskReader = MaskReaderType::New();

    maskReader->SetFileName( argv[3] );

As usual, the reader is triggered by invoking its {Update()} method.
Since this may eventually throw an exception, the call must be placed in
a {try/catch} block. Note that a full fledged application will place
this {try/catch} block at a much higher level, probably under the
control of the GUI.

::

    [language=C++]
    try
    {
    maskReader->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

The output of the mask reader is connected as input to the
{ImageMaskSpatialObject}.

::

    [language=C++]
    spatialObjectMask->SetImage( maskReader->GetOutput() );

Finally, the spatial object mask is passed to the image metric.

::

    [language=C++]
    metric->SetFixedImageMask( spatialObjectMask );

Let’s execute this example over some of the images provided in
{Examples/Data}, for example:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceR10X13Y17.png}

The second image is the result of intentionally rotating the first image
by :math:`10` degrees and shifting it :math:`13mm` in :math:`X`
and :math:`17mm` in :math:`Y`. Both images have unit-spacing and are
shown in Figure {fig:FixedMovingImageRegistration5}.

::

    [language=C++]
    transform->SetParameters( finalParameters );

    TransformType::MatrixType matrix = transform->GetRotationMatrix();
    TransformType::OffsetType offset = transform->GetOffset();

    std::cout << "Matrix = " << std::endl << matrix << std::endl;
    std::cout << "Offset = " << std::endl << offset << std::endl;

Now we resample the moving image using the transform resulting from the
registration process.
