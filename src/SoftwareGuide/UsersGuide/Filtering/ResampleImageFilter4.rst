Rotating an Image
^^^^^^^^^^^^^^^^^

The source code for this section can be found in the file
``ResampleImageFilter4.cxx``.

The following example illustrates how to rotate an image around its
center. In this particular case an {AffineTransform} is used to map the
input space into the output space.

The header of the affine transform is included below.

::

    [language=C++]
    #include "itkAffineTransform.h"

The transform type is instantiated using the coordinate representation
type and the space dimension. Then a transform object is constructed
with the New() method and passed to a {SmartPointer}.

::

    [language=C++]
    typedef itk::AffineTransform< double, Dimension >  TransformType;
    TransformType::Pointer transform = TransformType::New();

The parameters of the output image are taken from the input image.

::

    [language=C++]
    reader->Update();

    const InputImageType * inputImage = reader->GetOutput();

    const InputImageType::SpacingType & spacing = inputImage->GetSpacing();
    const InputImageType::PointType & origin  = inputImage->GetOrigin();
    InputImageType::SizeType size =
    inputImage->GetLargestPossibleRegion().GetSize();

    filter->SetOutputOrigin( origin );
    filter->SetOutputSpacing( spacing );
    filter->SetOutputDirection( inputImage->GetDirection() );
    filter->SetSize( size );

Rotations are performed around the origin of physical coordinates—not
the image origin nor the image center. Hence, the process of positioning
the output image frame as it is shown in Figure
{fig:ResampleImageFilterOutput10} requires three steps. First, the image
origin must be moved to the origin of the coordinate system, this is
done by applying a translation equal to the negative values of the image
origin.

    |image| |image1| [Effect of the Resample filter rotating an image]
    {Effect of the resample filter rotating an image.}
    {fig:ResampleImageFilterOutput10}

::

    [language=C++]
    TransformType::OutputVectorType translation1;

    const double imageCenterX = origin[0] + spacing[0] * size[0] / 2.0;
    const double imageCenterY = origin[1] + spacing[1] * size[1] / 2.0;

    translation1[0] =   -imageCenterX;
    translation1[1] =   -imageCenterY;

    transform->Translate( translation1 );

In a second step, the rotation is specified using the method
{Rotate2D()}.

::

    [language=C++]
    const double degreesToRadians = vcl_atan(1.0) / 45.0;
    const double angle = angleInDegrees * degreesToRadians;
    transform->Rotate2D( -angle, false );

The third and final step requires translating the image origin back to
its previous location. This is be done by applying a translation equal
to the origin values.

::

    [language=C++]
    TransformType::OutputVectorType translation2;
    translation2[0] =   imageCenterX;
    translation2[1] =   imageCenterY;
    transform->Translate( translation2, false );
    filter->SetTransform( transform );

The output of the resampling filter is connected to a writer and the
execution of the pipeline is triggered by a writer update.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

.. |image| image:: BrainProtonDensitySliceBorder20.eps
.. |image1| image:: ResampleImageFilterOutput10.eps
