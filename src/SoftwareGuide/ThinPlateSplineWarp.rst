The source code for this section can be found in the file
``ThinPlateSplineWarp.cxx``. This example deforms a 3D volume with the
Thin plate spline.

::

    [language=C++]
    #include "itkThinPlateSplineKernelTransform.h"

Landmarks correspondances may be associated with the
SplineKernelTransforms via Point Set containers. Let us define
containers for the landmarks.

::

    [language=C++]
    PointSetType::Pointer sourceLandMarks = PointSetType::New();
    PointSetType::Pointer targetLandMarks = PointSetType::New();
    PointType p1;     PointType p2;
    PointSetType::PointsContainer::Pointer sourceLandMarkContainer =
    sourceLandMarks->GetPoints();
    PointSetType::PointsContainer::Pointer targetLandMarkContainer =
    targetLandMarks->GetPoints();

::

    [language=C++]
    sourceLandMarkContainer->InsertElement( id, p1 );
    targetLandMarkContainer->InsertElement( id++, p2 );

::

    [language=C++]
    TransformType::Pointer tps = TransformType::New();
    tps->SetSourceLandmarks(sourceLandMarks);
    tps->SetTargetLandmarks(targetLandMarks);
    tps->ComputeWMatrix();

The image is then resampled to produce an output image as defined by the
transform. Here we use a LinearInterpolator.

::

    [language=C++]
    resampler->SetOutputSpacing( spacing );
    resampler->SetOutputDirection( direction );
    resampler->SetOutputOrigin(  origin  );
    resampler->SetSize( size );
    resampler->SetTransform( tps );

The deformation field is computed as the difference between the input
and the deformed image by using an iterator.
