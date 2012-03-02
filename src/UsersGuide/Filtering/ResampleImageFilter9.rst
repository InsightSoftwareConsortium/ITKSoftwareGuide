The source code for this section can be found in the file
``ResampleImageFilter9.cxx``.

Resampling can also be performed in multi-component images. This example
compares nearest neighbor resampling using the Nearest neighbor and the
linear interpolators for vector images.

Try ResampleImageFilter9 Examples/Data/VisibleWomanEyeSlice.png
SliceNearestNeighbor.png SliceLinear.png

::

    [language=C++]
    PixelType defaultValue;
    defaultValue.Fill(50);
    nearestFilter->SetDefaultPixelValue( defaultValue );
    linearFilter->SetDefaultPixelValue( defaultValue );

::

    [language=C++]
    ImageType::SpacingType spacing;
    spacing[0] = .35;  pixel spacing in millimeters along X
    spacing[1] = .35;  pixel spacing in millimeters along Y

    nearestFilter->SetOutputSpacing( spacing );
    linearFilter->SetOutputSpacing( spacing );

::

    [language=C++]
    ImageType::PointType origin;
    origin[0] = 0.4;   X space coordinate of origin
    origin[1] = 0.4;   Y space coordinate of origin
    nearestFilter->SetOutputOrigin( origin );
    linearFilter->SetOutputOrigin( origin );

::

    [language=C++]
    ImageType::DirectionType direction;
    direction.SetIdentity();
    nearestFilter->SetOutputDirection( direction );
    linearFilter->SetOutputDirection( direction );

