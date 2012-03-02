The source code for this section can be found in the file
``FastMarchingImageFilter.cxx``.

When the differential equation governing the level set evolution has a
very simple form, a fast evolution algorithm called fast marching can be
used.

The following example illustrates the use of the
{FastMarchingImageFilter}. This filter implements a fast marching
solution to a simple level set evolution problem. In this example, the
speed term used in the differential equation is expected to be provided
by the user in the form of an image. This image is typically computed as
a function of the gradient magnitude. Several mappings are popular in
the literature, for example, the negative exponential :math:`exp(-x)`
and the reciprocal :math:`1/(1+x)`. In the current example we decided
to use a Sigmoid function since it offers a good deal of control
parameters that can be customized to shape a nice speed image.

The mapping should be done in such a way that the propagation speed of
the front will be very low close to high image gradients while it will
move rather fast in low gradient areas. This arrangement will make the
contour propagate until it reaches the edges of anatomical structures in
the image and then slow down in front of those edges. The output of the
FastMarchingImageFilter is a *time-crossing map* that indicates, for
each pixel, how much time it would take for the front to arrive at the
pixel location.

    |image| [FastMarchingImageFilter collaboration diagram]
    {Collaboration diagram of the FastMarchingImageFilter applied to a
    segmentation task.} {fig:FastMarchingCollaborationDiagram}

The application of a threshold in the output image is then equivalent to
taking a snapshot of the contour at a particular time during its
evolution. It is expected that the contour will take a longer time to
cross over the edges of a particular anatomical structure. This should
result in large changes on the time-crossing map values close to the
structure edges. Segmentation is performed with this filter by locating
a time range in which the contour was contained for a long time in a
region of the image space.

Figure {fig:FastMarchingCollaborationDiagram} shows the major components
involved in the application of the FastMarchingImageFilter to a
segmentation task. It involves an initial stage of smoothing using the
{CurvatureAnisotropicDiffusionImageFilter}. The smoothed image is passed
as the input to the {GradientMagnitudeRecursiveGaussianImageFilter} and
then to the {SigmoidImageFilter}. Finally, the output of the
FastMarchingImageFilter is passed to a {BinaryThresholdImageFilter} in
order to produce a binary mask representing the segmented object.

The code in the following example illustrates the typical setup of a
pipeline for performing segmentation with fast marching. First, the
input image is smoothed using an edge-preserving filter. Then the
magnitude of its gradient is computed and passed to a sigmoid filter.
The result of the sigmoid filter is the image potential that will be
used to affect the speed term of the differential equation.

Let’s start by including the following headers. First we include the
header of the CurvatureAnisotropicDiffusionImageFilter that will be used
for removing noise from the input image.

::

    [language=C++]
    #include "itkCurvatureAnisotropicDiffusionImageFilter.h"

The headers of the GradientMagnitudeRecursiveGaussianImageFilter and
SigmoidImageFilter are included below. Together, these two filters will
produce the image potential for regulating the speed term in the
differential equation describing the evolution of the level set.

::

    [language=C++]
    #include "itkGradientMagnitudeRecursiveGaussianImageFilter.h"
    #include "itkSigmoidImageFilter.h"

Of course, we will need the {Image} class and the
FastMarchingImageFilter class. Hence we include their headers.

::

    [language=C++]
    #include "itkFastMarchingImageFilter.h"

The time-crossing map resulting from the FastMarchingImageFilter will be
thresholded using the BinaryThresholdImageFilter. We include its header
here.

::

    [language=C++]
    #include "itkBinaryThresholdImageFilter.h"

Reading and writing images will be done with the {ImageFileReader} and
{ImageFileWriter}.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

We now define the image type using a pixel type and a particular
dimension. In this case the {float} type is used for the pixels due to
the requirements of the smoothing filter.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The output image, on the other hand, is declared to be binary.

::

    [language=C++]
    typedef unsigned char                            OutputPixelType;
    typedef itk::Image< OutputPixelType, Dimension > OutputImageType;

The type of the BinaryThresholdImageFilter filter is instantiated below
using the internal image type and the output image type.

