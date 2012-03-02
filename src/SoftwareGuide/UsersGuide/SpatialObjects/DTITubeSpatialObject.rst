.. _sec-DTITubeSpatialObject:

DTITubeSpatialObject
^^^^^^^^^^^^^^^^^^^^


The source code for this section can be found in the file
``DTITubeSpatialObject.cxx``.

:itkdox:`itk::DTITubeSpatialObject` derives from
:itkdox:`itk::TubeSpatialObject`. It represents a fiber tracts from Diffusion
Tensor Imaging. A DTITubeSpatialObject is described as a list of centerline
points which have a position, a radius, normals, the fractional anisotropy (FA)
value, the ADC value, the geodesic anisotropy (GA) value, the eigenvalues and
vectors as well as the full tensor matrix.

Let’s start by including the appropriate header file.

::

    #include "itkDTITubeSpatialObject.h"

DTITubeSpatialObject is templated over the dimension of the space. A
DTITubeSpatialObject contains a list of DTITubeSpatialObjectPoints.

First we define some type definitions and we create the tube.

::

    typedef itk::DTITubeSpatialObject<3>            DTITubeType;
    typedef itk::DTITubeSpatialObjectPoint<3>       DTITubePointType;

    DTITubeType::Pointer dtiTube = DTITubeType::New();

We create a point list and we set:

- The position of each point in the local coordinate system using the
   ``SetPosition()`` method.

- The radius of the tube at this position using ``SetRadius()``.

- The FA value using ``AddField(DTITubePointType::FA)``.

- The ADC value using ``AddField(DTITubePointType::ADC)``.

- The GA value using ``AddField(DTITubePointType::GA)``.

- The full tensor matrix supposed to be symmetric definite positive
   value using ``SetTensorMatrix()``.

- The color of the point is set to red in our case.

::

    DTITubeType::PointListType list;
    for( i=0; i<5; i++)
      {
      DTITubePointType p;
      p.SetPosition(i,i+1,i+2);
      p.SetRadius(1);
      p.AddField(DTITubePointType::FA,i);
      p.AddField(DTITubePointType::ADC,2*i);
      p.AddField(DTITubePointType::GA,3*i);
      p.AddField("Lambda1",4*i);
      p.AddField("Lambda2",5*i);
      p.AddField("Lambda3",6*i);
      float* v = new float[6];
      for(unsigned int k=0;k<6;k++)
        {
        v[k] = k;
        }
      p.SetTensorMatrix(v);
      delete v;
      p.SetColor(1,0,0,1);
      list.push_back(p);
      }

Next, we create the tube and set its name using ``SetName()``. We also set its
identification number with ``SetId()`` and, at the end, we add the list of
points previously created.

::

    dtiTube->GetProperty()->SetName("DTITube");
    dtiTube->SetId(1);
    dtiTube->SetPoints(list);

The ``GetPoints()`` method return a reference to the internal list of
points of the object.

::

    DTITubeType::PointListType pointList = dtiTube->GetPoints();
    std::cout << "Number of points representing the fiber tract: ";
    std::cout << pointList.size() << std::endl;

Then we can access the points using STL iterators. ``GetPosition()`` and
``GetColor()`` functions return respectively the position and the color of
the point.

::

    DTITubeType::PointListType::const_iterator it = dtiTube->GetPoints().begin();
    i=0;
    while(it != dtiTube->GetPoints().end())
      {
      std::cout << std::endl;
      std::cout << "Point #" << i << std::endl;
      std::cout << "Position: " << (*it).GetPosition() << std::endl;
      std::cout << "Radius: " << (*it).GetRadius() << std::endl;
      std::cout << "FA: " << (*it).GetField(DTITubePointType::FA) << std::endl;
      std::cout << "ADC: " << (*it).GetField(DTITubePointType::ADC) << std::endl;
      std::cout << "GA: " << (*it).GetField(DTITubePointType::GA) << std::endl;
      std::cout << "Lambda1: " << (*it).GetField("Lambda1") << std::endl;
      std::cout << "Lambda2: " << (*it).GetField("Lambda2") << std::endl;
      std::cout << "Lambda3: " << (*it).GetField("Lambda3") << std::endl;
      std::cout << "TensorMatrix: " << (*it).GetTensorMatrix()[0] << " : ";
      std::cout << (*it).GetTensorMatrix()[1] << " : ";
      std::cout << (*it).GetTensorMatrix()[2] << " : ";
      std::cout << (*it).GetTensorMatrix()[3] << " : ";
      std::cout << (*it).GetTensorMatrix()[4] << " : ";
      std::cout << (*it).GetTensorMatrix()[5] << std::endl;
      std::cout << "Color = " << (*it).GetColor() << std::endl;
      it++;
      i++;
      }

