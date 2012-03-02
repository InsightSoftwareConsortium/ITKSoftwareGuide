The source code for this section can be found in the file
``ResampleImageFilter6.cxx``.

Resampling can also be performed in multi-component images.

::

    [language=C++]
    PixelType defaultValue;
    defaultValue.Fill(50);

    filter->SetDefaultPixelValue( defaultValue );

::

    [language=C++]
    ImageType::SpacingType spacing;
    spacing[0] = .5;  pixel spacing in millimeters along X
    spacing[1] = .5;  pixel spacing in millimeters along Y

    filter->SetOutputSpacing( spacing );

::

    [language=C++]
    ImageType::PointType origin;
    origin[0] = 30.0;   X space coordinate of origin
    origin[1] = 40.0;   Y space coordinate of origin
    filter->SetOutputOrigin( origin );

::

    [language=C++]
    ImageType::DirectionType direction;
    direction.SetIdentity();
    filter->SetOutputDirection( direction );

