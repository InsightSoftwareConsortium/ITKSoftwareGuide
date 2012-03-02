The source code for this section can be found in the file
``ImageLinearIteratorWithIndex.cxx``.

The {ImageLinearIteratorWithIndex} is designed for line-by-line
processing of an image. It walks a linear path along a selected image
direction parallel to one of the coordinate axes of the image. This
iterator conceptually breaks an image into a set of parallel lines that
span the selected image dimension.

Like all image iterators, movement of the ImageLinearIteratorWithIndex
is constrained within an image region :math:`R`. The line
:math:`\ell` through which the iterator moves is defined by selecting
a direction and an origin. The line :math:`\ell` extends from the
origin to the upper boundary of :math:`R`. The origin can be moved to
any position along the lower boundary of :math:`R`.

Several additional methods are defined for this iterator to control
movement of the iterator along the line :math:`\ell` and movement of
the origin of :math:`\ell`.

    **{NextLine()**} Moves the iterator to the beginning pixel location
    of the next line in the image. The origin of the next line is
    determined by incrementing the current origin along the fastest
    increasing dimension of the subspace of the image that excludes the
    selected dimension.

    **{PreviousLine()**} Moves the iterator to the *last valid pixel
    location* in the previous line. The origin of the previous line is
    determined by decrementing the current origin along the fastest
    increasing dimension of the subspace of the image that excludes the
    selected dimension.

    **{GoToBeginOfLine()**} Moves the iterator to the beginning pixel of
    the current line.

    **{GoToEndOfLine()**} Move the iterator to *one past* the last valid
    pixel of the current line.

    **{GoToReverseBeginOfLine()**} Move the iterator to *the last valid
    pixel* of the current line.

    **{IsAtReverseEndOfLine()**} Returns true if the iterator points to
    *one position before* the beginning pixel of the current line.

    **{IsAtEndOfLine()**} Returns true if the iterator points to *one
    position past* the last valid pixel of the current line.

The following code example shows how to use the
ImageLinearIteratorWithIndex. It implements the same algorithm as in the
previous example, flipping an image across its :math:`x`-axis. Two
line iterators are iterated in opposite directions across the
:math:`x`-axis. After each line is traversed, the iterator origins are
stepped along the :math:`y`-axis to the next line.

Headers for both the const and non-const versions are needed.

::

    [language=C++]
    #include "itkImageLinearIteratorWithIndex.h"

The RGB image and pixel types are defined as in the previous example.
The ImageLinearIteratorWithIndex class and its const version each have
single template parameters, the image type.

::

    [language=C++]
    typedef itk::ImageLinearIteratorWithIndex< ImageType >       IteratorType;
    typedef itk::ImageLinearConstIteratorWithIndex< ImageType >  ConstIteratorType;

After reading the input image, we allocate an output image that of the
same size, spacing, and origin.

::

    [language=C++]
    ImageType::Pointer outputImage = ImageType::New();
    outputImage->SetRegions( inputImage->GetRequestedRegion() );
    outputImage->CopyInformation( inputImage );
    outputImage->Allocate();

Next we create the two iterators. The const iterator walks the input
image, and the non-const iterator walks the output image. The iterators
are initialized over the same region. The direction of iteration is set
to 0, the :math:`x` dimension.

::

    [language=C++]
    ConstIteratorType inputIt( inputImage, inputImage->GetRequestedRegion() );
    IteratorType outputIt( outputImage, inputImage->GetRequestedRegion() );

    inputIt.SetDirection(0);
    outputIt.SetDirection(0);

Each line in the input is copied to the output. The input iterator moves
forward across columns while the output iterator moves backwards.

::

    [language=C++]
    for ( inputIt.GoToBegin(),  outputIt.GoToBegin(); ! inputIt.IsAtEnd();
    outputIt.NextLine(),  inputIt.NextLine())
    {
    inputIt.GoToBeginOfLine();
    outputIt.GoToEndOfLine();
    while ( ! inputIt.IsAtEndOfLine() )
    {
    --outputIt;
    outputIt.Set( inputIt.Get() );
    ++inputIt;
    }
    }

Running this example on {VisibleWomanEyeSlice.png} produces the same
output image shown in Figure {fig:ImageRegionIteratorWithIndexExample}.