::

    [language=C++]
    typedef itk::BinaryThresholdImageFilter< InternalImageType,
    OutputImageType    >    ThresholdingFilterType;
    ThresholdingFilterType::Pointer thresholder = ThresholdingFilterType::New();

The upper threshold passed to the BinaryThresholdImageFilter will define
the time snapshot that we are taking from the time-crossing map. In an
ideal application the user should be able to select this threshold
interactively using visual feedback. Here, since it is a minimal
example, the value is taken from the command line arguments.

::

    [language=C++]
    thresholder->SetLowerThreshold(           0.0  );
    thresholder->SetUpperThreshold( timeThreshold  );

    thresholder->SetOutsideValue(  0  );
    thresholder->SetInsideValue(  255 );

We instantiate reader and writer types in the following lines.

::

    [language=C++]
    typedef  itk::ImageFileReader< InternalImageType > ReaderType;
    typedef  itk::ImageFileWriter<  OutputImageType  > WriterType;

The CurvatureAnisotropicDiffusionImageFilter type is instantiated using
the internal image type.

::

    [language=C++]
    typedef   itk::CurvatureAnisotropicDiffusionImageFilter<
    InternalImageType,
    InternalImageType >  SmoothingFilterType;

Then, the filter is created by invoking the {New()} method and assigning
the result to a {SmartPointer}.

::

    [language=C++]
    SmoothingFilterType::Pointer smoothing = SmoothingFilterType::New();

The types of the GradientMagnitudeRecursiveGaussianImageFilter and
SigmoidImageFilter are instantiated using the internal image type.

::

    [language=C++]
    typedef   itk::GradientMagnitudeRecursiveGaussianImageFilter<
    InternalImageType,
    InternalImageType >  GradientFilterType;
    typedef   itk::SigmoidImageFilter<
    InternalImageType,
    InternalImageType >  SigmoidFilterType;

The corresponding filter objects are instantiated with the {New()}
method.

::

    [language=C++]
    GradientFilterType::Pointer  gradientMagnitude = GradientFilterType::New();
    SigmoidFilterType::Pointer sigmoid = SigmoidFilterType::New();

The minimum and maximum values of the SigmoidImageFilter output are
defined with the methods {SetOutputMinimum()} and {SetOutputMaximum()}.
In our case, we want these two values to be :math:`0.0` and
:math:`1.0` respectively in order to get a nice speed image to feed to
the FastMarchingImageFilter. Additional details on the use of the
SigmoidImageFilter are presented in
Section {sec:IntensityNonLinearMapping}.

::

    [language=C++]
    sigmoid->SetOutputMinimum(  0.0  );
    sigmoid->SetOutputMaximum(  1.0  );

We now declare the type of the FastMarchingImageFilter.

::

    [language=C++]
    typedef  itk::FastMarchingImageFilter< InternalImageType,
    InternalImageType >    FastMarchingFilterType;

Then, we construct one filter of this class using the {New()} method.

::

    [language=C++]
    FastMarchingFilterType::Pointer  fastMarching = FastMarchingFilterType::New();

The filters are now connected in a pipeline shown in
Figure {fig:FastMarchingCollaborationDiagram} using the following lines.

::

    [language=C++]
    smoothing->SetInput( reader->GetOutput() );
    gradientMagnitude->SetInput( smoothing->GetOutput() );
    sigmoid->SetInput( gradientMagnitude->GetOutput() );
    fastMarching->SetInput( sigmoid->GetOutput() );
    thresholder->SetInput( fastMarching->GetOutput() );
    writer->SetInput( thresholder->GetOutput() );

The CurvatureAnisotropicDiffusionImageFilter class requires a couple of
parameters to be defined. The following are typical values for
:math:`2D` images. However they may have to be adjusted depending on
the amount of noise present in the input image. This filter has been
discussed in Section {sec:GradientAnisotropicDiffusionImageFilter}.

::

    [language=C++]
    smoothing->SetTimeStep( 0.125 );
    smoothing->SetNumberOfIterations(  5 );
    smoothing->SetConductanceParameter( 9.0 );

