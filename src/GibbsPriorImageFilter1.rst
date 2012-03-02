The source code for this section can be found in the file
``GibbsPriorImageFilter1.cxx``.

This example illustrates the use of the {RGBGibbsPriorFilter}. The
filter outputs a binary segmentation that can be improved by the
deformable model. It is the first part of our hybrid framework.

First, we include the appropriate header file.

::

    [language=C++]
    #include "itkRGBGibbsPriorFilter.h"

The input is a single channel 2D image; the channel number is {NUMBANDS}
= 1, and {NDIMENSION} is set to 3.

::

    [language=C++]
    const unsigned short NUMBANDS = 1;
    const unsigned short NDIMENSION = 3;

    typedef itk::Image<itk::Vector<unsigned short,NUMBANDS>,NDIMENSION> VecImageType;

The Gibbs prior segmentation is performed first to generate a rough
segmentation that yields a sample of tissue from a region to be
segmented, which will be combined to form the input for the
isocontouring method. We define the pixel type of the output of the
Gibbs prior filter to be {unsigned short}.

::

    [language=C++]
    typedef itk::Image< unsigned short, NDIMENSION > ClassImageType;

Then we define the classifier that is needed for the Gibbs prior model
to make correct segmenting decisions.

::

    [language=C++]
    typedef itk::ImageClassifierBase< VecImageType, ClassImageType > ClassifierType;
    typedef itk::ClassifierBase<VecImageType>::Pointer ClassifierBasePointer;

    typedef ClassifierType::Pointer ClassifierPointer;
    ClassifierPointer myClassifier = ClassifierType::New();

After that we can define the multi-channel Gibbs prior model.

::

    [language=C++]
    typedef itk::RGBGibbsPriorFilter<VecImageType,ClassImageType>
    GibbsPriorFilterType;
    GibbsPriorFilterType::Pointer applyGibbsImageFilter =
    GibbsPriorFilterType::New();

The parameters for the Gibbs prior filter are defined below.
{NumberOfClasses} indicates how many different objects are in the image.
The maximum number of iterations is the number of minimization steps.
{ClusterSize} sets the lower limit on the object’s size. The boundary
gradient is the estimate of the variance between objects and background
at the boundary region.

::

    [language=C++]
    applyGibbsImageFilter->SetNumberOfClasses(NUM_CLASSES);
    applyGibbsImageFilter->SetMaximumNumberOfIterations(MAX_NUM_ITER);
    applyGibbsImageFilter->SetClusterSize(10);
    applyGibbsImageFilter->SetBoundaryGradient(6);
    applyGibbsImageFilter->SetObjectLabel(1);

We now set the input classifier for the Gibbs prior filter and the input
to the classifier. The classifier will calculate the mean and variance
of the object using the class image, and the results will be used as
parameters for the Gibbs prior model.

::

    [language=C++]
    applyGibbsImageFilter->SetInput(vecImage);
    applyGibbsImageFilter->SetClassifier( myClassifier );
    applyGibbsImageFilter->SetTrainingImage(trainingimagereader->GetOutput());

Finally we execute the Gibbs prior filter using the Update() method.

::

    [language=C++]
    applyGibbsImageFilter->Update();

We execute this program on the image {brainweb89.png}. The following
parameters are passed to the command line:

::

    GibbsGuide.exe brainweb89.png brainweb89_train.png brainweb_gp.png

{brainweb89train} is a training image that helps to estimate the object
statistics.

Note that in order to successfully segment other images, one has to
create suitable training images for them. We can also segment color
(RGB) and other multi-channel images.
