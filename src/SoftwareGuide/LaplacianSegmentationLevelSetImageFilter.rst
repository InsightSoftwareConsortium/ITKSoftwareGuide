The source code for this section can be found in the file
``LaplacianSegmentationLevelSetImageFilter.cxx``.

The {LaplacianSegmentationLevelSetImageFilter} defines a speed term
based on second derivative features in the image. The speed term is
calculated as the Laplacian of the image values. The goal is to attract
the evolving level set surface to local zero-crossings in the Laplacian
image. Like {CannySegmentationLevelSetImageFilter}, this filter is more
suitable for refining existing segmentations than as a stand-alone,
region growing algorithm. It is possible to perform region growing
segmentation, but be aware that the growing surface may tend to become
“stuck” at local edges.

The propagation (speed) term for the
LaplacianSegmentationLevelSetImageFilter is constructed by applying the
{LaplacianImageFilter} to the input feature image. One nice property of
using the Laplacian is that there are no free parameters in the
calculation.

LaplacianSegmentationLevelSetImageFilter expects two inputs. The first
is an initial level set in the form of an {Image}. The second input is
the feature image :math:`g` from which the propagation term is
calculated (see Equation {eqn:LevelSetEquation}). Because the filter
performs a second derivative calculation, it is generally a good idea to
do some preprocessing of the feature image to remove noise.

Figure {fig:LaplacianSegmentationLevelSetImageFilterDiagram} shows how
the image processing pipeline is constructed. We read two images: the
image to segment and the image that contains the initial implicit
surface. The goal is to refine the initial model from the second input
to better match the structure represented by the initial implicit
surface (a prior segmentation). The {feature} image is preprocessed
using an anisotropic diffusion filter.

    |image| [LaplacianSegmentationLevelSetImageFilter collaboration
    diagram] {An image processing pipeline using
    LaplacianSegmentationLevelSetImageFilter for segmentation.}
    {fig:LaplacianSegmentationLevelSetImageFilterDiagram}

Let’s start by including the appropriate header files.

::

    [language=C++]
    #include "itkLaplacianSegmentationLevelSetImageFilter.h"
    #include "itkGradientAnisotropicDiffusionImageFilter.h"

We define the image type using a particular pixel type and dimension. In
this case we will use 2D {float} images.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The input image will be processed with a few iterations of
feature-preserving diffusion. We create a filter and set the parameters.
The number of iterations and the conductance parameter are taken from
the command line.

::

    [language=C++]
    typedef itk::GradientAnisotropicDiffusionImageFilter< InternalImageType,
    InternalImageType> DiffusionFilterType;
    DiffusionFilterType::Pointer diffusion = DiffusionFilterType::New();
    diffusion->SetNumberOfIterations( atoi(argv[4]) );
    diffusion->SetTimeStep(0.125);
    diffusion->SetConductanceParameter( atof(argv[5]) );

The following lines define and instantiate a
LaplacianSegmentationLevelSetImageFilter.

::

    [language=C++]
    typedef itk::LaplacianSegmentationLevelSetImageFilter< InternalImageType,
    InternalImageType > LaplacianSegmentationLevelSetImageFilterType;
    LaplacianSegmentationLevelSetImageFilterType::Pointer laplacianSegmentation =
    LaplacianSegmentationLevelSetImageFilterType::New();

As with the other ITK level set segmentation filters, the terms of the
LaplacianSegmentationLevelSetImageFilter level set equation can be
weighted by scalars. For this application we will modify the relative
weight of the propagation term. The curvature term weight is set to its
default of :math:`1`. The advection term is not used in this filter.

::

    [language=C++]
    laplacianSegmentation->SetCurvatureScaling( 1.0 );
    laplacianSegmentation->SetPropagationScaling( ::atof(argv[6]) );

The maximum number of iterations is set from the command line. It may
not be desirable in some applications to run the filter to convergence.
Only a few iterations may be required.

::

    [language=C++]
    laplacianSegmentation->SetMaximumRMSError( 0.002 );
    laplacianSegmentation->SetNumberOfIterations( ::atoi(argv[8]) );

Finally, it is very important to specify the isovalue of the surface in
the initial model input image. In a binary image, for example, the
isosurface is found midway between the foreground and background values.

::

    [language=C++]
    laplacianSegmentation->SetIsoSurfaceValue( ::atof(argv[7]) );

The filters are now connected in a pipeline indicated in
Figure {fig:LaplacianSegmentationLevelSetImageFilterDiagram}.

::

    [language=C++]
    diffusion->SetInput( reader1->GetOutput() );
    laplacianSegmentation->SetInput( reader2->GetOutput() );
    laplacianSegmentation->SetFeatureImage( diffusion->GetOutput() );
    thresholder->SetInput( laplacianSegmentation->GetOutput() );
    writer->SetInput( thresholder->GetOutput() );

Invoking the {Update()} method on the writer triggers the execution of
the pipeline. As usual, the call is placed in a {try/catch} block to
handle any exceptions that may be thrown.

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

We can use this filter to make some subtle refinements to the ventricle
segmentation from the example using the filter
{ThresholdSegmentationLevelSetImageFilter}. This application was run
using {Examples/Data/BrainProtonDensitySlice.png} and
{Examples/Data/VentricleModel.png} as inputs. We used :math:`10`
iterations of the diffusion filter with a conductance of 2.0. The
propagation scaling was set to :math:`1.0` and the filter was run
until convergence. Compare the results in the rightmost images of
Figure {fig:LaplacianSegmentationLevelSetImageFilter} with the ventricle
segmentation from Figure {fig:ThresholdSegmentationLevelSetImageFilter}
shown in the middle. Jagged edges are straightened and the small spur at
the upper right-hand side of the mask has been removed.

    |image1| |image2| |image3| [Segmentation results of
    LaplacianLevelSetImageFilter] {Results of applying
    LaplacianSegmentationLevelSetImageFilter to a prior ventricle
    segmentation. Shown from left to right are the original image, the
    prior segmentation of the ventricle from
    Figure {fig:ThresholdSegmentationLevelSetImageFilter}, and the
    refinement of the prior using
    LaplacianSegmentationLevelSetImageFilter.}
    {fig:LaplacianSegmentationLevelSetImageFilter}

.. |image| image:: LaplacianSegmentationLevelSetImageFilterCollaborationDiagram1.eps
.. |image1| image:: BrainProtonDensitySlice.eps
.. |image2| image:: ThresholdSegmentationLevelSetImageFilterVentricle.eps
.. |image3| image:: LaplacianSegmentationLevelSetImageFilterVentricle.eps
