The source code for this section can be found in the file
``ImageRandomConstIteratorWithIndex.cxx``.

{ImageRandomConstIteratorWithIndex} was developed to randomly sample
pixel values. When incremented or decremented, it jumps to a random
location in its image region.

The user must specify a sample size when creating this iterator. The
sample size, rather than a specific image index, defines the end
position for the iterator. {IsAtEnd()} returns {true} when the current
sample number equals the sample size. {IsAtBegin()} returns {true} when
the current sample number equals zero. An important difference from
other image iterators is that ImageRandomConstIteratorWithIndex may
visit the same pixel more than once.

Let’s use the random iterator to estimate some simple image statistics.
The next example calculates an estimate of the arithmetic mean of pixel
values.

First, include the appropriate header and declare pixel and image types.

::

    [language=C++]
    #include "itkImageRandomConstIteratorWithIndex.h"

::

    [language=C++]
    const unsigned int Dimension = 2;

    typedef unsigned short                                       PixelType;
    typedef itk::Image< PixelType, Dimension >                   ImageType;
    typedef itk::ImageRandomConstIteratorWithIndex< ImageType >  ConstIteratorType;

The input image has been read as {inputImage}. We now create an iterator
with a number of samples set by command line argument. The call to
{ReinitializeSeed} seeds the random number generator. The iterator is
initialized over the entire valid image region.

::

    [language=C++]
    ConstIteratorType inputIt(  inputImage,  inputImage->GetRequestedRegion() );
    inputIt.SetNumberOfSamples( ::atoi( argv[2]) );
    inputIt.ReinitializeSeed();

Now take the specified number of samples and calculate their average
value.

::

    [language=C++]
    float mean = 0.0f;
    for ( inputIt.GoToBegin(); ! inputIt.IsAtEnd(); ++inputIt)
    {
    mean += static_cast<float>( inputIt.Get() );
    }
    mean = mean / ::atof( argv[2] );

Table {fig:ImageRandomConstIteratorWithIndexExample} shows the results
of running this example on several of the data files from
{Examples/Data} with a range of sample sizes.

            & {4} {c} {*Sample Size*}
            & {**10**} & {**100**} & {**1000**} & {**10000**}
            {2-5} {RatLungSlice1.mha} & 50.5 & 52.4 & 53.0 & 52.4
            {RatLungSlice2.mha} & 46.7 & 47.5 & 47.4 & 47.6
            {BrainT1Slice.png} & 47.2 & 64.1 & 68.0 & 67.8

        {fig:ImageRandomConstIteratorWithIndexExample}
        [ImageRandomConstIteratorWithIndex usage] {Estimates of mean
        image pixel value using the ImageRandomConstIteratorWithIndex at
        different sample sizes.}
