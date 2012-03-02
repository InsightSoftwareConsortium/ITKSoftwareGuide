The source code for this section can be found in the file
``ShapedNeighborhoodIterators2.cxx``.

The logic of the inner loop can be rewritten to perform dilation.
Dilation of the set :math:`I` by :math:`E` is the set of all
:math:`x` such that :math:`E` positioned at :math:`x` contains at
least one element in :math:`I`.

::

    [language=C++]
    Implements dilation
    for (it.GoToBegin(), out.GoToBegin(); !it.IsAtEnd(); ++it, ++out)
    {
    ShapedNeighborhoodIteratorType::ConstIterator ci;

    bool flag = false;
    for (ci = it.Begin(); ci != it.End(); ci++)
    {
    if (ci.Get() != background_value)
    {
    flag = true;
    break;
    }
    }
    if (flag == true)
    {
    out.Set(foreground_value);
    }
    else
    {
    out.Set(background_value);
    }
    }
    }

The output image is written and visualized directly as a binary image of
{unsigned chars}. Figure {fig:ShapedNeighborhoodExample2} illustrates
some results of erosion and dilation on the image
{Examples/Data/BinaryImage.png}. Applying erosion and dilation in
sequence effects the morphological operations of opening and closing.

    |image| |image1| |image2| |image3| |image4| [Binary image
    morphology] {The effects of morphological operations on a binary
    image using a circular structuring element of size 4. From left to
    right are the original image, erosion, dilation, opening, and
    closing. The opening operation is erosion of the image followed by
    dilation. Closing is dilation of the image followed by erosion.}
    {fig:ShapedNeighborhoodExample2}

.. |image| image:: BinaryImage.eps
.. |image1| image:: ShapedNeighborhoodIterators1a.eps
.. |image2| image:: ShapedNeighborhoodIterators1b.eps
.. |image3| image:: ShapedNeighborhoodIterators1c.eps
.. |image4| image:: ShapedNeighborhoodIterators1d.eps