The GradientMagnitudeRecursiveGaussianImageFilter performs the
equivalent of a convolution with a Gaussian kernel followed by a
derivative operator. The sigma of this Gaussian can be used to control
the range of influence of the image edges. This filter has been
discussed in Section {sec:GradientMagnitudeRecursiveGaussianImageFilter}

::

    [language=C++]
    gradientMagnitude->SetSigma(  sigma  );

The SigmoidImageFilter class requires two parameters to define the
linear transformation to be applied to the sigmoid argument. These
parameters are passed using the {SetAlpha()} and {SetBeta()} methods. In
the context of this example, the parameters are used to intensify the
differences between regions of low and high values in the speed image.
In an ideal case, the speed value should be :math:`1.0` in the
homogeneous regions of anatomical structures and the value should decay
rapidly to :math:`0.0` around the edges of structures. The heuristic
for finding the values is the following. From the gradient magnitude
image, let’s call :math:`K1` the minimum value along the contour of
the anatomical structure to be segmented. Then, let’s call :math:`K2`
an average value of the gradient magnitude in the middle of the
structure. These two values indicate the dynamic range that we want to
map to the interval :math:`[0:1]` in the speed image. We want the
sigmoid to map :math:`K1` to :math:`0.0` and :math:`K2` to
:math:`1.0`. Given that :math:`K1` is expected to be higher than
:math:`K2` and we want to map those values to :math:`0.0` and
:math:`1.0` respectively, we want to select a negative value for alpha
so that the sigmoid function will also do an inverse intensity mapping.
This mapping will produce a speed image such that the level set will
march rapidly on the homogeneous region and will definitely stop on the
contour. The suggested value for beta is :math:`(K1+K2)/2` while the
suggested value for alpha is :math:`(K2-K1)/6`, which must be a
negative number. In our simple example the values are provided by the
user from the command line arguments. The user can estimate these values
by observing the gradient magnitude image.

::

    [language=C++]
    sigmoid->SetAlpha( alpha );
    sigmoid->SetBeta(  beta  );

The FastMarchingImageFilter requires the user to provide a seed point
from which the contour will expand. The user can actually pass not only
one seed point but a set of them. A good set of seed points increases
the chances of segmenting a complex object without missing parts. The
use of multiple seeds also helps to reduce the amount of time needed by
the front to visit a whole object and hence reduces the risk of leaks on
the edges of regions visited earlier. For example, when segmenting an
elongated object, it is undesirable to place a single seed at one
extreme of the object since the front will need a long time to propagate
to the other end of the object. Placing several seeds along the axis of
the object will probably be the best strategy to ensure that the entire
object is captured early in the expansion of the front. One of the
important properties of level sets is their natural ability to fuse
several fronts implicitly without any extra bookkeeping. The use of
multiple seeds takes good advantage of this property.

The seeds are passed stored in a container. The type of this container
is defined as {NodeContainer} among the FastMarchingImageFilter traits.

::

    [language=C++]
    typedef FastMarchingFilterType::NodeContainer           NodeContainer;
    typedef FastMarchingFilterType::NodeType                NodeType;
    NodeContainer::Pointer seeds = NodeContainer::New();

Nodes are created as stack variables and initialized with a value and an
{Index} position.

::

    [language=C++]
    NodeType node;
    const double seedValue = 0.0;

    node.SetValue( seedValue );
    node.SetIndex( seedPosition );

The list of nodes is initialized and then every node is inserted using
the {InsertElement()}.

::

    [language=C++]
    seeds->Initialize();
    seeds->InsertElement( 0, node );

The set of seed nodes is now passed to the FastMarchingImageFilter with
the method {SetTrialPoints()}.

::

    [language=C++]
    fastMarching->SetTrialPoints(  seeds  );

The FastMarchingImageFilter requires the user to specify the size of the
image to be produced as output. This is done using the
{SetOutputSize()}. Note that the size is obtained here from the output
image of the smoothing filter. The size of this image is valid only
after the {Update()} methods of this filter has been called directly or
indirectly.

