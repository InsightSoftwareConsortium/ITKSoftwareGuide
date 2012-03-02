Rotating and Scaling an Image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The source code for this section can be found in the file
``ResampleImageFilter5.cxx``.

This example illustrates the use of the {Similarity2DTransform}. A
similarity transform involves rotation, translation and scaling. Since
the parameterization of rotations is difficult to get in a generic
:math:`ND` case, a particular implementation is available for
:math:`2D`.

The header file of the transform is included below.

::

    [language=C++]
    #include "itkSimilarity2DTransform.h"

The transform type is instantiated using the coordinate representation
type as the single template parameter.

::

    [language=C++]
    typedef itk::Similarity2DTransform< double >  TransformType;

A transform object is constructed by calling {New()} and passing the
result to a {SmartPointer}.

::

    [language=C++]
    TransformType::Pointer transform = TransformType::New();

The parameters of the output image are taken from the input image.

The Similarity2DTransform allows the user to select the center of
rotation. This center is used for both rotation and scaling operations.

::

    [language=C++]
    TransformType::InputPointType rotationCenter;
    rotationCenter[0] = origin[0] + spacing[0] * size[0] / 2.0;
    rotationCenter[1] = origin[1] + spacing[1] * size[1] / 2.0;
    transform->SetCenter( rotationCenter );

The rotation is specified with the method {SetAngle()}.

::

    [language=C++]
    const double degreesToRadians = vcl_atan(1.0) / 45.0;
    const double angle = angleInDegrees * degreesToRadians;
    transform->SetAngle( angle );

The scale change is defined using the method {SetScale()}.

::

    [language=C++]
    transform->SetScale( scale );

A translation to be applied after the rotation and scaling can be
specified with the method {SetTranslation()}.

::

    [language=C++]
    TransformType::OutputVectorType translation;

    translation[0] =   13.0;
    translation[1] =   17.0;

    transform->SetTranslation( translation );

    filter->SetTransform( transform );

Note that the order in which rotation, scaling and translation are
defined is irrelevant in this transform. This is not the case in the
Affine transform which is very generic and allow different combinations
for initialization. In the Similarity2DTransform class the rotation and
scaling will always be applied before the translation.

    |image| |image1| [Effect of the Resample filter rotating and scaling
    an image] {Effect of the resample filter rotating and scaling an
    image.} {fig:ResampleImageFilterOutput11}

Figure {fig:ResampleImageFilterOutput11} shows the effect of this
rotation, translation and scaling on a slice of a brain MRI. The scale
applied for producing this figure was :math:`1.2` and the rotation
angle was :math:`10^{\circ}`.

.. |image| image:: BrainProtonDensitySliceBorder20.eps
.. |image1| image:: ResampleImageFilterOutput11.eps
