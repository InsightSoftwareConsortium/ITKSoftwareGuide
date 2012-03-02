The source code for this section can be found in the file
``CompositeFilterExample.cxx``.

The composite filter we will build combines three filters: a gradient
magnitude operator, which will calculate the first-order derivative of
the image; a thresholding step to select edges over a given strength;
and finally a rescaling filter, to ensure the resulting image data is
visible by scaling the intensity to the full spectrum of the output
image type.

Since this filter takes an image and produces another image (of
identical type), we will specialize the ImageToImageFilter:

::

    [language=C++]

Next we include headers for the component filters:

::

    [language=C++]
    #include "itkGradientMagnitudeImageFilter.h"
    #include "itkThresholdImageFilter.h"
    #include "itkRescaleIntensityImageFilter.h"

Now we can declare the filter itself. It is within the ITK namespace,
and we decide to make it use the same image type for both input and
output, thus the template declaration needs only one parameter. Deriving
from \code{ImageToImageFilter} provides default behavior for several
important aspects, notably allocating the output image (and making it
the same dimensions as the input).

::

    [language=C++]
    namespace itk {

    template <class TImageType>
    class ITK_EXPORT CompositeExampleImageFilter :
    public ImageToImageFilter<TImageType, TImageType>
    {
    public:

Next we have the standard declarations, used for object creation with
the object factory:

::

    [language=C++]
    typedef CompositeExampleImageFilter               Self;
    typedef ImageToImageFilter<TImageType,TImageType> Superclass;
    typedef SmartPointer<Self>                        Pointer;
    typedef SmartPointer<const Self>                  ConstPointer;

Here we declare an alias (to save typing) for the image’s pixel type,
which determines the type of the threshold value. We then use the
convenience macros to define the Get and Set methods for this parameter.

::

    [language=C++]

    typedef typename TImageType::PixelType PixelType;

    itkGetMacro( Threshold, PixelType);
    itkSetMacro( Threshold, PixelType);

Now we can declare the component filter types, templated over the
enclosing image type:

::

    [language=C++]
    protected:

    typedef ThresholdImageFilter< TImageType >                     ThresholdType;
    typedef GradientMagnitudeImageFilter< TImageType, TImageType > GradientType;
    typedef RescaleIntensityImageFilter< TImageType, TImageType >  RescalerType;

The component filters are declared as data members, all using the smart
pointer types.

::

    [language=C++]

    typename GradientType::Pointer     m_GradientFilter;
    typename ThresholdType::Pointer    m_ThresholdFilter;
    typename RescalerType::Pointer     m_RescaleFilter;

    PixelType m_Threshold;
    };

    } /* namespace itk */

The constructor sets up the pipeline, which involves creating the
stages, connecting them together, and setting default parameters.

::

    [language=C++]
    template <class TImageType>
    CompositeExampleImageFilter<TImageType>
    ::CompositeExampleImageFilter()
    {
    m_GradientFilter = GradientType::New();
    m_ThresholdFilter = ThresholdType::New();
    m_RescaleFilter = RescalerType::New();

    m_ThresholdFilter->SetInput( m_GradientFilter->GetOutput() );
    m_RescaleFilter->SetInput( m_ThresholdFilter->GetOutput() );

    m_Threshold = 1;

    m_RescaleFilter->SetOutputMinimum(NumericTraits<PixelType>::NonpositiveMin());
    m_RescaleFilter->SetOutputMaximum(NumericTraits<PixelType>::max());
    }

The \code{GenerateData()} is where the composite magic happens. First, we
connect the first component filter to the inputs of the composite filter
(the actual input, supplied by the upstream stage). Then we graft the
output of the last stage onto the output of the composite, which ensures
the filter regions are updated. We force the composite pipeline to be
processed by calling \code{Update()} on the final stage, then graft the
output back onto the output of the enclosing filter, so it has the
result available to the downstream filter.

::

    [language=C++]
    template <class TImageType>
    void
    CompositeExampleImageFilter<TImageType>::
    GenerateData()
    {
    m_GradientFilter->SetInput( this->GetInput() );

    m_ThresholdFilter->ThresholdBelow( this->m_Threshold );

    m_RescaleFilter->GraftOutput( this->GetOutput() );
    m_RescaleFilter->Update();
    this->GraftOutput( m_RescaleFilter->GetOutput() );
    }

Finally we define the \code{PrintSelf} method, which (by convention) prints
the filter parameters. Note how it invokes the superclass to print
itself first, and also how the indentation prefixes each line.

::

    [language=C++]

    template <class TImageType>
    void
    CompositeExampleImageFilter<TImageType>::
    PrintSelf( std::ostream& os, Indent indent ) const
    {
    Superclass::PrintSelf(os,indent);

    os
    << indent << "Threshold:" << this->m_Threshold
    << std::endl;
    }

    } /* end namespace itk */

It is important to note that in the above example, none of the internal
details of the pipeline were exposed to users of the class. The
interface consisted of the Threshold parameter (which happened to change
the value in the component filter) and the regular ImageToImageFilter
interface. This example pipeline is illustrated in
Figure \ref{fig:CompositeExamplePipeline}.