::

    [language=C++]
    fastMarching->SetOutputSize(
    reader->GetOutput()->GetBufferedRegion().GetSize() );

Since the front representing the contour will propagate continuously
over time, it is desirable to stop the process once a certain time has
been reached. This allows us to save computation time under the
assumption that the region of interest has already been computed. The
value for stopping the process is defined with the method
{SetStoppingValue()}. In principle, the stopping value should be a
little bit higher than the threshold value.

::

    [language=C++]
    fastMarching->SetStoppingValue(  stoppingTime  );

The invocation of the {Update()} method on the writer triggers the
execution of the pipeline. As usual, the call is placed in a {try/catch}
block should any errors occur or exceptions be thrown.

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

Now let’s run this example using the input image
{BrainProtonDensitySlice.png} provided in the directory {Examples/Data}.
We can easily segment the major anatomical structures by providing seeds
in the appropriate locations. The following table presents the
parameters used for some structures.

            Structure & Seed Index & :math:`\sigma` & :math:`\alpha`
            & :math:`\beta` & Threshold & Output Image from left
             Left Ventricle & :math:`(81,114)` & 1.0 & -0.5 & 3.0 &
            100 & First
             Right Ventricle & :math:`(99,114)` & 1.0 & -0.5 & 3.0 &
            100 & Second
             White matter & :math:`(56, 92)` & 1.0 & -0.3 & 2.0 & 200
            & Third
             Gray matter & :math:`(40, 90)` & 0.5 & -0.3 & 2.0 & 200 &
            Fourth

    [FastMarching segmentation example parameters] {Parameters used for
    segmenting some brain structures shown in
    Figure {fig:FastMarchingImageFilterOutput2} using the filter
    FastMarchingImageFilter. All of them used a stopping value of
    100.{tab:FastMarchingImageFilterOutput2}}

Figure {fig:FastMarchingImageFilterOutput} presents the intermediate
outputs of the pipeline illustrated in
Figure {fig:FastMarchingCollaborationDiagram}. They are from left to
right: the output of the anisotropic diffusion filter, the gradient
magnitude of the smoothed image and the sigmoid of the gradient
magnitude which is finally used as the speed image for the
FastMarchingImageFilter.

    |image1| |image2| |image3| |image4| [FastMarchingImageFilter
    intermediate output] {Images generated by the segmentation process
    based on the FastMarchingImageFilter. From left to right and top to
    bottom: input image to be segmented, image smoothed with an
    edge-preserving smoothing filter, gradient magnitude of the smoothed
    image, sigmoid of the gradient magnitude. This last image, the
    sigmoid, is used to compute the speed term for the front propagation
    } {fig:FastMarchingImageFilterOutput}

Notice that the gray matter is not being completely segmented. This
illustrates the vulnerability of the level set methods when the
anatomical structures to be segmented do not occupy extended regions of
the image. This is especially true when the width of the structure is
comparable to the size of the attenuation bands generated by the
gradient filter. A possible workaround for this limitation is to use
multiple seeds distributed along the elongated object. However, note
that white matter versus gray matter segmentation is not a trivial task,
and may require a more elaborate approach than the one used in this
basic example.

    |image5| |image6| |image7| |image8| [FastMarchingImageFilter
    segmentations] {Images generated by the segmentation process based
    on the FastMarchingImageFilter. From left to right: segmentation of
    the left ventricle, segmentation of the right ventricle,
    segmentation of the white matter, attempt of segmentation of the
    gray matter.} {fig:FastMarchingImageFilterOutput2}

.. |image| image:: FastMarchingCollaborationDiagram1.eps
.. |image1| image:: BrainProtonDensitySlice.eps
.. |image2| image:: FastMarchingFilterOutput1.eps
.. |image3| image:: FastMarchingFilterOutput2.eps
.. |image4| image:: FastMarchingFilterOutput3.eps
.. |image5| image:: FastMarchingImageFilterOutput5.eps
.. |image6| image:: FastMarchingImageFilterOutput6.eps
.. |image7| image:: FastMarchingImageFilterOutput7.eps
.. |image8| image:: FastMarchingImageFilterOutput8.eps
