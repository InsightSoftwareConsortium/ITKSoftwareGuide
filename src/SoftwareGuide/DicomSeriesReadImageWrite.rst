The source code for this section can be found in the file
``DicomSeriesReadImageWrite.cxx``.

Probably the most common representation of datasets in clinical
applications is the one that uses sets of DICOM slices in order to
compose tridimensional images. This is the case for CT, MRI and PET
scanners. It is very common therefore for image analysists to have to
process volumetric images that are stored in the form of a set of DICOM
files belonging to a common DICOM series.

The following example illustrates how to use ITK functionalities in
order to read a DICOM series into a volume and then save this volume in
another file format.
